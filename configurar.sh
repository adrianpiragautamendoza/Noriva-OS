#!/bin/sh

echo "--- Iniciando configuración de NORIVA ---"

# 1. Configuración Base (Corregida a 'none')
lb config \
 --debian-installer none \
 --bootappend-live "boot=live components quiet splash hostname=noriva username=noriva user-fullname='Noriva Live User'" \
 --iso-volume "NORIVA_1.0"

# 2. Lista de Paquetes
echo "Creando lista de paquetes..."
cat <<EOF > config/package-lists/noriva.list.chroot
xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
xserver-xorg-core xserver-xorg
fonts-noto fonts-roboto papirus-icon-theme dmz-cursor-theme
calamares calamares-settings-debian
grub-efi-amd64 grub-pc-bin plymouth plymouth-themes
firmware-linux firmware-linux-nonfree firmware-iwlwifi firmware-realtek
firmware-amd-graphics firmware-misc-nonfree intel-microcode amd64-microcode
bluetooth bluez
firefox-esr thunar xfce4-terminal mousepad gnome-software
network-manager-gnome pulseaudio pavucontrol
xfce4-whiskermenu-plugin fastfetch curl wget git
EOF

# 3. Estilo Calamares
echo "Configurando Calamares..."
mkdir -p config/includes.chroot/etc/calamares/branding/noriva
cat <<EOF > config/includes.chroot/etc/calamares/branding/noriva/branding.desc
---
componentName:  noriva
strings:
    productName: "NORIVA"
    shortProductName: "NORIVA"
    version: "1.0"
    shortVersion: "1.0"
    versionedName: "NORIVA 1.0"
    shortVersionedName: "NORIVA 1.0"
    bootloaderEntryName: "NORIVA"
    productUrl: "https://adrianfpiragauta.blogspot.com/"
    supportUrl: "https://adrianfpiragauta.blogspot.com/"
images:
    productLogo: "logo.svg"
    productIcon: "logo.svg"
    productWelcome: "welcome.png"
style:
    sidebarBackground: "#202020"
    sidebarText: "#FFFFFF"
    sidebarTextSelect: "#000000"
    sidebarTextHighlight: "#3498DB"
slideshow: "show.qml"
uploadServer:
    url: ""
EOF

cat <<EOF > config/includes.chroot/etc/calamares/branding/noriva/stylesheet.qss
QWidget { font: 11pt "Noto Sans"; color: #eff0f1; background-color: #1a1a1a; }
#sidebarApp { background-color: #101010; border-right: 1px solid #333; }
QPushButton { background-color: #333; color: #fff; border: 1px solid #444; border-radius: 4px; padding: 6px; }
EOF

# 4. Icono Escritorio
mkdir -p config/includes.chroot/usr/share/applications
cat <<EOF > config/includes.chroot/usr/share/applications/install-noriva.desktop
[Desktop Entry]
Type=Application
Name=Install NORIVA
Exec=calamares
Icon=/etc/calamares/branding/noriva/logo.svg
Terminal=false
Categories=Qt;System;
EOF

# 5. Panel XFCE (Whisker)
echo "Configurando Panel XFCE..."
mkdir -p config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml
cat <<EOF > config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array"><value type="int" value="1"/></property>
  <property name="panel-1" type="empty">
    <property name="position" type="string" value="p=6;x=0;y=0"/>
    <property name="size" type="uint" value="48"/>
    <property name="plugin-ids" type="array">
      <value type="int" value="1"/>
      <value type="int" value="2"/>
      <value type="int" value="3"/>
      <value type="int" value="4"/>
      <value type="int" value="5"/>
      <value type="int" value="6"/>
      <value type="int" value="7"/>
      <value type="int" value="8"/>
    </property>
  </property>
  <property name="plugin-1" type="string" value="whiskermenu"/>
  <property name="plugin-2" type="string" value="tasklist">
    <property name="grouping" type="bool" value="true"/>
    <property name="show-labels" type="bool" value="false"/>
  </property>
  <property name="plugin-3" type="string" value="separator"><property name="expand" type="bool" value="true"/></property>
  <property name="plugin-4" type="string" value="pager"/>
  <property name="plugin-5" type="string" value="separator"><property name="style" type="uint" value="0"/></property>
  <property name="plugin-6" type="string" value="systray"><property name="square-icons" type="bool" value="true"/></property>
  <property name="plugin-7" type="string" value="clock"/>
  <property name="plugin-8" type="string" value="actions"/>
</channel>
EOF

# 6. Wallpaper Config
cat <<EOF > config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/noriva-background.png"/>
        <property name="image-style" type="int" value="5"/>
      </property>
    </property>
  </property>
</channel>
EOF

# 7. Fastfetch Config
echo "Configurando Fastfetch..."
mkdir -p config/includes.chroot/etc/skel/.config/fastfetch
cat <<EOF > config/includes.chroot/etc/skel/.config/fastfetch/config.jsonc
{
    "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": { 
        "source": "/usr/share/noriva/branding/logo.ascii", 
        "type": "file",
        "padding": { "top": 2, "left": 2, "right": 4 }
    },
    "display": { "color": "blue" },
    "modules": [ "title", "break", "os", "kernel", "packages", "shell", "wm", "memory", "break", "colors" ]
}
EOF

# Alias
mkdir -p config/includes.chroot/etc/profile.d
echo "alias neofetch='fastfetch'" > config/includes.chroot/etc/profile.d/noriva-neofetch.sh

# 8. Whisker Config
mkdir -p config/includes.chroot/etc/skel/.config/xfce4/panel
cat <<EOF > config/includes.chroot/etc/skel/.config/xfce4/panel/whiskermenu-1.rc
button-icon=/usr/share/noriva/branding/logo.svg
button-title=Menú
show-button-title=false
show-button-icon=true
launcher-show-name=true
favorites-in-recent=true
menu-width=450
menu-height=500
EOF

# Tecla Windows
cat <<EOF > config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="Super_L" type="string" value="xfce4-popup-whiskermenu"/>
      <property name="override" type="bool" value="true"/>
    </property>
  </property>
</channel>
EOF

echo "--- Configuración completada ---"
