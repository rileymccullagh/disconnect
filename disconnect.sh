#!/bin/bash

# splashscreen
echo
echo "ScreenConnect Removal Tool"
echo "by Riley McCullagh"
echo

# check if su
if (( $EUID != 0 ))
    then
        echo "Please rerun this program as root to continue"
        exit
fi

# check if there is a screenconnect install
if test -n "$(find /opt -maxdepth 1 -name 'screenconnect*' -print -quit)"
    then
        echo "ScreenConnect is indeed installed. Nuking..."
        echo
    else
        echo "ScreenConnect does not appear to be installed."
        exit
fi
        

# list all optware starting with "screenconnect"
DIRS=`ls -ld /opt/screenconnect* | egrep '^d' |  awk '{print $9}'`

# iterate if there is more than one installation
for DIR in $DIRS
do
    # check if empty
    if [[ ! -z "$DIR" ]]
    then
        # remove /opt/ and .app to get install ID
        ID=${DIR#/opt/}
        ID=${ID%.app}
        
        # print it out for the good folk at home
        echo "ScreenConnect install ID: ${ID}"

        # screenconnect says to stop the screenconnect service
        #`launchctl unload /Library/LaunchAgents/${ID}-onlogin.plist`

        # but i'm not convinced this works, so i kill all processes
        # with "screenconnect" in the name instead
        # note the regex on screenconnect so awk doesn't find itself
        `ps aux | awk '/[s]creenconnect/ {print $2}' | xargs sudo kill`

        # delete the service definitions
        `rm /Library/LaunchAgents/${ID}-*.plist`
        
        # delete the daemon definitions
        `rm /Library/LaunchDaemons/${ID}.plist`

        # delete the screenconnect files
        `rm -r /opt/${ID}.app`
    fi
done

# that's all folks
echo "ScreenConnect should be uninstalled now."
