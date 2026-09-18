import '../models/checklist_item.dart';
import '../models/guide.dart';

const emergencyGuides = [
  Guide(id:'emergency',title:'Urgence générale',icon:'warning',immediate:'Mettez-vous en sécurité, restez calme et évaluez le danger.',avoid:'Ne vous exposez pas pour récupérer des objets.',steps:['Éloignez-vous du danger immédiat.','Alertez les secours si une vie est menacée.','Prévenez un proche lorsque cela est sûr.'],callHelp:'Appelez les secours en cas de danger vital, d’incendie ou de blessure grave.',evacuate:'Évacuez sur ordre des autorités ou si le lieu devient dangereux.'),
  Guide(id:'evacuation',title:'Évacuation',icon:'directions_run',immediate:'Prenez votre kit, vos documents et quittez la zone sans attendre.',avoid:'N’attendez pas ou ne retournez pas dans une zone évacuée.',steps:['Suivez les consignes officielles.','Fermez gaz, eau et électricité si cela est sans danger.','Rejoignez le point de rassemblement.'],callHelp:'Signalez toute personne vulnérable ou blessée.',evacuate:'Évacuez immédiatement dès qu’un ordre est donné.'),
  Guide(id:'blackout',title:'Coupure électrique',icon:'power_off',immediate:'Utilisez une lampe, préservez la batterie du téléphone.',avoid:'N’utilisez jamais un générateur ou barbecue à l’intérieur.',steps:['Débranchez les appareils sensibles.','Gardez le réfrigérateur fermé.','Écoutez les informations locales.'],callHelp:'Appelez en cas de ligne électrique tombée ou danger médical.',evacuate:'Évacuez seulement si les autorités le demandent.'),
];

const disasterGuides = [
  Guide(id:'fire',title:'Incendie',icon:'local_fire_department',immediate:'Sortez immédiatement et restez dehors.',avoid:'Ne retournez jamais dans un bâtiment en feu.',steps:['Alertez les occupants.','Sortez par l’issue la plus sûre.','Appelez les pompiers depuis l’extérieur.'],callHelp:'Appelez les pompiers dès que vous êtes en sécurité.',evacuate:'Évacuez immédiatement si fumée, feu ou alarme.'),
  Guide(id:'flood',title:'Inondation',icon:'water',immediate:'Gagnez un point haut et évitez toute eau en mouvement.',avoid:'Ne marchez ni ne conduisez dans une zone inondée.',steps:['Coupez l’électricité si sûr.','Écoutez les alertes.','Emportez le kit d’urgence.'],callHelp:'Appelez si quelqu’un est isolé ou emporté.',evacuate:'Évacuez dès l’alerte ou la montée des eaux.'),
  Guide(id:'storm',title:'Tempête',icon:'thunderstorm',immediate:'Abritez-vous à l’intérieur, loin des fenêtres.',avoid:'Ne restez pas sous les arbres ou près des lignes électriques.',steps:['Chargez les appareils.','Rentrez les objets extérieurs.','Suivez les alertes météo.'],callHelp:'Appelez pour un danger immédiat.',evacuate:'Évacuez si les autorités le demandent.'),
  Guide(id:'earthquake',title:'Séisme',icon:'landscape',immediate:'Baissez-vous, abritez-vous, agrippez-vous.',avoid:'Ne courez pas dehors pendant les secousses.',steps:['Protégez tête et cou.','Après les secousses, sortez prudemment.','Attendez-vous à des répliques.'],callHelp:'Appelez pour blessures graves ou effondrement.',evacuate:'Évacuez après les secousses si le bâtiment est endommagé.'),
  Guide(id:'heat',title:'Canicule',icon:'wb_sunny',immediate:'Hydratez-vous et cherchez un endroit frais.',avoid:'Ne laissez jamais enfant ou animal dans un véhicule.',steps:['Buvez régulièrement.','Évitez les efforts intenses.','Prenez des nouvelles des proches fragiles.'],callHelp:'Appelez en cas de confusion, perte de connaissance ou malaise grave.',evacuate:'Rejoignez un lieu frais si votre logement devient dangereux.'),
  Guide(id:'cold',title:'Grand froid',icon:'ac_unit',immediate:'Restez au chaud et limitez les sorties.',avoid:'N’utilisez pas de chauffage à combustion sans ventilation.',steps:['Superposez les vêtements.','Isolez les canalisations.','Vérifiez les voisins vulnérables.'],callHelp:'Appelez pour hypothermie ou intoxication suspectée.',evacuate:'Évacuez si le chauffage ou la structure devient dangereuse.'),
  Guide(id:'water',title:'Coupure d’eau',icon:'water_drop',immediate:'Préservez l’eau potable disponible.',avoid:'Ne buvez pas une eau déclarée impropre.',steps:['Utilisez l’eau stockée.','Suivez les consignes sanitaires.','Préparez des contenants propres.'],callHelp:'Appelez si un besoin médical nécessite de l’eau.',evacuate:'Évacuez uniquement sur instruction officielle.'),
  Guide(id:'shelter',title:'Confinement',icon:'home',immediate:'Rentrez, fermez portes, fenêtres et ventilation.',avoid:'Ne sortez pas pour observer la situation.',steps:['Suivez les sources officielles.','Préparez eau et radio.','Informez un proche par message.'],callHelp:'Appelez seulement en cas d’urgence réelle.',evacuate:'Quittez le lieu uniquement sur ordre officiel.'),
];

