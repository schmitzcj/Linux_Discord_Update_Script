#!/bin/bash

discord_package=$(curl -sI "https://discord.com/api/download?platform=linux&format=deb" | awk -v IGNORECASE=1 '/^location:/ { print $2 }' | tr -d '[:space:]')

latest_discord_version=$(curl -sI "https://discord.com/api/download?platform=linux&format=deb" | awk -v IGNORECASE=1 '/^location:/ { print $2 }' | awk -F'/' '{print $6}')
installed_discord_version=$(grep -oP '"version": "\K[^"]+' /usr/share/discord/resources/build_info.json)

if [ "$installed_discord_version" == "$latest_discord_version" ]; then
    echo "No need to update"
else
    echo "Updating Discord from $installed_discord_version to $latest_discord_version"
    sudo pkill Discord
    sudo apt remove -y discord
    original_user=$SUDO_USER
    download_folder="/home/$original_user/Downloads"
    sudo curl -o "$download_folder/discord-$latest_discord_version.deb" -L "$discord_package"
    sudo apt install -y "$download_folder/discord-$latest_discord_version.deb"
    sleep 5s
    sudo -u $original_user setsid nohup /usr/share/discord/Discord > /dev/null 2>&1 < /dev/null &
    echo "Done - Starting Discord"
fi
