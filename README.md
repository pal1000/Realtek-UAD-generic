### Compatibility
This Realtek UAD driver mod should install and function properly on all systems supporting Realtek Legacy HDA FF00 drivers that don't rely on any special audio enhancements. If used with devices relying on special audio enhancements functionality and feature set available may be limited.
### Switching from other Realtek HD Audio drivers
Before installing my package you have to completely remove other Realtek HD Audio drivers regardless of being in classic HDA or UAD format because Windows favores hardware specific drivers with better hardware ID matching even if older than generic ones. Follow this procedure: 
1. download and extract my generic package;
2. download and extract [DriverStore Explorer](https://github.com/lostindark/DriverStoreExplorer/releases);

3a. if there is an entry in `Programs and Features` / `Apps & Features` put in there by Realtek official setup, use it to uninstall, but don't restart yet when prompted, minimize it as you'll be back to it later;

3b. if there is no such entry, run setup from my generic package until it asks to install the generic driver, answear with no as it's too early for it;

4. on start search for `Services` and open it as admin;
5. locate `Windows Audio` making sure it matches exactly, then do stop command on it;
6. when it's over close `Services`, then open `DriverStore Explorer - RAPR`;
7. look for entries under `Extensions`, `Software components` and `Sound, video and game controllers` driver classes with providder being `Realtek` or `Realtek Semiconductor Corp.` and carefully delete stuff related to Realtek Audio driver;

8a. if you used official setup to uninstall, disconnect from Internet and let it reboot the system;

9. run setup from my generic package to the end;

10a. if you used official setup you can now reconnect to Internet.

If step 3a applies to you, you'll have to perform 8a and 10a. Otherwisse they don't apply to you.
Step 8a and step 9 take care of restarting `Windows Audio` service for you, so don't worry about it.
### Note about system instability e.g. BSOD/GSOD
Just boot into safe mode minimal or with networking, safe with Command prompt is too restrictive. Setup will run and correct the problem.
### Project motivation
I have an old system that is not supported by OEM specific Realtek UAD drivers and I found HDA drivers to be very large, bloated and causing an unpleasant issue when equalizer was installed that was a pain to live with. Realtek UAD generic drivers were not affected so I permanently switched to them. But Realtek doesn't provide complete and official UAD generic drivers very often so I decided to custom craft it from parts since I discovered it is possible to do so without breaking WHQL signature.
### Repository contents
- source code of installer and updater used by this package;
- new release everytime official package that this mod is based on is updated on Realtek FTP server.
### How this package is built
- Download latest `{version}_UAD_RTK*.zip` or  `{version}_UAD_WHQL_RTK*.zip` whichever is the newer version from `ftp://spcust@ftp3.realtek.com/Realtek`; [1]
- Download and extract last available release;
- Extract `RTKVHD64.sys`and `RTAIODAT.DAT` from source codec folder, either `Win64` or `Win64\Realtek\Codec*` or `Realtek\Codec*` to `Realtek-UAD-generic\Win64\Realtek\UpdatedCodec` overwriting existing files; [1]
- Remove `RealtekAPO_*`, `RealtekHSA_*` and `RealtekService_*` folders from `Realtek-UAD-generic\Win64\Realtek`; [1]
- Extract `RealtekAPO_*`, `RealtekHSA_*` and `RealtekService_*` folders from RTK package located either under `Win64\Realtek` or `Realtek` folder to `Realtek-UAD-generic\Win64\Realtek`. [1]

Note [1]: `*` means any number or characters or both or absolutely nothing.
### Official installer
The MSI RTK package that this mod is most of time based off contains the official Realtek UAD installer. Unfortunately due to force updater being required with most releases, official Realtek UAD installer can't be included due to it and force updater being mutually incompatible.