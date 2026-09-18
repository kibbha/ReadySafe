import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../data/content.dart';
import '../models/checklist_item.dart';
import '../services/local_storage_service.dart';
import 'kit_item_detail_screen.dart';

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
  int filter = 0;
  late final String key;
  @override void initState(){super.initState();key=widget.kit?'kit72':'scenarios';_load();}
  Future<void> _load() async {final completed=await store.completed(key);final savedStock=widget.kit?await store.kitStock():<String,KitStockEntry>{};final savedFamily=widget.kit?await store.family():family;if(!mounted)return;setState((){done=completed;stock=savedStock;family=savedFamily;});}
  int get people=>(family['adults']??0)+(family['children']??0)+(family['care']??0); int get pets=>family['pets']??0;
  num? _target(ChecklistItem item){final base=item.recommendedQuantity;if(base==null)return null;final unit=item.unit??'';if(unit.contains('/ personne')||unit.contains('par personne'))return base*(people==0?1:people);if(unit.contains('/ enfant'))return base*(family['children']??0);if(unit.contains('/ animal'))return base*pets;return base;}
  String _unit(ChecklistItem item)=>(item.unit??'').replaceAll(' / personne','').replaceAll(' / enfant','').replaceAll(' / animal','').replaceAll('par personne','').trim();
  String _date(DateTime v)=>'${v.day.toString().padLeft(2,'0')}.${v.month.toString().padLeft(2,'0')}.${v.year}';
  bool _ready(ChecklistItem item){final entry=stock[item.id];if(entry==null||entry.isExpired)return false;final target=_target(item);if(target==null)return entry.quantityOwned>0||done.contains(item.id);return entry.quantityOwned>=target;}
  IconData _icon(ChecklistItem item){final text=item.label.toLowerCase();if(text.contains('eau'))return Icons.water_drop_outlined;if(text.contains('nourrit')||text.contains('aliment'))return Icons.lunch_dining_outlined;if(text.contains('lampe'))return Icons.flashlight_on_outlined;if(text.contains('batter')||text.contains('power'))return Icons.battery_charging_full;if(text.contains('radio'))return Icons.radio_outlined;if(text.contains('médic'))return Icons.medication_outlined;if(text.contains('document'))return Icons.description_outlined;if(text.contains('hygiène'))return Icons.sanitizer_outlined;return Icons.inventory_2_outlined;}
  IconData _categoryIcon(String category){final c=category.toLowerCase();if(c.contains('eau')||c.contains('nour'))return Icons.restaurant_outlined;if(c.contains('lumi')||c.contains('énerg'))return Icons.bolt_outlined;if(c.contains('commun'))return Icons.cell_tower_outlined;if(c.contains('sant')||c.contains('secour'))return Icons.medical_services_outlined;if(c.contains('document'))return Icons.folder_copy_outlined;if(c.contains('hygi'))return Icons.clean_hands_outlined;return Icons.inventory_2_outlined;}

  Future<void> _edit(ChecklistItem item) async {
    final current=stock[item.id]??KitStockEntry(itemId:item.id,reminderDays:item.expiryReminderDays);
    final result=await Navigator.of(context).push<KitStockEntry>(MaterialPageRoute(builder:(_)=>KitItemDetailScreen(item:item,initial:current,target:_target(item),unit:_unit(item),icon:_icon(item))));
    if(result==null)return;
    await store.saveKitStockEntry(result);
    if(!mounted)return;
    setState(()=>stock[item.id]=result);
  }

  @override Widget build(BuildContext context){final strings=AppLocalizations.of(context);final all=widget.kit?kitItems:scenarioLists.entries.expand((entry)=>entry.value.map((label)=>ChecklistItem(id:'${entry.key}-$label',label:label,category:entry.key))).toList();
    if(!widget.kit)return Scaffold(appBar:AppBar(title:Text(strings.get('checklists'))),body:Column(children:[LinearProgressIndicator(value:all.isEmpty?0:done.length/all.length),Expanded(child:ListView.builder(padding:const EdgeInsets.all(12),itemCount:all.length,itemBuilder:(context,index){final item=all[index],checked=done.contains(item.id);return Card(child:CheckboxListTile(value:checked,title:Text(item.label),subtitle:Text(item.category),onChanged:(v)async{final next=v??false;setState((){next?done.add(item.id):done.remove(item.id);});await store.toggle(key,item.id,next);}));}))]));
    final readyCount=all.where(_ready).length;final visible=all.where((item){if(filter==1)return !_ready(item);if(filter==2)return item.hasExpiry;return true;}).toList();final categories=<String,List<ChecklistItem>>{};for(final item in visible){categories.putIfAbsent(item.category,()=>[]).add(item);}return Scaffold(appBar:AppBar(title:const Text('Kit d’urgence')),body:Column(children:[Padding(padding:const EdgeInsets.fromLTRB(16,6,16,10),child:Column(children:[Row(children:List.generate(3,(i){const labels=['Tous','Manquants','Avec DLC'];return Expanded(child:Padding(padding:EdgeInsets.only(right:i<2?6:0),child:ChoiceChip(showCheckmark:false,label:Center(child:Text(labels[i])),selected:filter==i,onSelected:(_)=>setState(()=>filter=i))));})),const SizedBox(height:14),LinearProgressIndicator(value:all.isEmpty?0:readyCount/all.length,minHeight:8,borderRadius:BorderRadius.circular(6)),const SizedBox(height:7),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('$readyCount / ${all.length} éléments prêts',style:const TextStyle(fontWeight:FontWeight.w900)),Text('$people pers. • $pets animal(aux)',style:const TextStyle(color:Color(0xff65747a),fontSize:12))])])),Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(12,2,12,24),children:[for(final group in categories.entries)...[
      Padding(padding:const EdgeInsets.fromLTRB(5,12,5,7),child:Row(children:[Icon(_categoryIcon(group.key),size:19,color:const Color(0xff087f83)),const SizedBox(width:7),Text(group.key,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900,color:Color(0xff33454b)))])),
      ...group.value.map((item){final entry=stock[item.id],target=_target(item),unit=_unit(item),expired=entry?.isExpired??false,soon=item.hasExpiry&&(entry?.expiresWithin(entry.reminderDays)??false),quantity=entry?.quantityOwned??0,ready=_ready(item);return Card(margin:const EdgeInsets.only(bottom:7),child:InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>_edit(item),child:Padding(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),child:Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:expired||soon?const Color(0xffffeeee):const Color(0xffe8f5f5),borderRadius:BorderRadius.circular(13)),child:Icon(_icon(item),color:expired||soon?Theme.of(context).colorScheme.error:const Color(0xff087f83))),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.label,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),Text(target==null?'$quantity $unit':'$quantity $unit / $target $unit',style:const TextStyle(fontSize:12,color:Color(0xff65747a))),if(entry?.expiryDate!=null)Text('${expired?'DLC dépassée':'DLC'} : ${_date(entry!.expiryDate!)}',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:expired||soon?Theme.of(context).colorScheme.error:const Color(0xff65747a))) ])),Container(width:28,height:28,decoration:BoxDecoration(color:ready?const Color(0xff087f83):Colors.transparent,shape:BoxShape.circle,border:Border.all(color:ready?const Color(0xff087f83):const Color(0xffb8c6c9),width:2)),child:ready?const Icon(Icons.check,color:Colors.white,size:18):null),const SizedBox(width:3),const Icon(Icons.chevron_right,color:Color(0xff87969a))]))));}),
    ]]))]));}
}
