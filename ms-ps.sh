#!/bin/bash

# Coloring scheme for notfications and logo
ESC="\x1b["
RESET=$ESC"39;49;00m"
CYAN=$ESC"33;36m"
RED=$ESC"31;01m"
GREEN=$ESC"32;01m"

# Warning
function warning() 
{	echo -e "\n$RED [!] $1 $RESET\n"
	}

# Green notification
function notification() 
{	echo -e "\n$GREEN [+] $1 $RESET\n"
	}

# Cyan notification
function notification_b() 
{	echo -e "$CYAN $1 $RESET"
	}


# Function to write out a desktop entry/shortcut 
function write_shortcut()
{	# Set var for path to desktop
	location=/home/$USER/Desktop
	
	# Save icon to documents dir
	notification "Downloading icon..." && sleep 1
	wget -O /home/$USER/Documents/ps_icon.png https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/PowerShell_Core_6.0_icon.png/64px-PowerShell_Core_6.0_icon.png && sleep 0.5 
	clear
	
	# Create file
	touch $location/PowerShell.desktop || warning "Could not write file to Desktop, do you have write access?"
	
	echo "[Desktop Entry]" >> $location/PowerShell.desktop
	echo "Version=1.0" >> $location/PowerShell.desktop
	echo "Type=Application" >> $location/PowerShell.desktop
	echo "Name=Powershell" >> $location/PowerShell.desktop
	echo "Comment=# Launches MS PowerShell Core" >> $location/PowerShell.desktop
	
	# Change terminal emulator in case we're installing on Debian
	# If the debian var is not set to 1/true we'll assume Ubuntu or Fedora
	if [[ $debian == 1 ]]; then
		echo "Exec=x-terminal-emulator +t -T PowerShell -e pwsh" >> $location/PowerShell.desktop
	else
		echo "Exec=xterm -bg blue -cr white -fw Laksaman +t -T PowerShell -e pwsh" >> $location/PowerShell.desktop
	fi
	
	echo "Icon=/home/$USER/Documents/ps_icon.png" >> $location/PowerShell.desktop
	echo "Path=/home/$USER" >> $location/PowerShell.desktop
	echo "Terminal=false" >> $location/PowerShell.desktop
	echo "StartupNotify=false" >> $location/PowerShell.desktop
	echo "Name[en_US]=PowerShell" >> $location/PowerShell.desktop
	
	chmod +x $location/PowerShell.desktop && sleep 0.5
	notification "Done"
	
	}

function check_version()
{	notification "Checking Ubuntu version..." && sleep 1.5
	# Check Distro version
	distro=$(uname -v)
	case $distro in 
		*'14.04'*)
		version='14.04'
		notification "Version $version was detected."
		;;
	esac
				
	case $distro in 
		*'16.04'*)
		version='16.04'
		notification "Version $version was detected."
		;;		
	esac
				
	case $distro in 
		*'17.04'*)
		version='17.04'
		notification "Version $version was detected."
		;;
	esac
	
	}

# If we're installing on Debian we need to check if sudo is present
function util_check_debian()
{	notification "Checking Linux utilities required by the installer."
	sleep 2
				
	# Check for sudo
	su_do=$(which sudo)
	case $su_do in
		*/usr/bin/sudo*)
		sd=1
		;;
	esac
	
	if [[ $sd != 1 ]]; then
		warning "Heuristics seem to indicate `sudo` is not installed on this system."
		read -p 'Automatically resolve? Y/n : ' choice
		if [[ $choice == 'y' || $choice == 'Y' ]]; then
			notification "Please enter root password."
					
			su -
			apt-get install sudo -y && notification "Sudo was succesfully installed" || warning "An error was encountered while trying to install sudo. Quitting..." && exit 1
			printf "Please add your regular user account to sudoers and restart the script."
			printf "Quitting..."
			sleep 2 && exit 1
		else
			warning "Not resolving." && sleep 1
		fi
	fi

	}
	
