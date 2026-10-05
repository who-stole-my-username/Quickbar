#!/bin/bash

src="$(dirname "$(readlink -f "$0")")/../.."
dest="$HOME/.config/quickshell/Quickbar"

bold="\033[1m"
color_success="\033[92m"
color_error="\033[31m"
reset="\033[0m"

if [ "$EUID" -eq 0 ]; then
    echo -e "Why are you trying to run this with root?"
    exit 1
fi

echo -e "${bold}Install required packages...${reset}"

read -r -n 1 -p "Update your system? (Stronly recommended) [Y/n] " system_upgrade
echo
system_upgrade=${system_upgrade:-y}

if [ "$system_upgrade" = y ] || [ "$system_upgrade" = Y ]; then
    upgrade="-Syu"
else
    upgrade="-S"
fi

if sudo pacman $upgrade --needed quickshell ripgrep hyprland proton-vpn-cli networkmanager ttf-material-symbols-variable ttf-roboto; then
    echo
else
    echo -e "${bold}${color_error}Installation failed for some reason.${reset}"
    echo -e "Try installing the following packages yourself and rerun the script: quickshell, hyprland, ripgrep, proton-vpn-cli, networkmanager, ttf-material-symbols-variable, ttf-roboto"
    exit 1
fi

echo -e "${bold}Starting services...${reset}"

sudo systemctl enable --now NetworkManager > /dev/null 2>&1

echo -e "${bold}Moving files to their destination...${reset}"

if ! mkdir -p "$dest" > /dev/null 2>&1; then
    echo -e "${bold}${color_error}Could not create $dest${reset}"
    exit 1
fi

if [ "$(readlink -f "$src")" != "$(readlink -f "$dest")" ]; then
    if ! cp -a "$src"/. "$dest/" > /dev/null 2>&1; then
        echo -e "${bold}${color_error}Could not copy to $dest${reset}"
        exit 1
    fi
fi

echo -e "${bold}Creating udev rules...${reset}"

echo "SUBSYSTEM==\"power_supply\", ATTR{online}==\"0\", RUN+=\"$dest/bar/scripts/chargingTracker.sh\"" \
    | sudo tee /etc/udev/rules.d/90-charging-tracker.rules > /dev/null
sudo udevadm control --reload > /dev/null 2>&1

echo -e "${bold}Applying permissions...${reset}"

chmod +x "$dest/bar/scripts/chargingTracker.sh" > /dev/null 2>&1

echo -e "${bold}Setting up proton...${reset}"

read -r -n 1 -p "Are you already using proton-vpn-cli? [y/N] " user
echo
user=${user:-n}

if [ "$user" = N ] || [ "$user" = n ]; then
    read -r -n 1 -p "Do you already have a proton account? [Y/n] " account
    echo
    account=${account:-y}

    if [ "$account" = N ] || [ "$account" = n ]; then
        echo -e "Go to https://protonvpn.com/ and create a free or paid account"
        read -r -p "Press enter to continue " _
    fi

    read -r -p "What's your proton username? " username

    until protonvpn signin "$username"; do
        echo
        read -r -p "What's your proton username? " username
    done
fi

echo -e "${bold}Starting quickshell...${reset}"

setsid qs -p "$dest/shell.qml" > /dev/null 2>&1 &

echo -e "${bold}${color_success}Installed successfully${reset}"

echo -e "If you wish the bar to autostart after a reboot put:"
echo -e "- .conf: exec-once = qs -p ~/.config/quickshell/Quickbar/shell.qml"
echo -e "- .lua: hl.on(\"hyprland.start\", function() hl.exec_cmd(\"qs -p ~/.config/quickshell/Quickbar/shell.qml\") end)"
echo -e "into your Hyprland config."
