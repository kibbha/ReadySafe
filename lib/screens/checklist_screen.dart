import 'package:flutter/material.dart';
import '../app/localizations.dart';
import '../data/content.dart';
import '../models/checklist_item.dart';
import '../services/local_storage_service.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, required this.kit});
  final bool kit;
  @override State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final store = LocalStorageService();
  Set<String> done = {};
  Map<String, KitStockEntry> stock = {};
  Map<String, int> family = const {'adults':1,'children':0,'care':0,'pets':0};
  late final String key;

  @override void initState(){super.initState();key=widget.kit?'kit72':'scenarios';_load();}
  Future<void> _load() async {
    final completed=await store.completed(key);
    final savedStock=widget.kit?await store.kitStock():<String,KitStockEntry>{};
    final savedFamily=widget.kit?await store.family():family;
    if(mounted)setState((){done=completed;stock=savedStock;family=savedFamily;});
  }

  int get _people => (family['adults']??0)+(family['children']??0)+(family['care']??0);
  int get _pets => family['pets']??0;
  num? _target(ChecklistItem item){
    final base=item.recommendedQuantity;if(base==null)return null;
    final unit=item.unit??'';
    if(unit.contains('/ personne')||unit.contains('par personne')) return base*(_people==0?1:_people);
    if(unit.contains('/ enfant')) return base*(family['children']??0);
    if(unit.contains('/ animal')) return base*_pets;
    return base;
  }
  String _targetUnit(ChecklistItem item)=>(item.unit??'').replaceAll(' / personne','').replaceAll(' / enfant','').replaceAll(' / animal','').replaceAll('par personne','').trim();

  Future<void> _editKitItem(ChecklistItem item) async {
    final current=stock[item.id]??KitStockEntry(itemId:item.id);
    final quantity=TextEditingController(text:current.quantityOwned.toString());DateTime? expiry=current.expiryDate;
    final target=_target(item);final unit=_targetUnit(item);
    final result=await showModalBottomSheet<KitStockEntry>(context:context,isScrollControlled:true,builder:(sheetContext)=>StatefulBuilder(builder:(context,setSheetState)=>Padding(padding:EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).viewInsets.bottom+24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(item.label,style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),
      if(target!=null)Text('Recommandé pour votre foyer : $target $unit'),
      const SizedBox(height:16),TextField(controller:quantity,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:'Quantité disponible${unit.isEmpty?'':' ($unit)'}',border:const OutlineInputBorder())),
      if(item.hasExpiry)...[const SizedBox(height:16),ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.event),title:const Text('Date de péremption / rotation'),subtitle:Text(expiry==null?'Aucune date renseignée':'${expiry!.day.toString().padLeft(2,'0')}.${expiry!.month.toString().padLeft(2,'0')}.${expiry!.year}'),trailing:const Icon(Icons.edit_calendar),onTap:()async{final picked=await showDatePicker(context:context,initialDate:expiry??DateTime.now().add(const Duration(days:180)),firstDate:DateTime.now().subtract(const Duration(days:3650)),lastDate:DateTime.now().add(const Duration(days:7300)));if(picked!=null)setSheetState(()=>expiry=picked);}),Text('Alerte dans l’application ${item.expiryReminderDays} jours avant la date.',style:Theme.of(context).textTheme.bodySmall)],
      const SizedBox(height:20),SizedBox(width:double.infinity,child:FilledButton(onPressed:(){final parsed=num.tryParse(quantity.text.replaceAll(',','.'))??0;Navigator.pop(sheetContext,KitStockEntry(itemId:item.id,quantityOwned:parsed,expiryDate:expiry,updatedAt:DateTime.now()));},child:const Text('Enregistrer'))),
    ]))));quantity.dispose();if(result!=null){await store.saveKitStockEntry(result);if(mounted)setState(()=>stock[item.id]=result);}
  }

  @override Widget build(BuildContext context){
    final t=AppLocalizations.of(context);final items=widget.kit?kitItems:scenarioLists.entries.expand((e)=>e.value.map((x)=>ChecklistItem(id:'${e.key}-$x',label:x,category:e.key))).toList();
    final expiring=widget.kit?items.where((i)=>i.hasExpiry&&(stock[i.id]?.expiresWithin(i.expiryReminderDays)??false)).length:0;
    final expired=widget.kit?items.where((i)=>stock[i.id]?.isExpired??false).length:0;
    return Scaffold(appBar:AppBar(title:Text(widget.kit?t.get('kit'):t.get('checklists'))),body:Column(children:[
      LinearProgressIndicator(value:items.isEmpty?0:done.length/items.length),
      Padding(padding:const EdgeInsets.all(12),child:Column(children:[Text(t.get('items_ready',{'done':'${done.length}','total':'${items.length}'})),if(widget.kit)Padding(padding:const EdgeInsets.only(top:6),child:Text('Foyer : $_people personne(s) • $_pets animal(aux)',style:Theme.of(context).textTheme.bodySmall)),if(widget.kit&&(expired>0||expiring>0))Padding(padding:const EdgeInsets.only(top:8),child:Text('$expired périmé(s) • $expiring bientôt à remplacer',style:TextStyle(color:Theme.of(context).colorScheme.error,fontWeight:FontWeight.w600)))])),
      Expanded(child:ListView.builder(itemCount:items.length,itemBuilder:(_,i){final item=items[i];final checked=done.contains(item.id);final entry=stock[item.id];final target=_target(item);final unit=_targetUnit(item);final warning=entry?.isExpired==true?'Périmé — remplacer':(item.hasExpiry&&(entry?.expiresWithin(item.expiryReminderDays)??false)?'Expire bientôt':null);final detail=widget.kit?'${entry?.quantityOwned??0}${unit.isEmpty?'':' $unit'}${target==null?'':' / recommandé $target${unit.isEmpty?'':' $unit'}'}':item.category;return CheckboxListTile(value:checked,onChanged:(v)async{setState(()=>v==true?done.add(item.id):done.remove(item.id));await store.toggle(key,item.id,v??false);},title:Text(item.label),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(detail),if(warning!=null)Text(warning,style:TextStyle(color:Theme.of(context).colorScheme.error,fontWeight:FontWeight.w600))]),secondary:widget.kit?IconButton(icon:const Icon(Icons.tune),onPressed:()=>_editKitItem(item)):null,controlAffinity:ListTileControlAffinity.leading);}))
    ]));
  }
}
