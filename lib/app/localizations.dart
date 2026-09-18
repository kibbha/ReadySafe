import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;

  static const Map<String, String> _fr = {
    'adults': 'Adultes',
    'children': 'Enfants',
    'days': 'Jours',
    'water_result': 'Eau recommandée',
    'meal_result': 'Repas recommandés',
    'calculator_estimate': 'Estimation de préparation',
    'calculator_note':
        'Adaptez ces estimations à la santé, au climat et aux consignes locales.',
    'litres_for':
        '{litres} litres pour {people} personne(s) pendant {days} jour(s)',
    'meals_for': '{meals} repas à prévoir (3 par personne et par jour)',
    'family_profile': 'Profil familial local',
    'family_privacy':
        'N’enregistrez que ce qui aide à préparer votre foyer. Aucune donnée n’est envoyée à un serveur.',
    'care_people': 'Personnes nécessitant une attention particulière',
    'pets': 'Animaux domestiques',
    'save_local': 'Enregistrer localement',
    'saved_offline': 'Profil enregistré hors ligne.',
    'items_ready': '{done} / {total} éléments prêts',
    'do_now': 'À faire immédiatement',
    'avoid': 'À éviter',
    'steps': 'Étapes',
    'when_call': 'Quand appeler les secours',
    'when_evacuate': 'Quand évacuer',
    'search_country': 'Rechercher un pays',
    'numbers_unverified': 'Numéros non vérifiés',
    'service_unverified_desc': 'Aucun numéro vérifié publié pour ce pays',
    'info_numbers_pending':
        'Les numéros nationaux de ce pays sont en cours de vérification. ReadySafe ne propose aucun appel tant qu’une source officielle n’est pas validée.',
    'not_callable': 'Appel indisponible tant que le numéro n’est pas vérifié',
    'all_filter': 'Tous',
    'europe_filter': 'Europe',
    'downloaded_filter': 'Téléchargés',
    'search_maps': 'Rechercher un pack',
    'size_unknown': 'Taille à confirmer',
    'map_update': 'Mise à jour disponible',
    'map_downloading': 'Téléchargement',
    'pause': 'Pause',
    'resume': 'Reprendre',
    'verify': 'Vérifier',
    'illustration_ready': 'Illustration pédagogique ReadySafe hors ligne',
    'aid_cpr_adult': 'RCP adulte',
    'aid_aed': 'Utiliser un DAE',
    'aid_aed_summary': 'Un DAE guide vocalement chaque action.',
    'aid_aed_1':
        'Demandez un DAE pendant qu’une autre personne appelle les secours.',
    'aid_aed_2': 'Allumez le DAE et placez les électrodes comme indiqué.',
    'aid_aed_3':
        'Éloignez-vous pendant l’analyse et suivez exactement les instructions vocales.',
    'aid_cpr_child': 'RCP enfant',
    'aid_cpr_child_summary':
        'Enfant inconscient qui ne respire pas normalement.',
    'aid_child_cpr_1':
        'Appelez les secours et suivez immédiatement les instructions de l’opérateur.',
    'aid_child_cpr_2':
        'Commencez la réanimation selon votre formation et les consignes reçues.',
    'aid_child_cpr_3':
        'Utilisez un DAE avec électrodes pédiatriques si disponible et suivez ses instructions.',
    'aid_cpr_infant': 'RCP nourrisson',
    'aid_cpr_infant_summary':
        'Nourrisson inconscient qui ne respire pas normalement.',
    'aid_infant_cpr_1':
        'Appelez les secours et placez le téléphone en haut-parleur.',
    'aid_infant_cpr_2':
        'Suivez les instructions spécifiques au nourrisson données par l’opérateur.',
    'aid_infant_cpr_3':
        'Poursuivez jusqu’à reprise de la respiration ou relais des secours.',
    'aid_trauma': 'Fracture ou traumatisme',
    'aid_trauma_summary': 'Douleur, déformation ou traumatisme important.',
    'aid_trauma_1': 'Ne déplacez pas la personne sauf danger immédiat.',
    'aid_trauma_2':
        'Soutenez la zone dans la position trouvée sans tenter de la remettre en place.',
    'aid_trauma_3':
        'Appelez les secours et surveillez respiration et conscience.',
    'aid_poisoning': 'Intoxication',
    'aid_poisoning_summary':
        'Ingestion, inhalation ou contact avec un produit toxique.',
    'aid_poisoning_1':
        'Éloignez la source sans vous exposer et aérez seulement si cela est sûr.',
    'aid_poisoning_2':
        'Appelez les secours ou le centre antipoison officiel; gardez l’emballage.',
    'aid_poisoning_3':
        'Ne faites pas vomir et ne donnez rien sans instruction professionnelle.',
    'aid_anaphylaxis': 'Réaction allergique grave',
    'aid_anaphylaxis_summary':
        'Difficulté respiratoire, gonflement ou malaise après une exposition.',
    'aid_anaphylaxis_1': 'Appelez immédiatement les secours.',
    'aid_anaphylaxis_2':
        'Aidez la personne à utiliser son auto-injecteur prescrit si elle en possède un.',
    'aid_anaphylaxis_3':
        'Surveillez respiration et conscience; préparez-vous à suivre les instructions de réanimation.',
    'aid_stroke': 'Suspicion d’AVC',
    'aid_stroke_summary':
        'Faiblesse du visage ou d’un bras, trouble soudain de la parole, de l’équilibre ou de la vision.',
    'aid_stroke_1':
        'Utilisez FAST : visage, bras, parole. Notez l’heure de début ou la dernière fois où la personne était normale.',
    'aid_stroke_2':
        'Appelez immédiatement les secours, même si les signes s’améliorent ou disparaissent.',
    'aid_stroke_3':
        'Installez la personne confortablement, ne lui donnez pas à manger ou boire et surveillez respiration et conscience.',
    'aid_chest_pain': 'Douleur thoracique',
    'aid_chest_pain_summary':
        'Pression, serrement ou douleur dans la poitrine, parfois vers le bras, la mâchoire, le cou ou le dos.',
    'aid_chest_pain_1':
        'Appelez immédiatement les secours si la douleur évoque une urgence cardiaque ou s’accompagne d’essoufflement, malaise ou sueurs.',
    'aid_chest_pain_2':
        'Aidez la personne à s’asseoir ou s’allonger confortablement et évitez tout effort.',
    'aid_chest_pain_3':
        'Surveillez la respiration et la conscience et suivez les instructions de l’opérateur des secours.',
    'aid_asthma': 'Crise d’asthme',
    'aid_asthma_summary':
        'Difficulté à respirer, sifflements ou oppression chez une personne asthmatique.',
    'aid_asthma_1':
        'Aidez la personne à s’asseoir et à utiliser son propre inhalateur de secours comme prescrit.',
    'aid_asthma_2':
        'Restez avec elle, rassurez-la et surveillez l’évolution de la respiration.',
    'aid_asthma_3':
        'Appelez les secours si la difficulté est sévère, s’aggrave, ne s’améliore pas rapidement ou si la personne s’épuise.',
    'aid_hypoglycemia': 'Hypoglycémie',
    'aid_hypoglycemia_summary':
        'Sueurs, tremblements, faiblesse ou confusion chez une personne pouvant manquer de sucre.',
    'aid_hypoglycemia_1':
        'Si la personne est réveillée et avale sans difficulté, donnez une source de sucre rapide adaptée.',
    'aid_hypoglycemia_2':
        'Surveillez-la et répétez la vérification selon son plan habituel ou les instructions professionnelles.',
    'aid_hypoglycemia_3':
        'Si elle est inconsciente, convulse ou ne peut pas avaler, ne donnez rien par la bouche et appelez les secours.',
    'home': 'Accueil',
    'more': 'Plus',
    'title': 'READYSAFE',
    'subtitle': 'Préparez-vous. Restez en sécurité.',
    'offline': 'Essentiel disponible hors connexion',
    'emergencies': 'Urgences',
    'firstAid': 'Premiers secours',
    'disasters': 'Catastrophes',
    'kit': 'Kit d’urgence',
    'checklists': 'Check-lists',
    'waterFood': 'Eau & nourriture',
    'family': 'Famille',
    'contacts': 'Contacts d’urgence',
    'maps': 'Cartes hors-ligne',
    'information': 'Informations',
    'settings': 'Paramètres',
    'continue': 'Continuer',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'close': 'Fermer',
    'save': 'Enregistrer',
    'delete': 'Supprimer',
    'download': 'Télécharger',
    'view': 'Consulter',
    'back': 'Retour',
    'welcome': 'Bienvenue dans ReadySafe',
    'choose_residence': 'Sélectionnez votre pays de résidence',
    'country_explanation':
        'Ce choix adapte les numéros et informations d’urgence. Il reste modifiable dans Paramètres.',
    'residence_country': 'Pays de résidence',
    'active_country': 'Pays actif',
    'travel_mode': 'Mode voyage',
    'travel_explanation':
        'Utilisez temporairement les informations d’un autre pays sans modifier votre résidence.',
    'disable_travel': 'Désactiver le mode voyage',
    'language': 'Langue',
    'french': 'Français',
    'english': 'English',
    'call': 'Appeler',
    'call_confirm_title': 'Confirmer l’appel',
    'call_confirm_body': 'Voulez-vous appeler le {number} ({service}) ?',
    'call_failed': 'Impossible d’ouvrir l’application Téléphone.',
    'official_sources': 'Sources officielles',
    'verified_on': 'Données vérifiées le {date}',
    'country_information': 'Informations locales',
    'emergency_hint':
        'En danger immédiat, mettez-vous en sécurité puis appelez les secours.',
    'medicalNotice':
        'Informations générales uniquement. ReadySafe ne remplace ni les services d’urgence, ni un professionnel de santé, ni une formation de secourisme. Suivez les instructions de l’opérateur.',
    'country_france': 'France',
    'country_belgium': 'Belgique',
    'country_germany': 'Allemagne',
    'country_italy': 'Italie',
    'country_albania': 'Albanie',
    'country_andorra': 'Andorre',
    'country_armenia': 'Arménie',
    'country_austria': 'Autriche',
    'country_azerbaijan': 'Azerbaïdjan',
    'country_belarus': 'Biélorussie',
    'country_bosnia': 'Bosnie-Herzégovine',
    'country_bulgaria': 'Bulgarie',
    'country_cyprus': 'Chypre',
    'country_croatia': 'Croatie',
    'country_denmark': 'Danemark',
    'country_spain': 'Espagne',
    'country_estonia': 'Estonie',
    'country_finland': 'Finlande',
    'country_georgia': 'Géorgie',
    'country_greece': 'Grèce',
    'country_hungary': 'Hongrie',
    'country_ireland': 'Irlande',
    'country_iceland': 'Islande',
    'country_kosovo': 'Kosovo',
    'country_latvia': 'Lettonie',
    'country_liechtenstein': 'Liechtenstein',
    'country_lithuania': 'Lituanie',
    'country_luxembourg': 'Luxembourg',
    'country_north_macedonia': 'Macédoine du Nord',
    'country_malta': 'Malte',
    'country_moldova': 'Moldavie',
    'country_monaco': 'Monaco',
    'country_montenegro': 'Monténégro',
    'country_norway': 'Norvège',
    'country_netherlands': 'Pays-Bas',
    'country_poland': 'Pologne',
    'country_portugal': 'Portugal',
    'country_czechia': 'République tchèque',
    'country_romania': 'Roumanie',
    'country_united_kingdom': 'Royaume-Uni',
    'country_san_marino': 'Saint-Marin',
    'country_serbia': 'Serbie',
    'country_slovakia': 'Slovaquie',
    'country_slovenia': 'Slovénie',
    'country_sweden': 'Suède',
    'country_switzerland': 'Suisse',
    'country_turkiye': 'Turquie',
    'country_ukraine': 'Ukraine',
    'country_vatican': 'Vatican',
    'service_emergency': 'Urgences européennes',
    'service_ambulance': 'Aide médicale urgente',
    'service_police': 'Police',
    'service_fire': 'Pompiers',
    'service_accessible': 'Urgence accessible',
    'service_112_desc': 'Numéro d’urgence européen',
    'service_samu_desc': 'SAMU — urgence médicale en France',
    'service_police_desc': 'Police ou gendarmerie en France',
    'service_fire_desc': 'Incendie et secours en France',
    'service_114_desc':
        'Urgences par SMS/app pour personnes sourdes ou malentendantes en France',
    'service_be_112_desc': 'Ambulance ou pompiers en Belgique',
    'service_be_police_desc': 'Police urgente en Belgique',
    'service_de_112_desc': 'Pompiers et secours médicaux en Allemagne',
    'service_de_police_desc': 'Police en Allemagne',
    'service_it_112_desc': 'Numéro unique d’urgence en Italie',
    'service_no_fire_desc': 'Pompiers et secours incendie en Norvège',
    'service_no_police_desc': 'Police d’urgence en Norvège',
    'service_no_ambulance_desc': 'Urgence médicale et ambulance en Norvège',
    'service_is_112_desc': 'Numéro national d’urgence en Islande',
    'service_tr_112_desc': 'Numéro unique d’urgence en Türkiye',
    'service_li_112_desc': 'Euro-Notruf au Liechtenstein',
    'service_li_police_desc': 'Police au Liechtenstein',
    'service_li_fire_desc': 'Pompiers au Liechtenstein',
    'service_li_ambulance_desc': 'Service de secours médical au Liechtenstein',
    'service_ch_ambulance_desc': 'Ambulance et urgence médicale en Suisse',
    'service_rega': 'Rega — sauvetage aérien',
    'service_rega_desc': 'Sauvetage aérien médicalisé en Suisse',
    'service_poison': 'Centre antipoison',
    'service_poison_desc': 'Tox Info Suisse — conseil urgent en cas d’intoxication',
    'service_adult_help': 'La Main Tendue',
    'service_adult_help_desc': 'Aide et écoute pour adultes en Suisse',
    'service_youth_help': 'Aide enfants et jeunes',
    'service_youth_help_desc': 'Conseil et aide pour enfants et jeunes en Suisse',
    'info_fr_alert':
        'En France, suivez FR-Alert et les consignes des autorités.',
    'info_be_112':
        'En Belgique, le 112 dessert ambulance et pompiers; le 101 dessert la police urgente.',
    'info_de_warning':
        'En Allemagne, utilisez le 112 pour les pompiers/secours et le 110 pour la police.',
    'info_it_112': 'En Italie, le 112 est le numéro unique d’urgence.',
    'info_eu_112': 'Le 112 est gratuit dans toute l’Union européenne.',
    'map_architecture': 'Packs de cartes hors-ligne',
    'map_installed': 'Installé et disponible hors connexion',
    'map_available': 'Disponible au téléchargement',
    'map_provider_missing':
        'Aucun fournisseur cartographique licencié n’est encore configuré. Aucun téléchargement n’a été effectué.',
    'map_policy':
        'ReadySafe est prêt pour des packs PMTiles/MBTiles fournis par un partenaire compatible OpenStreetMap. Le serveur public OSM ne sera jamais utilisé pour un téléchargement massif.',
    'map_unavailable': 'Pack indisponible',
    'map_license': 'Attribution : OpenStreetMap contributors',
    'step': 'Étape {number}',
    'illustration_pending':
        'Emplacement pour une illustration pédagogique originale ou sous licence compatible.',
    'aid_call_now':
        'Appelez immédiatement les secours si la personne ne respire pas normalement ou si sa vie est menacée.',
    'aid_cpr': 'RCP et DAE',
    'aid_cpr_summary': 'Personne inconsciente qui ne respire pas normalement.',
    'aid_cpr_1':
        'Appelez les secours, mettez le téléphone en haut-parleur et demandez un DAE.',
    'aid_cpr_2':
        'Commencez les compressions au centre de la poitrine et suivez le rythme indiqué par l’opérateur.',
    'aid_cpr_3':
        'Allumez le DAE, posez les électrodes et suivez exactement ses instructions.',
    'aid_choking_adult': 'Étouffement — adulte',
    'aid_choking_child': 'Étouffement — enfant',
    'aid_choking_infant': 'Étouffement — nourrisson',
    'aid_choking_summary':
        'La personne ne peut plus parler, tousser ou respirer.',
    'aid_choking_1':
        'Demandez si la personne s’étouffe et appelez les secours.',
    'aid_choking_2': 'Donnez jusqu’à 5 claques fermes entre les omoplates.',
    'aid_choking_3':
        'Si inefficace, alternez avec les gestes enseignés par les secours jusqu’à expulsion ou perte de connaissance.',
    'aid_choking_infant_summary':
        'Un nourrisson conscient ne peut plus pleurer, tousser ou respirer.',
    'aid_infant_1': 'Appelez les secours et soutenez la tête du nourrisson.',
    'aid_infant_2':
        'Donnez jusqu’à 5 claques dorsales, tête plus basse que le thorax.',
    'aid_infant_3':
        'Alternez avec 5 compressions thoraciques; jamais de poussée abdominale chez le nourrisson.',
    'aid_bleeding': 'Hémorragie',
    'aid_bleeding_summary': 'Saignement abondant ou qui ne s’arrête pas.',
    'aid_bleeding_1':
        'Protégez-vous si possible et exercez une pression directe ferme.',
    'aid_bleeding_2':
        'Appelez les secours et maintenez la pression sans retirer le premier pansement.',
    'aid_bleeding_3': 'Allongez, couvrez et surveillez la respiration.',
    'aid_burn': 'Brûlure',
    'aid_burn_summary': 'Brûlure thermique, chimique ou électrique.',
    'aid_burn_1': 'Éloignez la source sans vous mettre en danger.',
    'aid_burn_2':
        'Refroidissez à l’eau tempérée courante; suivez les consignes des secours.',
    'aid_burn_3':
        'Ne percez pas les cloques et n’appliquez ni glace ni corps gras.',
    'aid_unconscious': 'Inconscience et PLS',
    'aid_unconscious_summary':
        'La personne ne répond pas mais respire normalement.',
    'aid_unconscious_1':
        'Vérifiez la réponse et la respiration, puis appelez les secours.',
    'aid_unconscious_2':
        'Placez-la sur le côté si vous savez le faire et si aucun traumatisme majeur n’est suspecté.',
    'aid_unconscious_3':
        'Surveillez continuellement la respiration et gardez-la au chaud.',
    'aid_seizure': 'Convulsions',
    'aid_seizure_summary': 'Mouvements incontrôlés ou crise convulsive.',
    'aid_seizure_1':
        'Éloignez les objets dangereux et protégez la tête sans retenir la personne.',
    'aid_seizure_2': 'Ne mettez rien dans sa bouche et chronométrez la crise.',
    'aid_seizure_3':
        'Appelez les secours selon leurs critères, notamment si la crise dure ou se répète.',
    'aid_drowning': 'Noyade',
    'aid_drowning_summary':
        'Personne en difficulté dans l’eau ou sortie de l’eau.',
    'aid_drowning_1':
        'N’entrez pas dans l’eau si cela vous met en danger; alertez les secours.',
    'aid_drowning_2':
        'Une fois en sécurité, vérifiez respiration et conscience.',
    'aid_drowning_3':
        'Commencez la réanimation guidée si elle ne respire pas normalement.',
    'aid_hypothermia': 'Hypothermie',
    'aid_hypothermia_summary':
        'Refroidissement, confusion, somnolence ou frissons importants.',
    'aid_hypothermia_1':
        'Abritez la personne et retirez doucement les vêtements mouillés.',
    'aid_hypothermia_2':
        'Réchauffez progressivement avec des couches sèches; évitez chaleur directe et friction.',
    'aid_hypothermia_3':
        'Appelez les secours et surveillez respiration et conscience.',
    'aid_heatstroke': 'Coup de chaleur',
    'aid_heatstroke_summary':
        'Température élevée avec confusion, malaise ou perte de connaissance.',
    'aid_heatstroke_1':
        'Appelez immédiatement les secours et placez la personne au frais.',
    'aid_heatstroke_2':
        'Retirez les couches superflues et refroidissez rapidement.',
    'aid_heatstroke_3':
        'Ne donnez rien à boire si la personne est confuse ou inconsciente.',
  };

  static const Map<String, String> _en = {
    'adults': 'Adults',
    'children': 'Children',
    'days': 'Days',
    'water_result': 'Recommended water',
    'meal_result': 'Recommended meals',
    'calculator_estimate': 'Preparedness estimate',
    'calculator_note':
        'Adapt these estimates to health, climate, and local guidance.',
    'litres_for': '{litres} litres for {people} person(s) over {days} day(s)',
    'meals_for': 'Plan {meals} meals (3 per person per day)',
    'family_profile': 'Local family profile',
    'family_privacy':
        'Only save what helps prepare your household. No data is sent to a server.',
    'care_people': 'People requiring special attention',
    'pets': 'Pets',
    'save_local': 'Save locally',
    'saved_offline': 'Profile saved offline.',
    'items_ready': '{done} / {total} items ready',
    'do_now': 'Do now',
    'avoid': 'Avoid',
    'steps': 'Steps',
    'when_call': 'When to call emergency services',
    'when_evacuate': 'When to evacuate',
    'search_country': 'Search countries',
    'numbers_unverified': 'Unverified numbers',
    'service_unverified_desc':
        'No verified number is published for this country',
    'info_numbers_pending':
        'National numbers for this country are awaiting verification. ReadySafe offers no call action until an official source is validated.',
    'not_callable': 'Calling unavailable until the number is verified',
    'all_filter': 'All',
    'europe_filter': 'Europe',
    'downloaded_filter': 'Downloaded',
    'search_maps': 'Search map packs',
    'size_unknown': 'Size to be confirmed',
    'map_update': 'Update available',
    'map_downloading': 'Downloading',
    'pause': 'Pause',
    'resume': 'Resume',
    'verify': 'Verify',
    'illustration_ready': 'Offline ReadySafe teaching illustration',
    'aid_cpr_adult': 'Adult CPR',
    'aid_aed': 'Using an AED',
    'aid_aed_summary': 'An AED gives spoken instructions for every action.',
    'aid_aed_1': 'Ask for an AED while someone else calls emergency services.',
    'aid_aed_2': 'Turn on the AED and place pads exactly as shown.',
    'aid_aed_3': 'Stand clear during analysis and follow every spoken prompt.',
    'aid_cpr_child': 'Child CPR',
    'aid_cpr_child_summary':
        'An unconscious child who is not breathing normally.',
    'aid_child_cpr_1':
        'Call emergency services and immediately follow the operator’s directions.',
    'aid_child_cpr_2':
        'Start resuscitation according to your training and the instructions received.',
    'aid_child_cpr_3':
        'Use an AED with paediatric pads if available and follow its prompts.',
    'aid_cpr_infant': 'Infant CPR',
    'aid_cpr_infant_summary':
        'An unconscious infant who is not breathing normally.',
    'aid_infant_cpr_1': 'Call emergency services and use speakerphone.',
    'aid_infant_cpr_2': 'Follow the operator’s infant-specific instructions.',
    'aid_infant_cpr_3':
        'Continue until normal breathing returns or emergency services take over.',
    'aid_trauma': 'Fracture or trauma',
    'aid_trauma_summary': 'Pain, deformity, or significant trauma.',
    'aid_trauma_1': 'Do not move the person unless there is immediate danger.',
    'aid_trauma_2': 'Support the area as found and do not try to realign it.',
    'aid_trauma_3':
        'Call emergency services and monitor breathing and consciousness.',
    'aid_poisoning': 'Poisoning',
    'aid_poisoning_summary':
        'Ingestion, inhalation, or contact with a toxic product.',
    'aid_poisoning_1':
        'Move away from the source without exposing yourself; ventilate only if safe.',
    'aid_poisoning_2':
        'Call emergency services or the official poison centre and keep the packaging.',
    'aid_poisoning_3':
        'Do not induce vomiting or give anything unless instructed by a professional.',
    'aid_anaphylaxis': 'Severe allergic reaction',
    'aid_anaphylaxis_summary':
        'Breathing difficulty, swelling, or collapse after exposure.',
    'aid_anaphylaxis_1': 'Call emergency services immediately.',
    'aid_anaphylaxis_2':
        'Help the person use their prescribed auto-injector if they have one.',
    'aid_anaphylaxis_3':
        'Monitor breathing and consciousness and follow resuscitation instructions.',
    'aid_stroke': 'Suspected stroke',
    'aid_stroke_summary':
        'Sudden face or arm weakness, speech problems, balance problems, or vision changes.',
    'aid_stroke_1':
        'Use FAST: face, arm, speech. Note when symptoms started or when the person was last known well.',
    'aid_stroke_2':
        'Call emergency services immediately, even if symptoms improve or disappear.',
    'aid_stroke_3':
        'Keep the person comfortable, give nothing to eat or drink, and monitor breathing and responsiveness.',
    'aid_chest_pain': 'Chest pain',
    'aid_chest_pain_summary':
        'Pressure, squeezing, or pain in the chest that may spread to the arm, jaw, neck, or back.',
    'aid_chest_pain_1':
        'Call emergency services immediately if the pain suggests a heart emergency or comes with breathlessness, collapse, or sweating.',
    'aid_chest_pain_2':
        'Help the person sit or lie in a comfortable position and avoid exertion.',
    'aid_chest_pain_3':
        'Monitor breathing and responsiveness and follow the emergency operator’s instructions.',
    'aid_asthma': 'Asthma attack',
    'aid_asthma_summary':
        'Breathing difficulty, wheezing, or chest tightness in a person with asthma.',
    'aid_asthma_1':
        'Help the person sit upright and use their own reliever inhaler as prescribed.',
    'aid_asthma_2':
        'Stay with them, reassure them, and monitor their breathing.',
    'aid_asthma_3':
        'Call emergency services if breathing is severe, worsening, not improving quickly, or the person is becoming exhausted.',
    'aid_hypoglycemia': 'Low blood sugar',
    'aid_hypoglycemia_summary':
        'Sweating, shaking, weakness, or confusion in a person who may have low blood sugar.',
    'aid_hypoglycemia_1':
        'If the person is awake and can swallow safely, give a suitable fast-acting source of sugar.',
    'aid_hypoglycemia_2':
        'Monitor them and repeat checks according to their usual plan or professional instructions.',
    'aid_hypoglycemia_3':
        'If unconscious, having a seizure, or unable to swallow, give nothing by mouth and call emergency services.',
    'home': 'Home',
    'more': 'More',
    'title': 'READYSAFE',
    'subtitle': 'Be prepared. Stay safe.',
    'offline': 'Essential content available offline',
    'emergencies': 'Emergencies',
    'firstAid': 'First aid',
    'disasters': 'Disasters',
    'kit': 'Emergency kit',
    'checklists': 'Checklists',
    'waterFood': 'Water & food',
    'family': 'Family',
    'contacts': 'Emergency contacts',
    'maps': 'Offline maps',
    'information': 'Information',
    'settings': 'Settings',
    'continue': 'Continue',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'close': 'Close',
    'save': 'Save',
    'delete': 'Delete',
    'download': 'Download',
    'view': 'View',
    'back': 'Back',
    'welcome': 'Welcome to ReadySafe',
    'choose_residence': 'Select your country of residence',
    'country_explanation':
        'This adapts emergency numbers and information. You can change it later in Settings.',
    'residence_country': 'Country of residence',
    'active_country': 'Active country',
    'travel_mode': 'Travel mode',
    'travel_explanation':
        'Temporarily use another country without changing your residence.',
    'disable_travel': 'Disable travel mode',
    'language': 'Language',
    'french': 'Français',
    'english': 'English',
    'call': 'Call',
    'call_confirm_title': 'Confirm call',
    'call_confirm_body': 'Call {number} ({service})?',
    'call_failed': 'Unable to open the Phone app.',
    'official_sources': 'Official sources',
    'verified_on': 'Data verified on {date}',
    'country_information': 'Local information',
    'emergency_hint':
        'If in immediate danger, move to safety and call emergency services.',
    'medicalNotice':
        'General information only. ReadySafe does not replace emergency services, healthcare professionals, or first-aid training. Follow the operator’s instructions.',
    'country_france': 'France',
    'country_belgium': 'Belgium',
    'country_germany': 'Germany',
    'country_italy': 'Italy',
    'country_albania': 'Albania',
    'country_andorra': 'Andorra',
    'country_armenia': 'Armenia',
    'country_austria': 'Austria',
    'country_azerbaijan': 'Azerbaijan',
    'country_belarus': 'Belarus',
    'country_bosnia': 'Bosnia and Herzegovina',
    'country_bulgaria': 'Bulgaria',
    'country_cyprus': 'Cyprus',
    'country_croatia': 'Croatia',
    'country_denmark': 'Denmark',
    'country_spain': 'Spain',
    'country_estonia': 'Estonia',
    'country_finland': 'Finland',
    'country_georgia': 'Georgia',
    'country_greece': 'Greece',
    'country_hungary': 'Hungary',
    'country_ireland': 'Ireland',
    'country_iceland': 'Iceland',
    'country_kosovo': 'Kosovo',
    'country_latvia': 'Latvia',
    'country_liechtenstein': 'Liechtenstein',
    'country_lithuania': 'Lithuania',
    'country_luxembourg': 'Luxembourg',
    'country_north_macedonia': 'North Macedonia',
    'country_malta': 'Malta',
    'country_moldova': 'Moldova',
    'country_monaco': 'Monaco',
    'country_montenegro': 'Montenegro',
    'country_norway': 'Norway',
    'country_netherlands': 'Netherlands',
    'country_poland': 'Poland',
    'country_portugal': 'Portugal',
    'country_czechia': 'Czechia',
    'country_romania': 'Romania',
    'country_united_kingdom': 'United Kingdom',
    'country_san_marino': 'San Marino',
    'country_serbia': 'Serbia',
    'country_slovakia': 'Slovakia',
    'country_slovenia': 'Slovenia',
    'country_sweden': 'Sweden',
    'country_switzerland': 'Switzerland',
    'country_turkiye': 'Türkiye',
    'country_ukraine': 'Ukraine',
    'country_vatican': 'Vatican',
    'service_emergency': 'European emergency number',
    'service_ambulance': 'Emergency medical service',
    'service_police': 'Police',
    'service_fire': 'Fire brigade',
    'service_accessible': 'Accessible emergency service',
    'service_112_desc': 'European emergency number',
    'service_samu_desc': 'SAMU medical emergency in France',
    'service_police_desc': 'Police or gendarmerie in France',
    'service_fire_desc': 'Fire and rescue in France',
    'service_114_desc':
        'Emergency SMS/app for deaf or hard-of-hearing people in France',
    'service_be_112_desc': 'Ambulance or fire brigade in Belgium',
    'service_be_police_desc': 'Urgent police assistance in Belgium',
    'service_de_112_desc': 'Fire and medical rescue in Germany',
    'service_de_police_desc': 'Police in Germany',
    'service_it_112_desc': 'Single emergency number in Italy',
    'service_no_fire_desc': 'Fire and rescue emergency service in Norway',
    'service_no_police_desc': 'Police emergency service in Norway',
    'service_no_ambulance_desc': 'Medical emergency and ambulance service in Norway',
    'service_is_112_desc': 'National emergency number in Iceland',
    'service_tr_112_desc': 'Single emergency number in Türkiye',
    'service_li_112_desc': 'European emergency number in Liechtenstein',
    'service_li_police_desc': 'Police emergency service in Liechtenstein',
    'service_li_fire_desc': 'Fire brigade in Liechtenstein',
    'service_li_ambulance_desc': 'Emergency medical service in Liechtenstein',
    'service_ch_ambulance_desc': 'Ambulance and medical emergency service in Switzerland',
    'service_rega': 'Rega — air rescue',
    'service_rega_desc': 'Medical air rescue in Switzerland',
    'service_poison': 'Poison centre',
    'service_poison_desc': 'Tox Info Suisse — urgent poisoning advice',
    'service_adult_help': 'Adult support line',
    'service_adult_help_desc': 'Listening and support for adults in Switzerland',
    'service_youth_help': 'Children and youth support',
    'service_youth_help_desc': 'Advice and help for children and young people in Switzerland',
    'info_fr_alert': 'In France, follow FR-Alert and authority instructions.',
    'info_be_112':
        'In Belgium, 112 reaches ambulance/fire; 101 reaches urgent police.',
    'info_de_warning':
        'In Germany, use 112 for fire/medical rescue and 110 for police.',
    'info_it_112': 'In Italy, 112 is the single emergency number.',
    'info_eu_112': '112 is free throughout the European Union.',
    'map_architecture': 'Offline map packs',
    'map_installed': 'Installed and available offline',
    'map_available': 'Available to download',
    'map_provider_missing':
        'No licensed map provider is configured yet. Nothing has been downloaded.',
    'map_policy':
        'ReadySafe is prepared for PMTiles/MBTiles packs from an OpenStreetMap-compatible partner. Public OSM servers will never be used for bulk downloads.',
    'map_unavailable': 'Pack unavailable',
    'map_license': 'Attribution: OpenStreetMap contributors',
    'step': 'Step {number}',
    'illustration_pending':
        'Space for an original or commercially compatible licensed teaching illustration.',
    'aid_call_now':
        'Call emergency services immediately if the person is not breathing normally or their life is at risk.',
    'aid_cpr': 'CPR and AED',
    'aid_cpr_summary': 'An unresponsive person who is not breathing normally.',
    'aid_cpr_1':
        'Call emergency services, use speakerphone, and ask for an AED.',
    'aid_cpr_2':
        'Start chest compressions in the centre of the chest and follow the operator’s rhythm.',
    'aid_cpr_3':
        'Turn on the AED, attach the pads, and follow its prompts exactly.',
    'aid_choking_adult': 'Choking — adult',
    'aid_choking_child': 'Choking — child',
    'aid_choking_infant': 'Choking — infant',
    'aid_choking_summary': 'The person cannot speak, cough, or breathe.',
    'aid_choking_1':
        'Ask whether the person is choking and call emergency services.',
    'aid_choking_2': 'Give up to 5 firm blows between the shoulder blades.',
    'aid_choking_3':
        'If ineffective, follow the emergency operator’s directions until the object clears or consciousness is lost.',
    'aid_choking_infant_summary':
        'A conscious infant can no longer cry, cough, or breathe.',
    'aid_infant_1': 'Call emergency services and support the infant’s head.',
    'aid_infant_2':
        'Give up to 5 back blows with the head lower than the chest.',
    'aid_infant_3':
        'Alternate with 5 chest thrusts; never use abdominal thrusts on an infant.',
    'aid_bleeding': 'Severe bleeding',
    'aid_bleeding_summary': 'Heavy bleeding or bleeding that does not stop.',
    'aid_bleeding_1':
        'Protect yourself if possible and apply firm direct pressure.',
    'aid_bleeding_2':
        'Call emergency services and maintain pressure without removing the first dressing.',
    'aid_bleeding_3':
        'Lay the person down, keep them warm, and monitor breathing.',
    'aid_burn': 'Burn',
    'aid_burn_summary': 'Thermal, chemical, or electrical burn.',
    'aid_burn_1': 'Remove the source without putting yourself at risk.',
    'aid_burn_2':
        'Cool under cool running water and follow emergency instructions.',
    'aid_burn_3': 'Do not burst blisters or apply ice or grease.',
    'aid_unconscious': 'Unconsciousness and recovery position',
    'aid_unconscious_summary':
        'The person does not respond but is breathing normally.',
    'aid_unconscious_1':
        'Check response and breathing, then call emergency services.',
    'aid_unconscious_2':
        'Place them on their side if trained and no major trauma is suspected.',
    'aid_unconscious_3': 'Continuously monitor breathing and keep them warm.',
    'aid_seizure': 'Seizure',
    'aid_seizure_summary': 'Uncontrolled movements or a convulsive seizure.',
    'aid_seizure_1':
        'Move hazards away and protect the head without restraining the person.',
    'aid_seizure_2': 'Put nothing in their mouth and time the seizure.',
    'aid_seizure_3':
        'Call emergency services especially if it lasts or repeats.',
    'aid_drowning': 'Drowning',
    'aid_drowning_summary':
        'A person in difficulty in water or rescued from water.',
    'aid_drowning_1':
        'Do not enter the water if unsafe; alert emergency services.',
    'aid_drowning_2': 'Once safe, check breathing and consciousness.',
    'aid_drowning_3':
        'Start operator-guided resuscitation if they are not breathing normally.',
    'aid_hypothermia': 'Hypothermia',
    'aid_hypothermia_summary':
        'Cold exposure with confusion, drowsiness, or severe shivering.',
    'aid_hypothermia_1': 'Shelter the person and gently remove wet clothing.',
    'aid_hypothermia_2':
        'Warm gradually with dry layers; avoid direct heat and rubbing.',
    'aid_hypothermia_3':
        'Call emergency services and monitor breathing and consciousness.',
    'aid_heatstroke': 'Heatstroke',
    'aid_heatstroke_summary':
        'High temperature with confusion, collapse, or unconsciousness.',
    'aid_heatstroke_1':
        'Call emergency services immediately and move the person somewhere cool.',
    'aid_heatstroke_2': 'Remove excess layers and cool rapidly.',
    'aid_heatstroke_3':
        'Give nothing to drink if the person is confused or unconscious.',
  };

  String get(String key, [Map<String, String> params = const {}]) {
    var value =
        (locale.languageCode == 'en' ? _en : _fr)[key] ?? _fr[key] ?? key;
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  static const delegate = _Delegate();
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale locale) =>
      const ['fr', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);
  @override
  bool shouldReload(_Delegate old) => false;
}
