#!/bin/bash

# Fix Windows line endings.
#dos2unix ~/./projects/BashServerScripts/vhost.sh

##### Colors #####
BOLD=`tput bold`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
WHITE=`tput setaf 7`
RESET=`tput sgr0`           # Reset colour


projectname="test"
url="$projectname.local"

projectspath="/home/chris/projects"


help() {
    echo "  Help here:"
	exit 0
}
list() {
	echo "  Enabled virtual hosts:"
	ls -l /etc/apache2/sites-enabled/
	exit 0
}
available() {
	echo "  Available virtual hosts:"
	ls -l /etc/apache2/sites-available/
	exit 0
}
add() {
    #set -x			# activate debugging from here
	echo "  Add a new virtual host:${GREEN} $url ${RESET}"
	# Create a new Project dir (if it doesn't already exist), add public_html and log dirs, and a simple index.htm file.
	make-project-dir
    # Copy the vhost-template file and add this project's details to it.
    make-template
    # Create the project alias in /var/www
    create-www-alias
    # Enable site and reload Apache
    enable
    echo "  To use, please create a new entry in the Windows 'hosts' file for: ${GREEN} $url ${RESET}"
    #set +x			# stop debugging from here
	exit 0
}
remove() {
	echo "  Remove and Delete virtual host: $url"
    sudo a2dissite $url
    sudo service apache2 reload
	sudo rm "/var/www/$projectname"
	sudo rm "/etc/apache2/sites-available/$url"
	exit 0
}
enable() {
    #set -x			# activate debugging from here
    sudo -v
	echo "  Enable virtual host: $url"
    sudo a2ensite $url
    sudo service apache2 reload
    #set +x			# stop debugging from here
	exit 0
}
disable() {
    #set -x			# activate debugging from here
    sudo -v
	echo "  Disable virtual host: $url"
    sudo a2dissite $url
    sudo service apache2 reload
    #set +x			# stop debugging from here
	exit 0
}

#--------- helper methods ---------
# Check if the Project dir exists
make-project-dir() {
    #set -x			# activate debugging from here
    cd "$projectspath"
    if [ ! -d "$projectspath/$projectname" ]; then
        echo "${GREEN}  Creating New Project $projectname directory ${RESET}"
        #mkdir -p "$projectspath/$projectname"
        mkdir -p ${projectname}/{public_html,logs}
        #mkdir -p "$projectname/logs"
        echo "<!DOCTYPE html><head></head><body><p>Site for <strong>$projectname</strong> works!</p></body>" > "${projectname}/public_html/index.htm"
    else
        echo "${YELLOW}  Using existing Project '$projectname' directory ${RESET}"
    fi
    #set +x			# stop debugging from here
}
# Make the template file and add it to sites-available
make-template() {
    if [ ! -f /etc/apache2/sites-available/vhost-template ]; then
        echo "${RED}  The 'vhost-template' file is missing! (needs to be in same dir as this script) ${RESET}"
        exit 0
    fi
    echo "${GREEN}  Creating a new vhost '$url' in sites-available ${RESET}"
    sudo cp /etc/apache2/sites-available/vhost-template /etc/apache2/sites-available/$url
    # Replace placeholders
    sudo sed -i 's/template.projectname/'$projectname'/g' /etc/apache2/sites-available/$url
    sudo sed -i 's/template.url/'$url'/g' /etc/apache2/sites-available/$url
}
# Create the alias to the project in /var/www
create-www-alias() {
    if [ ! -h /var/www/$projectname ]; then
        echo "${YELLOW}  Creating LINK to /var/www/$projectname ${RESET}"
        sudo ln -s /home/chris/projects/$projectname/ /var/www/$projectname
    else
        echo "${YELLOW}  Symbolic LINK to /var/www/$projectname already exists ${RESET}"
    fi
}



# Loop to read options and arguments
while [ $1 ]; do
    case "$1" in
    	'-l') list;;
    	'-a') available;;
		'-h'|'--help') help;;
    	'-add') projectname="$2" url="$projectname.local"
    	        add;;
        '-rm') projectname="$2" url="$projectname.local"
		        remove;;
        '-d') projectname="$2" url="$projectname.local"
		        disable;;
    esac
    shift
done



exit
