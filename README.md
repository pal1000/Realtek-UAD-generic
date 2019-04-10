# Premise
In response to the fact that there hasn't been a complete and official Realtek UAD generic driver since 6.0.1.8614 I decided to custom make it from parts since it is possible to do without breaking WHQL signature.

This repository contains the following:
- source code of the installer and updater used by this package;
- new release everytime official base package '{version}-UAD-Nahimic*.zip` is updated on Realtek FTP server.

# How this package is built
- Download latest `{version}-UAD-Nahimic*.zip` from `ftp://ftp3.realtek.com/Realtek`;
- Extract `RTKVHD64.sys`,`RTAIODAT.DAT`,`HDXRT.inf` and `hdxrt.cat` from source codec folder to destination codec folder;
- Extract `hdxrtext.cat` from extension folder to codec folder (we merge codec and extension folders for convencience);
- Copy date and version from the .inf file present in extension folder;
- Grab latest copy of [HDX_GenericExt_RTK.inf](https://github.com/alanfox2000/realtek-universal-audio-driver/blob/master/UAD/Realtek/CodecExtOem_RTK_8614/HDX_GenericExt_RTK.inf) and save it to Codec folder;
- Modify date and version in `HDX_GenericExt_RTK.inf` with what was copied before;
- Extract hsa, apo and service folders.
