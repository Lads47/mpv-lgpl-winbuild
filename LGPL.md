# Pourquoi ce fork

Ce dépôt est un fork de [shinchiro/mpv-winbuild-cmake](https://github.com/shinchiro/mpv-winbuild-cmake)
qui produit un **libmpv LGPL**, pour [EVA Pilot](https://evadif.com) — un logiciel
de régie de diffusion propriétaire, édité par Les Ateliers du Stream.

Le dépôt d'origine ne publie que des builds **GPL** : ils contiennent x264 et
x265, qui n'existent que sous cette licence. Une bibliothèque GPL **chargée dans
le processus** d'un logiciel propriétaire vendu n'est pas tenable — d'où ce fork.

## Ce qui change, et rien d'autre

**`packages/mpv.cmake`**

    -Dgpl=false            option officielle de mpv (« GPL (version 2 or later)
                           build », vraie par défaut) → libmpv devient LGPLv2.1+
    -Djavascript=disabled  MuJS est AGPLv3 (ou commerciale)
    -Drubberband=disabled  librubberband est GPLv2+ (ou commerciale)
    -Ddvdnav=disabled      GPL, et sans objet ici

**`packages/ffmpeg.cmake`** — retrait de `--enable-gpl`, `--enable-version3`,
et des bibliothèques que le `configure` de FFmpeg range dans
`EXTERNAL_LIBRARY_GPL_LIST` : `avisynth`, `libdvdnav`, `libdvdread`,
`librubberband`, `libx264`, `libx265`.

## Ce que ça coûte : rien, pour cet usage

⭐ **x264 et x265 sont des ENCODEURS.** EVA Pilot ne réencode jamais : il lit. Les
décodeurs H.264 et HEVC sont natifs dans libavcodec, et **LGPL**.

Les fonctions que mpv écarte de lui-même à `-Dgpl=false` (cdda, dvbin, dvda,
dvdnav, jack, oss, caca, direct3d, x11) ne concernent pas Windows, sauf
`vo_direct3d` — et EVA Pilot rend en OpenGL.

## Vérifier le résultat

La DLL produite ne doit contenir **aucune trace de x264 ni de x265** :

    strings libmpv-2.dll | grep -E 'x264 - core|x264_encoder|x265'

Côté EVA Pilot, le même relevé est outillé : `tools/licence-moteur.ps1`.

## Mise à jour depuis l'amont

    git remote add upstream https://github.com/shinchiro/mpv-winbuild-cmake.git
    git fetch upstream && git rebase upstream/master

Les deux fichiers modifiés sont les seuls à surveiller.
