#!/bin/bash

# Define groups
groups=("brews" "trees" "cars" "staff" "admins")

# Create groups only if they don't exist
for group in "${groups[@]}"; do
    if ! getent group "$group" >/dev/null; then
        sudo groupadd "$group"
    fi
done

# Create directories with correct ownership and permissions
for group in "${groups[@]}"; do
    sudo mkdir -p "/$group"
    sudo chown root:"$group" "/$group"
    sudo chmod 770 "/$group"
done

# Define users for each group
declare -A users
users=(
    ["brews"]="coors stella michelob guiness"
    ["trees"]="oak pine cherry willow maple walnut ash apple"
    ["cars"]="chrysler toyota dodge chevrolet pontiac ford suzuki hyundai cadillac jaguar"
    ["staff"]="bill tim marilyn kevin george"
    ["admins"]="bob rob brian dennis"
)

# Create users only if they don't exist
for group in "${!users[@]}"; do
    for user in ${users[$group]}; do
        if ! id "$user" >/dev/null 2>&1; then
            sudo useradd -m -g "$group" -s /bin/bash "$user"
            echo "$user:$(openssl rand -base64 12)" | sudo chpasswd
        fi
    done
done

# Ensure 'dennis' is part of all groups and has sudo access
for group in "${groups[@]}"; do
    sudo usermod -aG "$group" dennis
done
sudo usermod -aG sudo dennis

echo "User and group setup completed successfully!"
