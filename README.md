# linux-gtk4-theme-switcher
This changes the theme for everything, including gtk4/libadwaita applicatons. It affects your user, the sudo user and flatpak applications. Originally written for Fedora, but it should work with other GNOME-based distributions.

Usage: Download themes from gnome-look.org. Extract them in ~/.themes. When extracted, make sure they have a gtk-4.0 folder, because if they don't they won't be listed by the script, or in other words, work. Then just run the script:
```bash script.sh```

Alternatively you can create an application out of it:
- Put it in some folder. In my case I put it in /usr/local/bin and named it "gtk4-theme-switcher.sh"
- Install mate-terminal for the "application" componenet to work properly
- Save this in /usr/local/share/applications as "gtk4-theme-switcher.desktop"

```
[Desktop Entry]
Type=Application
Terminal=false
Name=GTK4 Theme Switcher
Categories=System
Icon=preferences-desktop-appearance-symbolic
Exec=mate-terminal --class "gtk4themeswitcher" --disable-factory --title "GTK4 THEME SWITCHER" --maximize -- sh -c 'bash "/usr/local/bin/gtk4-theme-switcher.sh"'
StartupWMClass=gtk4themeswitcher
```
