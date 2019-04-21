### Compatibility
This Realtek UAD driver mod should install and function properly on all systems supporting Realtek Legacy HDA FF00 drivers.
### Project motivation
I have an old system that is not supported by OEM specific Realtek UAD drivers and I found HDA drivers to be very large, bloated and causing an unpleasant issue when equalizer was installed that was a pain to live with. Realtek UAD generic drivers were not affected so I permanently switched to them.  But Realtek hasn't provided complete and official Realtek UAD generic driver since 6.0.1.8614 so I decided to custom craft it from parts since I discovered it is possible to do so without breaking WHQL signature.
### Repository contents
- source code of installer and updater used by this package;
- new release everytime official package that this mod is based on is updated on Realtek FTP server.
### How this package is built
- Download latest `{version}-UAD-Nahimic*.zip` or  `{version}-UAD-WHQL-Nahimic*.zip` whichever is the newer version from `ftp://spcust@ftp3.realtek.com/Realtek`;
- Extract `RTKVHD64.sys`,`RTAIODAT.DAT`,`HDXRT.inf` and `hdxrt.cat` from source codec folder to destination codec folder;
- Extract `hdxrtext.cat` from extension folder to codec folder (we merge codec and extension folders for convencience);
- Copy date and version from the .inf file present in extension folder;
- Grab latest copy of [HDX_GenericExt_RTK.inf](https://github.com/alanfox2000/realtek-universal-audio-driver/blob/master/UAD/Realtek/CodecExtOem_RTK_8614/HDX_GenericExt_RTK.inf) and save it to Codec folder;
- Modify date and version in `HDX_GenericExt_RTK.inf` with what was copied before;
- Extract hsa, apo and service folders.
