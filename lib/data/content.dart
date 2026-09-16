import '../models/checklist_item.dart';
import '../models/guide.dart';

const emergencyGuides = [
  Guide(
    id: 'emergency',
    title: 'Urgence générale',
    icon: 'warning',
    immediate: 'Mettez-vous en sécurité, restez calme et évaluez le danger.',
    avoid: 'Ne vous exposez pas pour récupérer des objets.',
    steps: [
      'Éloignez-vous du danger immédiat.',
      'Alertez les secours si une vie est menacée.',
      'Prévenez un proche lorsque cela est sûr.',
    ],
    callHelp:
        'Appelez les secours en cas de danger vital, d’incendie ou de blessure grave.',
    evacuate:
        'Évacuez sur ordre des autorités ou si le lieu devient dangereux.',
  ),
  Guide(
    id: 'evacuation',
    title: 'Évacuation',
    icon: 'directions_run',
    immediate:
        'Prenez votre kit, vos documents et quittez la zone sans attendre.',
    avoid: 'N’attendez pas ou ne retournez pas dans une zone évacuée.',
    steps: [
      'Suivez les consignes officielles.',
      'Fermez gaz, eau et électricité si cela est sans danger.',
      'Rejoignez le point de rassemblement.',
    ],
    callHelp: 'Signalez toute personne vulnérable ou blessée.',
    evacuate: 'Évacuez immédiatement dès qu’un ordre est donné.',
  ),
  Guide(
    id: 'blackout',
    title: 'Coupure électrique',
    icon: 'power_off',
    immediate: 'Utilisez une lampe, préservez la batterie du téléphone.',
    avoid: 'N’utilisez jamais un générateur ou barbecue à l’intérieur.',
    steps: [
      'Débranchez les appareils sensibles.',
      'Gardez le réfrigérateur fermé.',
      'Écoutez les informations locales.',
    ],
    callHelp: 'Appelez en cas de ligne électrique tombée ou danger médical.',
    evacuate: 'Évacuez seulement si les autorités le demandent.',
  ),
];
const disasterGuides = [
  Guide(
    id: 'fire',
    title: 'Incendie',
    icon: 'local_fire_department',
    immediate: 'Sortez immédiatement et restez dehors.',
    avoid: 'Ne retournez jamais dans un bâtiment en feu.',
    steps: [
      'Alertez les occupants.',
      'Sortez par l’issue la plus sûre.',
      'Appelez les pompiers depuis l’extérieur.',
    ],
    callHelp: 'Appelez les pompiers dès que vous êtes en sécurité.',
    evacuate: 'Évacuez immédiatement si fumée, feu ou alarme.',
  ),
  Guide(
    id: 'flood',
    title: 'Inondation',
    icon: 'water',
    immediate: 'Gagnez un point haut et évitez toute eau en mouvement.',
    avoid: 'Ne marchez ni ne conduisez dans une zone inondée.',
    steps: [
      'Coupez l’électricité si sûr.',
      'Écoutez les alertes.',
      'Emportez le kit 72 h.',
    ],
    callHelp: 'Appelez si quelqu’un est isolé ou emporté.',
    evacuate: 'Évacuez dès l’alerte ou la montée des eaux.',
  ),
  Guide(
    id: 'storm',
    title: 'Tempête',
    icon: 'thunderstorm',
    immediate: 'Abritez-vous à l’intérieur, loin des fenêtres.',
    avoid: 'Ne restez pas sous les arbres ou près des lignes électriques.',
    steps: [
      'Chargez les appareils.',
      'Rentrez les objets extérieurs.',
      'Suivez les alertes météo.',
    ],
    callHelp: 'Appelez pour un danger immédiat.',
    evacuate: 'Évacuez si les autorités le demandent.',
  ),
  Guide(
    id: 'earthquake',
    title: 'Séisme',
    icon: 'landscape',
    immediate: 'Baissez-vous, abritez-vous, agrippez-vous.',
    avoid: 'Ne courez pas dehors pendant les secousses.',
    steps: [
      'Protégez tête et cou.',
      'Après les secousses, sortez prudemment.',
      'Attendez-vous à des répliques.',
    ],
    callHelp: 'Appelez pour blessures graves ou effondrement.',
    evacuate: 'Évacuez après les secousses si le bâtiment est endommagé.',
  ),
  Guide(
    id: 'heat',
    title: 'Canicule',
    icon: 'wb_sunny',
    immediate: 'Hydratez-vous et cherchez un endroit frais.',
    avoid: 'Ne laissez jamais enfant ou animal dans un véhicule.',
    steps: [
      'Buvez régulièrement.',
      'Évitez les efforts intenses.',
      'Prenez des nouvelles des proches fragiles.',
    ],
    callHelp:
        'Appelez en cas de confusion, perte de connaissance ou malaise grave.',
    evacuate: 'Rejoignez un lieu frais si votre logement devient dangereux.',
  ),
  Guide(
    id: 'cold',
    title: 'Grand froid',
    icon: 'ac_unit',
    immediate: 'Restez au chaud et limitez les sorties.',
    avoid: 'N’utilisez pas de chauffage à combustion sans ventilation.',
    steps: [
      'Superposez les vêtements.',
      'Isolez les canalisations.',
      'Vérifiez les voisins vulnérables.',
    ],
    callHelp: 'Appelez pour hypothermie ou intoxication suspectée.',
    evacuate: 'Évacuez si le chauffage ou la structure devient dangereuse.',
  ),
  Guide(
    id: 'water',
    title: 'Coupure d’eau',
    icon: 'water_drop',
    immediate: 'Préservez l’eau potable disponible.',
    avoid: 'Ne buvez pas une eau déclarée impropre.',
    steps: [
      'Utilisez l’eau stockée.',
      'Suivez les consignes sanitaires.',
      'Préparez des contenants propres.',
    ],
    callHelp: 'Appelez si un besoin médical nécessite de l’eau.',
    evacuate: 'Évacuez uniquement sur instruction officielle.',
  ),
  Guide(
    id: 'shelter',
    title: 'Confinement',
    icon: 'home',
    immediate: 'Rentrez, fermez portes, fenêtres et ventilation.',
    avoid: 'Ne sortez pas pour observer la situation.',
    steps: [
      'Suivez les sources officielles.',
      'Préparez eau et radio.',
      'Informez un proche par message.',
    ],
    callHelp: 'Appelez seulement en cas d’urgence réelle.',
    evacuate: 'Quittez le lieu uniquement sur ordre officiel.',
  ),
];
const firstAid = [
  'Malaise',
  'Saignement',
  'Brûlure',
  'Étouffement',
  'Fracture',
  'Entorse',
  'Perte de connaissance',
  'Réaction allergique',
  'Intoxication',
];
const kitItems = [
  ChecklistItem(
    id: 'water',
    label: 'Eau potable (au moins 3 L/personne/jour)',
    category: 'Eau',
  ),
  ChecklistItem(
    id: 'food',
    label: 'Nourriture non périssable pour 72 h',
    category: 'Nourriture',
  ),
  ChecklistItem(id: 'light', label: 'Lampe et piles', category: 'Lumière'),
  ChecklistItem(
    id: 'energy',
    label: 'Batterie externe chargée',
    category: 'Énergie',
  ),
  ChecklistItem(
    id: 'radio',
    label: 'Radio à piles ou manivelle',
    category: 'Communication',
  ),
  ChecklistItem(
    id: 'firstaid',
    label: 'Trousse de premiers secours',
    category: 'Premiers secours',
  ),
  ChecklistItem(
    id: 'hygiene',
    label: 'Produits d’hygiène',
    category: 'Hygiène',
  ),
  ChecklistItem(
    id: 'clothes',
    label: 'Vêtements chauds et couverture',
    category: 'Vêtements',
  ),
  ChecklistItem(
    id: 'docs',
    label: 'Copies des documents essentiels',
    category: 'Documents',
  ),
  ChecklistItem(
    id: 'tools',
    label: 'Multi-outil et ruban adhésif',
    category: 'Outils',
  ),
  ChecklistItem(
    id: 'children',
    label: 'Besoins spécifiques des enfants',
    category: 'Enfants',
  ),
  ChecklistItem(
    id: 'pets',
    label: 'Nourriture et laisse pour animaux',
    category: 'Animaux',
  ),
];
const scenarioLists = {
  'Évacuation': ['Kit 72 h', 'Documents', 'Médicaments', 'Itinéraire'],
  'Incendie': [
    'Sorties identifiées',
    'Détecteurs testés',
    'Point de rassemblement',
  ],
  'Panne électrique': ['Lampes', 'Batteries', 'Réfrigérateur fermé'],
  'Voyage': ['Assurance', 'Copies de documents', 'Kit voiture'],
  'Catastrophe naturelle': ['Alertes activées', 'Eau', 'Plan familial'],
  'Voiture': ['Carburant', 'Gilet réfléchissant', 'Trousse'],
  'Maison': ['Extincteur', 'Détecteurs', 'Coupures connues'],
  'Famille': ['Contacts', 'Point de rencontre', 'Besoins particuliers'],
};
