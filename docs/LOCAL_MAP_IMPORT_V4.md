# ReadySafe 4.0.0-dev.2 — Importer une carte PMTiles hors ligne

## Fonction ajoutée

Dans **Carte > Atlas régional hors ligne > Importer une carte PMTiles du téléphone**, sélectionner
un fichier PMTiles v3 contenant des couches vectorielles Protomaps basemap v4.
Le fichier est copié dans un répertoire privé de l'application, puis lu directement par
MapLibre Native, sans HTTP, API tierce, inscription ni serveur.

La fonction est destinée aux tests terrain ; elle ne fournit ni cartographie officielle,
ni itinéraire garanti, ni recherche d'adresse hors ligne. Elle est distincte du catalogue
de trois packs régionaux officiels ReadySafe, encore non publiés.

Les données PMTiles peuvent être produites depuis un extrait régional issu de données autorisées :

- https://docs.protomaps.com/guide/getting-started
- https://maps.protomaps.com/builds/
- https://docs.protomaps.com/basemaps/downloads

Exemple de préparation **depuis un ordinateur disposant de la CLI Protomaps** :

```sh
pmtiles extract https://build.protomaps.com/20261012.pmtiles \
  Leman-test.pmtiles --bbox=5.9,46.0,6.5,46.5 --maxzoom=14
pmtiles verify Leman-test.pmtiles
```

La disponibilité de cet ancien build n'est pas garantie. Choisir un build daté
encore disponible et respecter les conditions de source/d'attribution.
Copier le fichier `.pmtiles` sur Android et l'ouvrir via le sélecteur de fichiers
ReadySafe. En mode avion, le fond de carte est lu depuis le stockage privé.

## Validation technique

Le service exige : PMTiles version 3, type MVT vectoriel, format de métadonnées
connu (sans compression ou gzip), présence des couches `roads`, `water`,
`landuse` et `pois`, coordonnées et sections du conteneur cohérentes.
Il refuse les sections hors fichier, les archives trop volumineuses et
les métadonnées qui décompressent au-delà de 1 Mio.

La copie se fait en flux, avec une limite **250 Mio/fichier** et **4 cartes**,
puis un SHA-256 est calculé sur les octets enregistrés. À chaque ouverture,
le fichier est relu et comparé à l'empreinte locale. Ceci détecte un fichier
corrompu ou modifié, **sans attester son origine, sa licence ou sa justesse**.

Les segments GPX locaux peuvent être superposés ; ils restent également
des données non vérifiées. Les cartes n'ont pas de polices/glyphes distants.
Aucun transfert des cartes utilisateur vers un serveur n'est effectué.

## À tester sur Android

1. Sélectionner une vraie carte Protomaps v4 de moins de 250 Mio.
2. Contrôler qu'elle apparaît dans « Cartes enregistrées ».
3. Ouvrir et examiner routes, chemins, eau et surfaces sur plusieurs zooms.
4. Activer le mode avion, fermer l'application puis rouvrir la carte.
5. Comparer le rendu avec une carte de référence : **absence de relief et de noms**.
6. Ajouter un parcours GPX ; vérifier la superposition sur carte locale.
7. Rejeter un mauvais fichier, une archive tronquée ou un doublon.
8. Supprimer la copie ReadySafe et vérifier que l'original n'est pas supprimé.

Aucune validation terrain ne peut être supposée à partir des seuls tests unitaires.

## Carte pilote Genève–Meyrin, fabrication automatisée

Le workflow `.github/workflows/readysafe-geneva-map-pilot.yml` prépare sur GitHub
Actions un extrait **vérifiable** du fond Protomaps v4, zone
`5.95,46.10,6.26,46.31`, zoom maximum 14.

La source de départ est volontairement datée :
`https://build.protomaps.com/20261012.pmtiles`. Ce serveur peut retirer
l'archive : l'extraction échoue alors sans publier de carte fictive.

L'artefact contient le fichier `.pmtiles`, son SHA-256, la provenance et
un mode d'emploi. Une fois l'APK V4 installée, il suffit de copier cet
extrait sur Android et de l'importer dans le nouvel écran local.
Il ne comprend **pas** de relief, ne certifie pas les sentiers et ne
constitue pas encore le grand pack Arc lémanique prévu.
