#!/bin/bash

LATEST_TAG_VERSION=`curl -s https://api.github.com/repos/NyarchLinux/NyarchLinux/releases/latest | grep "tag_name" | awk -F'"' '/tag_name/ {print $4}'`
RELEASE_LINK="https://github.com/NyarchLinux/NyarchLinux/releases/download/$LATEST_TAG_VERSION"
TAG_PATH="https://raw.githubusercontent.com/NyarchLinux/NyarchLinux/refs/tags/$LATEST_TAG_VERSION/Gnome"
TMP_FOLDER="/tmp/nyarchinstall" ### PLEASE DO NOT USE /tmp !!
DATE_TODAY=`date +"%Y%m%d-%H%M%S"`

RED='\033[0;31m'
NC='\033[0m'

curl https://raw.githubusercontent.com/NyarchLinux/NyarchLinux/main/Gnome/etc/skel/.config/neofetch/ascii70
echo -e "$RED\n\nWelcome to Nyarch Linux customization installer! $NC"


check_gnome_version() {
  GNOME_VERSION=`gnome-session --version`
  GNOME_VERSION_NUMBER=${GNOME_VERSION##* }
  GNOME_VERSION_MAJOR=${GNOME_VERSION_NUMBER%%.*}
  if [ "$GNOME_VERSION_MAJOR" -lt 47 ]; then
    echo "You need Gnome version 47 or above."
    exit
  fi
}

check_gnome_is_running() {
  local CURRENT_ENV=${XDG_CURRENT_DESKTOP,,}
  if [[ $CURRENT_ENV != *"gnome"* ]]; then
    echo "Gnome isn't running, please launch gnome environment first"
    exit
  fi
}

get_tarball() {
    #just a tar archive, no gzip compression, wrong extention
    local file_path=${TMP_FOLDER}/NyarchLinux.tar.gz
    local url=${RELEASE_LINK}/NyarchLinux.tar.gz

    if [ ! -f "$file_path" ]; then
        echo "Downloading Nyarch tarball from $url"
        wget -q -O "$file_path" "$url"
        cd ${TMP_FOLDER}
        tar -xf ${TMP_FOLDER}/NyarchLinux.tar.gz
    else
        echo "Using cached Nyarch tarball"
    fi
}

install_extensions () {
  local GNOME_SHELL_FOLDER="$HOME/.local/share/gnome-shell"
  check_gnome_version
  check_gnome_is_running

  # Backup Gnome extensions config folder
  if [ -d "${GNOME_SHELL_FOLDER}/extensions" ]; then
    echo "Backup old extensions to extensions-backup-$DATE_TODAY..."
    mv "${GNOME_SHELL_FOLDER}/extensions" "${GNOME_SHELL_FOLDER}/extensions-backup-${DATE_TODAY}"  # Backup old extensions 
  fi

  get_tarball
  mkdir -p ${GNOME_SHELL_FOLDER}/extensions
  cp -rf ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/skel/.local/share/gnome-shell/extensions ${GNOME_SHELL_FOLDER}
  
  # Install material you
  git clone https://github.com/FrancescoCaracciolo/material-you-colors.git ${TMP_FOLDER}/material-you-colors
  cd ${TMP_FOLDER}/material-you-colors
  make build
  make install
  npm install --prefix ${GNOME_SHELL_FOLDER}/extensions/material-you-colors@francescocaracciolo.github.io;

  rm -rf "${GNOME_SHELL_FOLDER}/extensions/material-you-colors@francescocaracciolo.github.io/adwaita-material-you" # if the folder exist
  git clone https://github.com/francescocaracciolo/adwaita-material-you "${GNOME_SHELL_FOLDER}/extensions/material-you-colors@francescocaracciolo.github.io/adwaita-material-you"
  cd "${GNOME_SHELL_FOLDER}/extensions/material-you-colors@francescocaracciolo.github.io/adwaita-material-you"
  bash local-install.sh
  
  # Install material you icons 
  cp -rf ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/skel/.config/nyarch $HOME/.config
  rm -rf $HOME/.config/nyarch/Tela-circle-icon-theme
  git clone https://github.com/vinceliuice/Tela-circle-icon-theme $HOME/.config/nyarch/Tela-circle-icon-theme
}

install_nyaofetch() {
  # Download scripts
  sudo wget ${TAG_PATH}/usr/local/bin/nekofetch -O /usr/bin/nekofetch
  sudo wget ${TAG_PATH}/usr/local/bin/nyaofetch -O /usr/bin/nyaofetch
  # Give the user execution permissions
  sudo chmod +x /usr/bin/nekofetch
  sudo chmod +x /usr/bin/nyaofetch
}

configure_neofetch() {
  if [ -d "$HOME/.config/fastfetch" ]; then
    echo "Backup old fastfetch folder to fastfetch-backup-$DATE_TODAY"
    mv $HOME/.config/fastfetch fastfetch-backup-$DATE_TODAY
  fi

  # Install new fastfetch files
  get_tarball
  cp -rf ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/skel/.config/fastfetch $HOME/.config
}

download_wallpapers() {
  local file_path=${TMP_FOLDER}/wallpaper
  local url=${RELEASE_LINK}/wallpaper.tar.gz

  mkdir -p $file_path
  wget -q -O "$file_path/wallpaper.tar.gz" "$url"
  cd $file_path
  tar -zxf $file_path/wallpaper.tar.gz
  bash install.sh
}

# TODO CONTINUE
download_icons() {
  local file_path=${TMP_FOLDER}/icons
  local url=${RELEASE_LINK}/icons.tar.gz

  mkdir -p $file_path
  mkdir -p $HOME/.local/share/icons/Tela-circle-MaterialYou
  wget -q -O "$file_path/icons.tar.gz" "$url"
  cd $file_path
  tar -zxf $file_path/icons.tar.gz
  cp -rf Tela-circle-MaterialYou*/* $HOME/.local/share/icons/Tela-circle-MaterialYou
}

set_themes() {
  if [ -d "$HOME/.local/share/themes" ]; then
    echo "Backup old themes folder to themes-backup-$DATE_TODAY"
    mv "$HOME/.local/share/themes" "$HOME/.local/share/themes-backup-$DATE_TODAY"
  fi

  if [ -d "$HOME/.config/gtk-3.0" ]; then
    echo "Backup old gtk-3.0 folder to gtk-3.0-backup-$DATE_TODAY"
    mv $HOME/.config/gtk-3.0 gtk-3.0-backup-$DATE_TODAY
  fi

  if [ -d "$HOME/.config/gtk-4.0" ]; then
    echo "Backup old gtk-4.0 folder to gtk-4.0-backup-$DATE_TODAY"
    mv $HOME/.config/gtk-4.0 gtk-4.0-backup-$DATE_TODAY
  fi

  get_tarball
  cp -rf ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/skel/.local/share/themes $HOME/.local/share
  # Set GTK4 and GTK3 themes
  cp -rf ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/skel/.config/gtk-3.0 $HOME/.config
  cp -rf ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/skel/.config/gtk-4.0 $HOME/.config
}

configure_kitty (){
  mkdir -p $HOME/.config/kitty
  if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
    echo "Backup old kitty.conf to kitty-backup-$DATE_TODAY"
    mv "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty-backup-$DATE_TODAY.conf"
  fi

  wget ${TAG_PATH}/etc/skel/.config/kitty/kitty.conf -O $HOME/.config/kitty/kitty.conf
}


flatpak_overrides() {
  sudo flatpak override --filesystem=xdg-config/gtk-3.0
  sudo flatpak override --filesystem=xdg-config/gtk-4.0
}


install_flatpaks() {
  # Add flathub
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-modify --enable flathub
  # Themes
  flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
  # Komikku
  flatpak install flathub info.febvre.Komikku
  # Flatseal
  flatpak install flathub com.github.tchx84.Flatseal
  # Shortwave
  flatpak install flathub de.haeckerfelix.Shortwave
  # Lollypop
  flatpak install flathub org.gnome.Lollypop
  # Fragments
  flatpak install flathub de.haeckerfelix.Fragments
  # Flatseal
  flatpak install flathub com.github.tchx84.Flatseal
  # Extension Manager
  flatpak install flathub com.mattjakeman.ExtensionManager
  # GearLever
  flatpak install flathub it.mijorus.gearlever
}

install_nyarch_apps() {
  # Install latest release of CatgirlDownloader through flatpak bundle
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/CatgirlDownloader/releases/latest/download/catgirldownloader.flatpak
  flatpak install catgirldownloader.flatpak

  # Install latest release of NyarchWizard through flatpak bundle
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/NyarchWizard/releases/latest/download/wizard.flatpak
  flatpak install wizard.flatpak

  # Install latest release of NyarchTour through flatpak bundle
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/NyarchTour/releases/latest/download/nyarchtour.flatpak
  flatpak install nyarchtour.flatpak

  # Install latest release of NyarchCustomize
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/NyarchCustomize/releases/latest/download/nyarchcustomize.flatpak
  flatpak install nyarchcustomize.flatpak
 
  # Install Nyarch Scripts
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/NyarchScript/releases/latest/download/nyarchscript.flatpak
  flatpak install nyarchscript.flatpak

  # Install Waifu Downloader
  cd ${TMP_FOLDER} 
  wget https://github.com/NyarchLinux/WaifuDownloader/releases/latest/download/waifudownloader.flatpak
  flatpak install waifudownloader.flatpak
  
}

install_nyarch_assistant() {
  # Install Nyarch Assistant
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/NyarchAssistant/releases/latest/download/nyarchassistant.flatpak
  flatpak install nyarchassistant.flatpak
}

install_nyarch_updater() {
  # Install Nyarch Updater
  cd ${TMP_FOLDER}
  wget https://github.com/NyarchLinux/NyarchUpdater/releases/latest/download/nyarchupdater.flatpak
  flatpak install nyarchupdater.flatpak
  sudo bash -c 'echo 20250801 > /version'
}

configure_gsettings() {
  check_gnome_version
  check_gnome_is_running
  dconf dump / > ~/dconf-backup.txt  # Save old gnome settings
  cd ${TMP_FOLDER}
  # Download default settings
  get_tarball
  cd ${TMP_FOLDER}/NyarchLinuxComp/Gnome/etc/dconf/db/local.d
  # Load settings
  dconf load / < 06-extensions  # Load extensions settings
  dconf load / < 02-interface  # Load theme settings
  dconf load / < 04-wmpreferences  # Add minimize button
  sed -i '/picture-uri=/d' ./03-background
  sed -i '/picture-uri-dark=/d' ./03-background
  dconf load / < 03-background  # Set gnome terminal and background settings
}

add_pywal() {
echo 'if [[ -f "$HOME/.cache/wal/sequences" ]]; then' >> ~/.bashrc
echo '    (cat $HOME/.cache/wal/sequences)' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
}


## EXECUTION PART

rm -rf $TMP_FOLDER/*
mkdir -p $TMP_FOLDER
check_gnome_version
check_gnome_is_running

read -r -p "Have you installed all the dependecies listed in the github page of this script? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  echo Cool! We can go ahead
else
  echo You need to have already installed the dependencies listed on github before running this script!
  exit
fi

read -r -p "Do you want to install our Gnome extensions, they are important for the overall desktop customization? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  install_extensions
  echo "Gnome extensions installed!"
fi
read -r -p "[SYSTEM] Do you want to install Nekofetch and Nyaofetch and configure neofetch, to tell everyone that you use nyarch btw? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  install_nyaofetch
  configure_neofetch
  echo "Nyaofetch and Neofetch installed!"
fi
read -r -p "Download Nyarch wallpapers? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  download_wallpapers
  echo "Wallpapers downloaded!"
fi
read -r -p "Do you want to download our icons? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  download_icons
  echo "Icons downloaded!"
fi
read -r -p "Do you want to download our themes? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  set_themes
  echo "Themes downloaded!"
fi
read -r -p "Do you want to apply our customizations to kitty terminal? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  configure_kitty
  echo "Kitty configured!"
fi
read -r -p "Do you want to add pywal theming to your ~/.bashrc (for other shells you have to do it manually)? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  add_pywal
  echo "pywal configured!"
fi
read -r -p "Do you want to apply your GTK themes to flatpak apps? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  flatpak_overrides
  echo "Flatpak themes configured!"
fi
read -r -p "Do you want to install suggested flatpaks to enhance your weebflow (You will be able to not download only some of them)? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  install_flatpaks
  echo "Suggested apps installed!"
fi
read -r -p "[SYSTEM] Do you want to install Nyarch Exclusive applications? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  install_nyarch_apps
  echo "Nyarch apps installed!"
fi
read -r -p "[SYSTEM] Do you want to install Nyarch Assistant, our Waifu AI Assistant? (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then 
  install_nyarch_assistant
  echo "Nyarch Assistant installed!"
fi 
read -r -p "[SYSTEM] ⚠️  Do you want to install Nyarch Updater? It's going to have some issues outside of Nyarch and Arch in general (Y/n) ⚠️ : " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  install_nyarch_updater
  echo "Nyarch Updater installed!"
fi

read -r -p "Do you want to edit your Gnome settings? Note that if you have not installed something before, you may experience some bugs at the start (Y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  configure_gsettings
  echo "Nyarch apps installed!"
fi



echo -e "$RED Log out and login to see the results! $NC"


