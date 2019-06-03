### Compatibility
This Realtek UAD driver mod should install and function properly on all systems supporting Realtek Legacy HDA FF00 drivers.
### Project motivation
I have an old system that is not supported by OEM specific Realtek UAD drivers and I found HDA drivers to be very large, bloated and causing an unpleasant issue when equalizer was installed that was a pain to live with. Realtek UAD generic drivers were not affected so I permanently switched to them.  But Realtek hasn't provided a complete and official UAD generic driver in a long time so I decided to custom craft it from parts since I discovered it is possible to do so without breaking WHQL signature.
### Repository contents
- source code of installer and updater used by this package;
- new release everytime official package that this mod is based on is updated on Realtek FTP server.
### How this package is built
- Download latest `{version}-UAD-Nahimic*.zip` or  `{version}-UAD-WHQL-Nahimic*.zip` whichever is the newer version from `ftp://spcust@ftp3.realtek.com/Realtek`;
- Extract `RTKVHD64.sys`,`RTAIODAT.DAT`,`HDXRT.inf` and `hdxrt.cat` to codec folder;
- Extract `hdxrtext.cat` from ExtRtk folder to codec folder;
- Save [HDX_GenericExt_RTK.inf](https://github.com/alanfox2000/realtek-universal-audio-driver/raw/master/UAD/Realtek/ExtRtk_8716.1_DUA/HDX_GenericExt_RTK.inf) to Codec folder;
- Replace `DriverVer` value from `HDX_GenericExt_RTK.inf` with the one copied from `hdxrt.inf`;
- Extract RealtekAPO, RealtekHSA and RealtekService folders from Nahimic package.
