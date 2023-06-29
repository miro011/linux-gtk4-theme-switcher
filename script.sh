#!/bin/bash

[ ! -d "$HOME/.local/share/themes" ] && echo "No themes in $HOME/.local/share/themes" && read hold && exit
sudo [ ! -d "/root/.local/share/themes" ] && sudo mkdir -p "/root/.local/share/themes" # create root themes folder if not already there

# GET VALID THEMES

declare -a validThemeNamesArr=()

for indexThemeDir in $(find "$HOME/.local/share/themes" -type f -name 'index.theme'); do
    themeDir=$(dirname "$indexThemeDir")
    [ ! -d "$themeDir/gtk-4.0" ] && continue # no gtk-4.0 = theme won't be compatible

    themeName=$(basename $themeDir)
    sudo [ ! -d "/root/.local/share/themes/$themeName" ] && sudo cp -r "$themeDir" "/root/.local/share/themes/$themeName" # copy theme to root if it's not there
    validThemeNamesArr+=("$themeName")
done

validThemeNamesArr=($(printf '%s\n' "${validThemeNamesArr[@]}" | sort)) # sort array
validThemeNamesArr=('Reset' "${validThemeNamesArr[@]}") # add reset as the first option

# GET USER INPUT

clear
echo "SELECT AN OPTION AND CLICK ENTER:"
for ((i=0; i<${#validThemeNamesArr[@]}; i++)); do
    echo "[$i] ${validThemeNamesArr[$i]}"
done

while true; do
    read uin
    uin=$(echo "$uin" | xargs) # trim
    if [[ "$uin" =~ ^[0-9]+$ && -v validThemeNamesArr[$uin] ]]; then
        break
    else
        echo "Invalid input, try again."
    fi
done

# APPLY THEME

# remove previous .bash-profile export - always done
grep -v "export GTK_THEME=" "$HOME/.bash_profile" > tmpfile && mv tmpfile "$HOME/.bash_profile"
sudo grep -v "export GTK_THEME=" "/root/.bash_profile" > tmpfile && sudo mv tmpfile "/root/.bash_profile"

if [[ "$uin" == "0" ]]; then
    gsettings reset org.gnome.desktop.interface gtk-theme
    sudo gsettings reset org.gnome.desktop.interface gtk-theme
    sudo flatpak override --reset
    clear
    echo "RESTART FOR EVERYTHING TO BE APPLIED"
    read hold
else
    themeName=${validThemeNamesArr[$uin]}

    # gsettings gtk (needed for window decorations in non-flatpak apps)
    gsettings set org.gnome.desktop.interface gtk-theme "$themeName"
    sudo gsettings set org.gnome.desktop.interface gtk-theme "$themeName"


    # add new export
    echo "export GTK_THEME=$themeName" >> "$HOME/.bash_profile"
    echo "export GTK_THEME=$themeName" | sudo tee --append "/root/.bash_profile"

    # flatpak
    sudo flatpak override --filesystem=xdg-data/themes # only way to give access to /.local/share/themes
    sudo flatpak override --env=GTK_THEME="$themeName"

    clear
    echo "LOGOUT FOR EVERYTHING TO BE APPLIED"
    read hold
fi