# Distro specific installation/main component
function install()
{	notification "Distro Specific Installation. Below is an overview of the supported Distros." 
	
	PS3='Select a Distro: '
	options=("Ubuntu 14 Through 17" "Debian 8" "Debian 9" "CentOS 7" "RHEL 7" "OpenSUSE 42.2" "Fedora 25" "Fedora 26" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Ubuntu 14 Through 17")
				# Call function to check Ubuntu version
				check_version
				
				notification "Adding MS PowerShell repository..." && sleep 1.5
				# Get relevant GPG key
				curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
				
				# Add correct sources list
				if [[ $version == '14.04' ]]; then
					sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/14.04/prod.list
				else
					if [[ $version == '16.04' ]]; then
						sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list
					else
						if [[ $version == '17.04' ]]; then
							sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/17.04/prod.list
						else
							warning "Your version of Ubuntu does not appear to be supported at this time." 
							printf "Consider running PowerShell-Core via the AppImage method instead."
						fi
					fi
				fi
				
				notification "Updating Repository..." && sleep 1.5
				sudo apt-get update
				notification "Installing PowerShell." && sleep 1.5
				sudo apt-get install -y powershell || warning "Failed to install."
				clear
				
				notification "Installation completed."
				printf "Enter 'pwsh' to start a PowerShell instance rom the terminal."
				printf "Alternatively the installer can add a Desktop entry for you.\n"
				
				read -p 'Add Desktop shortcut? Y/n : ' choice
				if [[ $choice == 'y' || $choice == 'Y' ]]; then
					write_shortcut
				else
					notification "Done."
				fi
				printf "%b \n"
				;;
			"Debian 8")
				debian=1
				
				if [[ "$EUID" -ne 0 ]]; then
					util_check_debian
				fi
				
				notification "Updating system and installing apt-transport-https component." && sleep 1.5
				sudo apt-get update
				sudo apt-get install curl apt-transport-https
				clear

				# Get relevant GPG key
				notification "Adding MS PowerShell repository..." && sleep 1.5
				curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

				# Register the Microsoft Product feed
				sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-jessie-prod jessie main" > /etc/apt/sources.list.d/microsoft.list'

				notification "Updating Repository..." && sleep 1.5
				sudo apt-get update
				notification "Installing PowerShell." && sleep 1.5
				sudo apt-get install -y powershell || warning "Failed to install."
				clear
				
				notification "Installation completed."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."
				printf "Alternatively the installer can add a Desktop entry for you.\n"
				
				read -p 'Add Desktop shortcut? Y/n : ' choice
				if [[ $choice == 'y' || $choice == 'Y' ]]; then
					write_shortcut
				else
					notification "Done."
				fi
				printf "%b \n"
				;;
			"Debian 9")
				debian=1
				if [[ "$EUID" -ne 0 ]]; then
					util_check_debian
				fi
								
				notification "Updating system and installing apt-transport-https component." && sleep 1.5
				sudo apt-get update
				sudo apt-get install curl apt-transport-https
				clear

				# Get relevant GPG key
				notification "Adding MS PowerShell repository..." && sleep 1.5
				curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

				# Register the Microsoft Product feed
				sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'
				notification "Updating Repository..." && sleep 1.5
				sudo apt-get update
				notification "Installing PowerShell." && sleep 1.5
				sudo apt-get install -y powershell || warning "Failed to install."
				clear
				
				notification "Installation completed."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."
				printf "Alternatively the installer can add a Desktop entry for you.\n"
				
				read -p 'Add Desktop shortcut? Y/n : ' choice
				if [[ $choice == 'y' || $choice == 'Y' ]]; then
					write_shortcut
				else
					notification "Done."
				fi
				printf "%b \n"
				;;
			"CentOS 7")
				notification "Adding MS PowerShell repository..." && sleep 1.5
				curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

				notification "Installing PowerShell..." && sleep 1.5
				sudo yum install -y powershell || warning "Failed to install."
				
				notification "Done."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."
				printf "%b \n"
				;;
			"RHEL 7")
				notification "Adding MS PowerShell repository..." && sleep 1.5
				curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

				notification "Installing PowerShell..." && sleep 1.5
				sudo yum install -y powershell || warning "Failed to install."
				
				notification "Done."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."				
				printf "%b \n"
				;;
			"OpenSUSE 42.2")
				notification "Adding MS PowerShell repository..." && sleep 1.5
				sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
				curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/zypp/repos.d/microsoft.repo

				notification "Updating Repository..." && sleep 1.5
				sudo zypper update

				notification "Installing PowerShell..." && sleep 1.5
				
				sudo zypper install powershell || warning "Failed to install" && printf "%b\nWhen installing PowerShell-Core, OpenSUSE may report
