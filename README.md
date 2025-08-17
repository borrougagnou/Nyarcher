# Nyarcher
Nyarcher is a Shell script to install [Nyarch Linux](https://github.com/NyarchLinux/NyarchLinux) customizations on many Linux Distributions

## Disclaimer
The script aims to give the most similar experience to Nyarch Linux on multiple Linux distribution, without editing system files. For these reasons, read the [What you are missing section](#what-you-are-missing).
Also, some applications, specially Nyarch Scripts, might not work correctly in non arch-based distributions.
The only operations that are going to edit system files, are flagged with [SYSTEM]. They are not dangerous, but you better know that they are doing it.
If something goes wrong, by creating a new user on your distribution, you won't be affected by the changes that the script does, excluding the changes made by part of the script flagged as [SYSTEM].

## Test
The installer has been tested on the following systems:

|  **System**  | **Working** |         **Note**        |
|:------------:|:-----------:|:-----------------------:|
| Debian 12    |      ❌     | Gnome 43 not compatible |
| Debian 13    |      ✅     |                         |
| Ubuntu 22.04 |      ❌     | Gnome 46 not compatible |
| Ubuntu 22.10 |      ✅     |                         |
| Fedora 42    |      ✅     |                         |
| ArchLinux    |             |                         |


## Install pre-requirements
**On any distributions, a functional installation of Gnome 47 is required**

### Arch-based distributions
```bash
sudo pacman -S curl python-pip flatpak gnome-menus kitty wget git fastfetch npm nodejs pacman-contrib gnome-menus gnome-shell-extensions tar
sudo pacman -S cairo pkgconf
sudo pacman -S python-pywal
```
It is also suggested to install `webapp-manager` and `gnome-terminal-transparency` from the AUR.

### Fedora based distributions
```bash
sudo dnf install curl flatpak python3-pip svn gnome-menus kitty wget git fastfetch npm nodejs btop gnome-menus gnome-extensions-app
sudo dnf install gcc cairo-devel cairo-gobject-devel pkg-config python3-devel
sudo pip3 install pywal16 --break-system-packages
sudo cp /usr/local/bin/wal /usr/bin/wal
```
NOTE: wal must be located in /usr/bin/wal, which is the reason for the last command

### Ubuntu based distributions
```bash
sudo apt install curl python3-pip python3-venv pkg-config flatpak subversion gnome-menus kitty wget git fastfetch npm nodejs btop gnome-menus gnome-shell-extension-prefs
sudo apt install libcairo2-dev pkg-config python3-dev libgirepository-2.0-dev gettext # For gnome extensions customization
sudo pip3 install pywal16 --break-system-packages
sudo cp /usr/local/bin/wal /usr/bin/wal
```
NOTE: wal must be located in /usr/bin/wal, which is the reason for the last command

## Running the script 
If you want to know what the script does, you can read [NYARCHER.md](https://github.com/NyarchLinux/Nyarcher/blob/main/NYARCHER.md) file.
<br />
**NOTE: The script will backup most existing configurations before overwriting them. In addition, with the exception of /usr/bin/nyaofetch and /usr/bin/nekofetch, it only alters the settings for the current user.**
<br />
Download `nyarcher.sh`, add the execution rights to it, then run it
```bash
git clone https://github.com/NyarchLinux/Nyarcher.git
cd Nyarcher
chmod +x nyarcher.sh
./nyarcher.sh
```
The script will ask you if you want to apply specific settings. It is **strongly recommended that you accept all suggestions** in order to enjoy a stable experience.

## What you are missing
By running this script, you are not going to have the full Nyarch experience, here are the things that are missing from the script, but are present in the distro.
Note that almost any of those things can be integrated in any distribution, by running some commands or editing a few files.
- gnome-terminal-transparency is not installed by the script, it is a version of Gnome Terminal that implements transparency. Fedora users have it by default. You can install it from the [AUR](https://aur.archlinux.org/packages/gnome-terminal-transparency)
- Webapp manager is not installed by default, you can install it from the [AUR](https://aur.archlinux.org/packages/webapp-manager)
- plymouth (boot animation) is not installed by this script, and neither its theme. The installation of Plymouth is very specific to each distribution, [here is the wiki page for Arch Linux](https://wiki.archlinux.org/title/plymouth). The theme we use can be found [here](https://github.com/NyarchLinux/NyarchLinux/tree/main/Gnome/usr/share/plymouth/themes)
- The breeze to install Nyarch on your bare metal hoping it won't destroy your pc
- Calamares installation: Only available in the live ISO. This is an almost standard Calamares with the adwaita qt theme. Here you will find the [slides](https://github.com/NyarchLinux/NyarchLinux/tree/main/Gnome/etc/calamares/branding/ezarcher) that are displayed during installation.
- `yay`, installed by the script, is an AUR helper. You can install it with another AUR helper. Yay is also aliased as `nyay` because lol
- You will encounter some expected bugs that doesn't occur on Nyarch:
  - The Pywal theme will not be generated by default. To resolve this issue, reload the theme (by changing the colors in Nyarch Customize or simply changing the wallpaper if you have "material you" enabled). 
  - You have to log out and log back in after running the script
  - Nyarch Tour: It won't start after you log back in, just run it yourself
  - Nyarch updater: it is very likely that it will not work properly.
  - Material You: you might not be able to automatically apply the "Material You - Gnome Shell" theme without logging out/logging back in on some distributions (problem encountered on Fedora). No easy fix has been found yet. A workaround without logging out is to change the "Gnome Shell" theme in `gnome tweaks` (or in the extension settings) to another theme, then switch back to the “Material You” theme.
