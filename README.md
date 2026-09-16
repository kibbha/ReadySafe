# ReadySafe

ReadySafe est une application Flutter **offline-first** de préparation aux urgences pour les personnes et les familles. La V1 fournit des guides pratiques, un kit 72 h interactif, des check-lists persistantes, des calculateurs d’eau et de nourriture, et un profil familial local.

> Les fiches de premiers secours sont des informations générales : elles ne remplacent jamais les secours ou un professionnel de santé.

## Fonctionnalités V1
- Guides urgences et catastrophes : incendie, inondation, tempête, séisme, canicule, grand froid, coupures, évacuation et confinement.
- Fiches de premiers secours avec avertissement médical.
- Kit d’urgence 72 heures et check-lists de scénarios sauvegardés sur l’appareil.
- Calculateur eau/nourriture et profil familial local.
- Écrans préparés pour les contacts d’urgence et les cartes hors-ligne, sans téléchargement automatique.
- Interface française par défaut et fondations d’internationalisation FR/EN.

## Architecture
```
lib/
  app/          # application, thème et localisations
  core/         # extensions et utilitaires partagés (réservé)
  models/       # modèles métier
  services/     # stockage local et services futurs
  data/         # guides et données V1 embarquées
  screens/      # écrans de l’application
  widgets/      # composants visuels réutilisables
```

Les données utilisateur sont stockées localement avec `shared_preferences`. Aucun serveur n’est requis pour les fonctions essentielles disponibles en V1.

## Installation et lancement

```bash
flutter pub get
flutter run
```

Pré-requis : Flutter stable, Dart fourni par Flutter, JDK compatible et Android SDK configuré (`flutter doctor -v`).

## Qualité et tests

```bash
flutter analyze
flutter test
```

## Build Android

```bash
flutter build apk --release
flutter build appbundle --release
```

L’APK de release est produit sous `build/app/outputs/flutter-apk/app-release.apk`. Une signature de production doit être ajoutée via des secrets/variables hors dépôt avant publication Play Store.

## CI

Le workflow `.github/workflows/android.yml` installe Flutter stable, exécute l’analyse et les tests, construit l’APK, puis le publie comme artefact de workflow.

## Prochaines étapes

1. Ajouter une base de contenu médical revue par des professionnels et localisée.
2. Ajouter l’édition persistante et la numérotation locale des contacts d’urgence.
3. Intégrer des cartes régionales téléchargeables à la demande.
4. Ajouter rappels, expiration du kit et chiffrement si des données sensibles sont un jour nécessaires.
5. Étendre les traductions allemand, italien, espagnol et tagalog.

## V2 Europe

ReadySafe V2 demande au premier lancement un pays de résidence, stocké uniquement sur l’appareil. Le mode voyage applique temporairement les numéros et informations d’un autre pays sans remplacer la résidence. Le registre extensible associe chaque pays à ses langues, services, date de vérification et URL officielles.

Pays actuellement activés : France, Belgique, Allemagne et Italie. Les numéros publiés proviennent exclusivement des sources officielles enregistrées dans `lib/data/country_repository.dart`; tout nouveau pays doit fournir les mêmes métadonnées et faire l’objet d’une revue.

Les cartes utilisent une interface fournisseur indépendante conçue pour des packs PMTiles/MBTiles. La V2 n’embarque ni fournisseur commercial ni carte et ne contacte jamais le serveur public OpenStreetMap pour du téléchargement massif. L’interface indique donc explicitement qu’aucun pack n’est disponible tant qu’un catalogue licencié n’a pas été configuré.