that nothing provides libcurl. libcurl should already 
be installed on supported versions of OpenSUSE.
Run zypper search libcurl to confirm. The error will 
present 2 'solutions'.Choose 'Solution 2' to continue
installing PowerShell Core."
				
				notification "Done."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."
				printf "%b \n"
				;;
			"Fedora 25")
				notification "Adding MS PowerShell repository..." && sleep 1.5
				sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
				curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

				notification "Updating Repository..." && sleep 1.5
				sudo dnf update

				notification "Installing PowerShell..." && sleep 1.5
				sudo dnf install -y powershell
				clear
				
				notification "Installation completed."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."
				printf "Alternatively the installer can add a Desktop entry for you.\n"
				
				read -p 'Add Desktop shortcut? Y/n : ' choice
				if [[ $choice == 'y' || $choice == 'Y' ]]; then
					write_shortcut
				else
					notification "Done."
				fi
				printf "%b \n"
				;;
			"Fedora 26")
				notification "Adding MS PowerShell repository..." && sleep 1.5
				sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
				curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

				notification "Updating Repository..." && sleep 1.5
				sudo dnf update
				
				notification "Installing compat-openssl component..." && sleep 1.5
				sudo dnf install compat-openssl10

				notification "Installing PowerShell..." && sleep 1.5
				sudo dnf install -y powershell
				clear
				
				notification "Installation completed."
				printf "Enter 'pwsh' to start a PowerShell instance from the terminal."
				printf "Alternatively the installer can add a Desktop entry for you.\n"
				
				read -p 'Add Desktop shortcut? Y/n : ' choice
				if [[ $choice == 'y' || $choice == 'Y' ]]; then
					write_shortcut
				else
					notification "Done."
				fi
				printf "%b \n"
				;;
			"Quit")
				exit 1
				;;
			*) echo invalid option;;
		esac
	done 
	}

# AppImage installation process
function AppImage()
{	notification "Downloading PowerShell AppImage"
	sleep 1.5
	
	mkdir /home/$USER/PowerShell-Core && cd PowerShell-Core
	wget -O powershell.AppImage https://github.com/PowerShell/PowerShell/releases/download/v6.0.1/powershell-6.0.1-x86_64.AppImage
	cwd=$(pwd)
	cd ..
	
	notification "Operation Completed. Making Appimage executable and creating symlink..."
	sleep 1
	
	chmod +x powershell.AppImage && ln -s $cwd/powershell.AppImage PowerShell
	notification "Operation Completed." 
	printf "Entering the command 'PowerShell' into your terminal" 
	printf "should start a PowerShell instance via the AppImage binary.\n"
	sleep 2
	
	} 	

function usage()
{   notification_b "\nThis script comes with two methods of deploying PowerShell-Core on Linux.
the first approach makes use of 'AppImages' which bundles all the 
dependencies into a single package that works independently of the 
user's Distro.\n 
It is built as a single portable binary and as such can be run without
installing, or altering any system libraries or preferences.
	
If you'd prefer to run PowerShell-Core natively, and install the related 
components to your distribution directly, the second approach is reccomended.
Opting for this approach will show a list of supported distros. 
Once you've made your selection, the installer will
employ your package manager and related utilities to install PowerShell
to your system proper.\n\n"
    }

function init_opt()
{   PS3='Please enter your choice: '
	options=("Employ AppImage" "Distro Specific Installation" "Usage" "Quit") 
	select opt in "${options[@]}"
	do
		case $opt in
			"Employ AppImage")
				# AppImage function call
				AppImage
				printf "%b\n"
				;;
			"Distro Specific Installation")
				# Install function call
				install
				printf "%b\n"
				;;
			"Usage")
				# Usage and general info
				usage
				printf "%b\n"
				;;                
			"Quit")
				warning "Quitting..." && sleep 1.5
				exit 1
				;;
			*) echo invalid option;;
		esac
	done 

    }

function intro()
{	notification_b "###############################################"
	notification_b "#  _____                   _____ _       _ _  #"
	notification_b "# |  _  |___ _ _ _ ___ ___|   __| |_ ___| | | #"
	notification_b "# |   __| . | | | | -_|  _|__   |   | -_| | | #"
	notification_b "# |__|  |___|_____|___|_| |_____|_|_|___|_|_| #"
	notification_b "#                                             #"
	notification_b "# -- Installer for *Nix --------------------- #"	
	notification_b "# ---- Multi Distro Support ----------------- #"
	notification_b "# -------- Author : Vector/NullArray -------- #"
	notification_b "# ------------ Twitter : @Real__Vector ------ #"
	notification_b "###############################################"

	notification_b "nWelcome to PowerShell installer for *Nix\n\n."

    init_opt
    
    }


# Check for root
if [[ "$EUID" -ne 0 ]]; then
	warning "It is recommended that this script is run as root"
	printf "Running it without super user privilege may result "
	printf "in the script failing to install critical components\n correctly\n"
   
   read -p 'Continue without root? Y/n : ' choice
   if [[ $choice == 'y' || $choice == 'Y' ]]; then
       notification "\nProceeding..."
       sleep 1.5
       clear
     
       # Call install information and menu
       intro
   else
       warning "Aborted"
       exit 1
   fi
fi

# Call install information and menu
intro