const firstAid = ['Malaise','Saignement','Brûlure','Étouffement','Fracture','Entorse','Perte de connaissance','Réaction allergique','Intoxication'];

/// Base stock for one adult. The UI will later scale household-dependent
/// quantities from the saved family profile. Expiry/rotation dates are entered
/// by the user because they depend on the exact purchased product.
const kitItems = [
  ChecklistItem(id:'water',label:'Eau potable',category:'Eau',recommendedQuantity:9,unit:'L / personne',hasExpiry:true,expiryReminderDays:30,notes:'Réserve minimale de boisson pour environ 3 jours.'),
  ChecklistItem(id:'food',label:'Aliments longue conservation',category:'Nourriture',recommendedQuantity:7,unit:'jours / personne',hasExpiry:true,expiryReminderDays:30),
  ChecklistItem(id:'pet_food',label:'Nourriture pour animaux',category:'Nourriture',recommendedQuantity:7,unit:'jours / animal',hasExpiry:true,expiryReminderDays:30),
  ChecklistItem(id:'medication',label:'Médicaments personnels indispensables',category:'Santé',recommendedQuantity:1,unit:'réserve',hasExpiry:true,expiryReminderDays:30,notes:'Conserver selon la notice et les prescriptions; ne pas modifier un traitement sans avis professionnel.'),
  ChecklistItem(id:'firstaid',label:'Trousse de premiers secours',category:'Santé',recommendedQuantity:1,unit:'trousse',hasExpiry:true,expiryReminderDays:60),
  ChecklistItem(id:'disinfectant',label:'Antiseptique / désinfectant adapté',category:'Santé',recommendedQuantity:1,unit:'flacon',hasExpiry:true,expiryReminderDays:60),
  ChecklistItem(id:'light',label:'Lampe de poche ou frontale',category:'Éclairage',recommendedQuantity:1,unit:'lampe'),
  ChecklistItem(id:'batteries',label:'Piles de rechange adaptées',category:'Éclairage',recommendedQuantity:1,unit:'jeu',hasExpiry:true,expiryReminderDays:90),
  ChecklistItem(id:'powerbank',label:'Batterie externe chargée',category:'Énergie',recommendedQuantity:1,unit:'batterie'),
  ChecklistItem(id:'cables',label:'Câbles de charge essentiels',category:'Énergie',recommendedQuantity:1,unit:'jeu'),
  ChecklistItem(id:'radio',label:'Radio à piles ou manivelle',category:'Communication',recommendedQuantity:1,unit:'radio'),
  ChecklistItem(id:'cash',label:'Argent liquide en petites coupures',category:'Documents & argent',recommendedQuantity:1,unit:'réserve'),
  ChecklistItem(id:'docs',label:'Copies protégées des documents essentiels',category:'Documents & argent',recommendedQuantity:1,unit:'jeu'),
  ChecklistItem(id:'contacts',label:'Liste papier des contacts importants',category:'Communication',recommendedQuantity:1,unit:'liste'),
  ChecklistItem(id:'hygiene',label:'Kit d’hygiène personnelle',category:'Hygiène',recommendedQuantity:1,unit:'kit / personne'),
  ChecklistItem(id:'toilet_paper',label:'Papier toilette et sacs résistants',category:'Hygiène',recommendedQuantity:1,unit:'réserve'),
  ChecklistItem(id:'clothes',label:'Vêtements chauds de rechange',category:'Protection',recommendedQuantity:1,unit:'jeu / personne'),
  ChecklistItem(id:'blanket',label:'Couverture ou sac de couchage',category:'Protection',recommendedQuantity:1,unit:'par personne'),
  ChecklistItem(id:'rain',label:'Protection contre la pluie',category:'Protection',recommendedQuantity:1,unit:'par personne'),
  ChecklistItem(id:'gloves',label:'Gants de travail',category:'Outils',recommendedQuantity:1,unit:'paire'),
  ChecklistItem(id:'multitool',label:'Multi-outil',category:'Outils',recommendedQuantity:1,unit:'outil'),
  ChecklistItem(id:'tape',label:'Ruban adhésif résistant',category:'Outils',recommendedQuantity:1,unit:'rouleau'),
  ChecklistItem(id:'whistle',label:'Sifflet de signalisation',category:'Signalisation',recommendedQuantity:1,unit:'sifflet'),
  ChecklistItem(id:'lighter',label:'Moyen d’allumage protégé de l’humidité',category:'Outils',recommendedQuantity:1,unit:'jeu'),
  ChecklistItem(id:'children',label:'Besoins spécifiques bébé/enfant',category:'Enfants',recommendedQuantity:1,unit:'kit / enfant',hasExpiry:true,expiryReminderDays:30),
  ChecklistItem(id:'pet_gear',label:'Laisse, caisse et besoins spécifiques animaux',category:'Animaux',recommendedQuantity:1,unit:'kit / animal'),
];

const scenarioLists = {
  'Évacuation':['Kit d’urgence','Documents','Médicaments','Itinéraire'],
  'Incendie':['Sorties identifiées','Détecteurs testés','Point de rassemblement'],
  'Panne électrique':['Lampes','Batteries','Réfrigérateur fermé'],
  'Voyage':['Assurance','Copies de documents','Kit voiture'],
  'Catastrophe naturelle':['Alertes activées','Eau','Plan familial'],
  'Voiture':['Carburant','Gilet réfléchissant','Trousse'],
  'Maison':['Extincteur','Détecteurs','Coupures connues'],
  'Famille':['Contacts','Point de rencontre','Besoins particuliers'],
};
