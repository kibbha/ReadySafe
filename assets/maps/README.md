# ReadySafe offline maps

Runtime country packs are stored in the app documents directory after download, not bundled in the APK.

ReadySafe uses MapLibre Native and local PMTiles (`pmtiles://file://...`) for installed packs. A production manifest will provide HTTPS URLs, sizes, versions and SHA-256 checksums for licensed/generated country archives.

OpenStreetMap-derived packs must retain the required OpenStreetMap attribution and comply with the source data licence. Do not bulk-download public OSM raster tile servers.
