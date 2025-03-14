#!/bin/bash

# Output header
echo "Starting Assignment 2 Script..."

# Function to configure the network interface
configure_network() {
    echo "Checking network configuration..."
    
    # Check if the configuration already exists
    if ! grep -q '192.168.16.21/24' /etc/netplan/10-lxc.yaml; then
        echo "Configuring network to 192.168.16.21/24"
        # Update netplan configuration file for the specific IP
        sed -i 's/192.168.16.*/192.168.16.21\/24/' /etc/netplan/10-lxc.yaml
        netplan apply
        echo "Network configured successfully."
    else
        echo "Network configuration already correct."
    fi
}

# Function to update /etc/hosts
configure_hosts() {
    echo "Checking /etc/hosts for correct IP and hostname..."
    
    if ! grep -q '192.168.16.21 server1' /etc/hosts; then
        echo "Updating /etc/hosts..."
        # Update /etc/hosts with the correct IP and hostname
        sed -i '/server1/d' /etc/hosts
        echo "192.168.16.21 server1" >> /etc/hosts
        echo "/etc/hosts updated successfully."
    else
        echo "/etc/hosts already correct."
    fi
}

# Function to install Apache2 and Squid
install_software() {
    echo "Checking if Apache2 and Squid are installed..."

    # Install Apache2 if not installed
    if ! dpkg -l | grep -q apache2; then
        echo "Installing apache2..."
        apt-get install apache2 -y
        systemctl enable apache2
        systemctl start apache2
        echo "Apache2 installed and started."
    else
        echo "Apache2 is already installed."
    fi

    # Install Squid if not installed
    if ! dpkg -l | grep -q squid; then
        echo "Installing squid..."
        apt-get install squid -y
        systemctl enable squid
        systemctl start squid
        echo "Squid installed and started."
    else
        echo "Squid is already installed."
    fi
}

# Function to create users and set up SSH keys
create_users() {
    local users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

    echo "Checking user accounts..."

    for user in "${users[@]}"; do
        if ! id -u "$user" &>/dev/null; then
            echo "Creating user $user..."
            useradd -m -s /bin/bash "$user"
            # Add SSH directory
            mkdir -p /home/"$user"/.ssh
            chown "$user":"$user" /home/"$user"/.ssh
            chmod 700 /home/"$user"/.ssh
            # Add SSH keys (both RSA and ED25519)
            ssh-keygen -t rsa -b 4096 -f /home/"$user"/.ssh/id_rsa -N ""
            ssh-keygen -t ed25519 -f /home/"$user"/.ssh/id_ed25519 -N ""
            cat /home/"$user"/.ssh/id_rsa.pub >> /home/"$user"/.ssh/authorized_keys
            cat /home/"$user"/.ssh/id_ed25519.pub >> /home/"$user"/.ssh/authorized_keys
            chown -R "$user":"$user" /home/"$user"/.ssh
            chmod 600 /home/"$user"/.ssh/authorized_keys
            echo "User $user created and SSH keys configured."
        else
            echo "User $user already exists."
        fi

        # Add `dennis` to sudo group
        if [ "$user" == "dennis" ]; then
            usermod -aG sudo "$user"
            echo "$user added to sudo group."
        fi
    done
}

# Run all configuration functions
configure_network
configure_hosts
install_software
create_users

echo "Assignment 2 Script completed successfully!"
