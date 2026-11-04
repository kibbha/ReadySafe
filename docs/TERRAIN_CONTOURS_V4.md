# ReadySafe V4 — Relief et sentiers hors ligne

**Branche :** `feature/survival-atlas-offline-v4`.
**État :** moteur et outils de préparation intégrés au code. Aucun pack cartographique
complet ni pack de courbes de niveau n'est encore hébergé ou installable.
Cette fonction n'a pas été compilée ni testée sur appareil.

## Affichage cartographique local

`RegionalTerrainStyle` produit une spécification MapLibre GL JS style v8
**entièrement autonome** : les seules sources autorisées sont des URL
`pmtiles://file:///...`, sans glyphes, sprites ou ressources Internet.

Le rendu adapté aux données **Protomaps basemap v4** comprend :

- Fond clair, forêts, prairies, rochers, glaciers et zones humides.
- Plans d'eau et cours d'eau.
- Grandes routes, routes secondaires, chemins piétons et pistes (styles différenciés).
- Bâtiments et points communautaires OSM d'abri, de camping et d'eau.
- Traces GPX sauvegardées dans ReadySafe, superposées sans connexion.
- **Courbes de niveau optionnelles** si (et seulement si) une archive PMTiles
  de relief approuvée, rattachée à la même région et validée par sa taille
  et son SHA-256 est effectivement installée.

La carte conserve les sources de données visibles dans son attribution.
Il n'y a pas de noms de lieux en mode local pour l'instant : les polices
glyphes et leurs licences doivent encore être ajoutées hors ligne.

## Provenance réelle du relief suisse : swissALTI3D

Documentation officielle : https://www.swisstopo.admin.ch/en/height-model-swissalti3d

Les fichiers swissALTI3D proviennent de l'**Office fédéral de topographie
swisstopo**. Les jeux de données OGD officiels peuvent être réutilisés,
transformés et redistribués, y compris commercialement, avec une attribution
appropriée (par exemple « © swisstopo ») :

- https://www.swisstopo.admin.ch/en/terms-of-use-free-geodata-and-geoservices
- https://www.swisstopo.admin.ch/en/faq-free-geodata

**Important :** les fichiers d'exemple téléchargeables comme « sample data »
sont autorisés uniquement pour les tests et ne doivent pas être inclus dans
un produit. Utiliser des dalles officielles OGD, pas les échantillons.

swissALTI3D est distribué notamment en COG GeoTIFF 2 m (environ 1 Mo par
dalle de 1 km²) et 0,5 m (environ 26 Mo par dalle).
Le jeu national brut peut atteindre des dizaines ou centaines de Go.
Il faut donc sélectionner les dalles officielles nécessaires à la région
et les rééchantillonner avant de produire un pack mobile.

## Préparer des courbes de niveau 20 m — commande volontaire

Après avoir obtenu un **GeoTIFF officiel déjà découpé sur la région** et
relevé sa provenance, installer GDAL (avec `gdalwarp`, `gdal_contour`,
`ogr2ogr`), Tippecanoe, la CLI PMTiles et Python 3.

```bash
bash tools/prepare_swiss_contours.sh ch-leman ./swissalti-leman-clip.tif
```

Ou pour les Alpes suisses :

```bash
bash tools/prepare_swiss_contours.sh ch-alpes ./swissalti-alpes-clip.tif
```

Le script :
1. Reprojette l'altitude en EPSG:3857 sur une grille de 20 m.
2. Génère des isolignes espacées de 20 m, avec champ numérique
   `elevation`.
3. Reprojette les lignes en WGS84/EPSG:4326.
4. Construit des tuiles vectorielles PMTiles v3 contenant le
   `source-layer: contours`, zooms 10 à 15.
5. Vérifie le conteneur PMTiles, mesure la taille et calcule le SHA-256.
6. Produit un fichier `.candidate.json` dont `approved` vaut **false**.

Il ne télécharge **aucune donnée**, n'héberge aucun fichier et n'active
aucun pack dans l'application. Le fichier n'est pas importé dans l'APK.
Un jeu massif de plusieurs cantons doit être préparé par lots, pas
transformé d'une seule commande sur une tablette.

Pour les Alpes françaises, **ne pas utiliser les données suisses comme
substitut**. La source du modèle d'altitude français, sa licence et ses
conditions de redistribution doivent être vérifiées séparément.

## Intégration dans le catalogue

Le catalogue possède désormais deux listes différentes :

- `packs` : fond Protomaps v4 régional.
- `contour_packs` : courbes de niveau `readysafe-contours-v1` avec
  `parent_map_id` correspondant au fond régional.

Les trois fonds régionaux et leurs trois jeux de courbes sont
**désactivés**, sans URL approuvée et sans empreinte SHA-256.
Une archive de relief ne peut pas être affichée si son parent, son
schéma de données ou son intégrité ne correspondent pas.

Avant tout lancement, le manifeste devra contenir une URL HTTPS
immuable, la taille exacte, l'empreinte SHA-256 calculée sur le fichier
hébergé, la source, la version des données, les mentions et licences
applicables, puis l'approbation explicite après tests. La présence du
fichier `.pmtiles` ne prouve pas à elle seule sa qualité topographique.

## Tests

```bash
flutter pub get
flutter analyze
flutter test test/regional_terrain_style_test.dart
flutter test test/regional_map_pack_test.dart
flutter test
```

Tests terrain indispensables : extrait GPS réel, affichage du relief à
différentes échelles, redémarrage du téléphone en mode avion,
comparaison avec une carte topographique de référence, détection de
fichiers corrompus, attribution des données, batterie, stockage et
rendu sur smartphone/tablette.

Une courbe de niveau n'indique pas les éboulements récents, la neige,
l'état des sentiers, la météo ou le risque d'avalanche.
Un point OSM « drinking_water » n'est pas une preuve que l'eau est potable.
Le calcul d'itinéraires hors ligne et la recherche de lieux restent à
développer indépendamment.

## Références techniques

- Schéma des couches Protomaps v4 : https://docs.protomaps.com/basemaps/layers
- PMTiles et MapLibre : https://docs.protomaps.com/pmtiles/maplibre
- Création de PMTiles avec Tippecanoe : https://docs.protomaps.com/pmtiles/create
- Conditions d'utilisation swisstopo : https://www.swisstopo.admin.ch/en/terms-of-use-free-geodata-and-geoservices
