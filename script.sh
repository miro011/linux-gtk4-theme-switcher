#!/bin/bash

####################################################
# INIT / CHECK

[ ! -d "$HOME/.local/share/themes" ] && echo "No themes in $HOME/.local/share/themes" && read -p "PRESS ENTER TO CLOSE" hold && exit

####################################################
# GET VALID THEMES

declare -a validThemeNamesArr=()

for indexThemeDir in $(find "$HOME/.local/share/themes" -type f -name 'index.theme'); do
    themeDir=$(dirname "$indexThemeDir")
    [ ! -d "$themeDir/gtk-4.0" ] && continue # no gtk-4.0 = theme won't be compatible

    themeName=$(basename $themeDir)
    validThemeNamesArr+=("$themeName")
done

validThemeNamesArr=($(printf '%s\n' "${validThemeNamesArr[@]}" | sort)) # sort array
validThemeNamesArr=('Reset' "${validThemeNamesArr[@]}") # add reset as the first option

####################################################
# GET DESIRED THEME USER INPUT

clear
echo "SELECT AN OPTION AND CLICK ENTER:"
for ((i=0; i<${#validThemeNamesArr[@]}; i++)); do
    echo "[$i] ${validThemeNamesArr[$i]}"
done

while true; do
    read tuin
    tuin=$(echo "$tuin" | xargs) # trim
    if [[ "$tuin" =~ ^[0-9]+$ && -v validThemeNamesArr[$tuin] ]]; then
        break
    else
        echo "Invalid input, try again."
    fi
done

####################################################
# APPLY THEME

chosenThemeName=${validThemeNamesArr[$tuin]}

# remove previous .bash-profile export - always done
grep -v "export GTK_THEME=" "$HOME/.bash_profile" > tmpfile && mv tmpfile "$HOME/.bash_profile"

if [[ "$tuin" == "0" ]]; then
    gsettings reset org.gnome.desktop.interface gtk-theme
    grep -v "GTK_THEME=" "$HOME/.local/share/flatpak/overrides/global" > tmpfile && mv tmpfile "$HOME/.local/share/flatpak/overrides/global"
    clear
    echo "CUSTOM USER THEME RESET"
    echo "RESTART FOR EVERYTHING TO BE CHANGED"
else
    # gsettings gtk (needed for window decorations in non-flatpak apps)
    gsettings set org.gnome.desktop.interface gtk-theme "$chosenThemeName"

    # add new export
    echo "export GTK_THEME=$chosenThemeName" >> "$HOME/.bash_profile"

    # flatpak
    flatpak override --user --filesystem=xdg-data/themes # only way to give access to /.local/share/themes
    flatpak override --user --env=GTK_THEME="$chosenThemeName"

    echo "CUSTOM USER THEME APPLIED"
    echo "LOGOUT FOR EVERYTHING TO BE CHANGED"
fi

echo "ALSO APPLY TO ROOT USER? y/N"
read suin
suin=$(echo "$suin" | xargs) # trim
suin=$(echo "$suin" | tr '[:upper:]' '[:lower:]') # lower case
if [[ "$suin" == "y" ]]; then
    sudo [ ! -d "/root/.local/share/themes" ] && sudo mkdir -p "/root/.local/share/themes" # create root themes folder if not already there
    sudo [ ! -d "/root/.local/share/themes/$chosenThemeName" ] && sudo cp -r "$HOME/.local/share/themes/$chosenThemeName" "/root/.local/share/themes/$chosenThemeName" # copy chosen theme to root if it's not there
    
    # remove previous .bash-profile export - always done
    sudo grep -v "export GTK_THEME=" "/root/.bash_profile" > tmpfile && sudo mv tmpfile "/root/.bash_profile"
    
    if [[ "$tuin" == "0" ]]; then
        sudo gsettings reset org.gnome.desktop.interface gtk-theme
    else
        # gsettings gtk (needed for window decorations in non-flatpak apps)
        sudo gsettings set org.gnome.desktop.interface gtk-theme "$chosenThemeName"

        # add new export
        echo "export GTK_THEME=$chosenThemeName" | sudo tee --append "/root/.bash_profile" > /dev/null 2>&1
    fi
    
    echo "ROOT ACCOUNT UPDATED"
fi

read -p "PRESS ENTER TO CLOSE" hold
