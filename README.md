### Compatibility
This Realtek UAD driver mod should install and function properly on all systems supporting Realtek Legacy HDA FF00 drivers that don't rely on any special audio enhancements. If used with devices relying on special audio enhancements functionality and feature set available may be limited.
### Project motivation
I have an old system that is not supported by OEM specific Realtek UAD drivers and I found HDA drivers to be very large, bloated and causing an unpleasant issue when equalizer was installed that was a pain to live with. Realtek UAD generic drivers were not affected so I permanently switched to them. But Realtek doesn't provide complete and official UAD generic drivers very often so I decided to custom craft it from parts since I discovered it is possible to do so without breaking WHQL signature.
### Repository contents
- source code of installer and updater used by this package;
- new release everytime official package that this mod is based on is updated on Realtek FTP server.
### How this package is built
- Download latest `{version}_UAD_RTK*.zip` or  `{version}_UAD_WHQL_RTK*.zip` whichever is the newer version from `ftp://spcust@ftp3.realtek.com/Realtek`;
- Extract `RTKVHD64.sys`,`RTAIODAT.DAT` and `hdxrt.cat` to destination codec folder;
- Save [HDXRT.inf](https://raw.githubusercontent.com/alanfox2000/realtek-universal-audio-driver/master/UAD/Realtek/Codec_8787.1/HDXRT.inf) and [HDXRTSST.inf](https://raw.githubusercontent.com/alanfox2000/realtek-universal-audio-driver/master/UAD/Realtek/Codec_8787.1/HDXRTSST.inf) to target codec folder;
- Save [HDX_GenericExt_RTK.inf](https://raw.githubusercontent.com/alanfox2000/realtek-universal-audio-driver/master/UAD/Realtek/ExtRtk_8787.1/HDX_GenericExt_RTK.inf) and [hdxrtext.cat](https://raw.githubusercontent.com/alanfox2000/realtek-universal-audio-driver/master/UAD/Realtek/ExtRtk_8787.1/hdxrtext.cat) to target ExtRtk folder and adjust in `HDX_GenericExt_RTK.inf`, `DriverVer` value to match with 'HDX_MsiExt_RTK.inf` from the downloaded RTK package;
- Extract RealtekAPO, RealtekHSA and RealtekService folders from RTK package.
### Official installer
The MSI RTK package that this mod is most of time based off contains the official Realtek UAD installer. If you prefer it over my custom made open-source installer, move Win64 folder inside Official-Setup folder and run setup.exe as admin from there. Not all releases will have the official setup available.