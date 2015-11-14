#!/bin/sh

## Set Screen Saver for OS X.  Original script is from macmule
##	# GitRepo: https://github.com/macmule/setscreensaver


## Modified by: macgurudev
## Modified date: 11-14-2015
## Changes made:
##		Instead of modifying the currently logged in user's Screen Saver settings I opted to modify the template and then copy to user's 
##		home dirs already on the system.  This was more ideal for myself in a Lab/deployment environment.
##
##		Also removed JAMF mentioned since I personally do not use JAMF
## 


## VARIABLES ##

startTime="3600" 					# Integer - Seconds
justMain=""							# Boolean
screenSaverName="Computer Name"		# String
screenSaverPath="/System/Library/Frameworks/ScreenSaver.framework/Resources/Computer Name.saver"		# String
requirePassword="0"					# Integer (1 = true, 0 = false)
timeBeforeRequiringPassword=""		# Integer - Seconds

###########
# 
# Get the Universally Unique Identifier (UUID) for the correct platform
# ioreg commands found in a comment at http://www.afp548.com/article.php?story=leopard_byhost_changes
#
###########

	# Check if hardware is PPC or early Intel
	if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` == "00000000-0000-1000-8000-" ]]; then
		macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c51-62 | awk {'print tolower()'}`
	# Check if hardware is new Intel
	elif [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
		macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
	fi

###########


###########
#
# For each variable check to see if it has a value. If it does then write the variables value to the applicable plist in the applicable manner
#
###########


# Set bash to become case-insensitive
shopt -s nocaseglob

# Remove the all the com.apple.screensaver* plists, with the Case insensitivity this will also remove the Case insenstivity was updated to remove: 
# com.apple.ScreenSaver.iLifeSlideShows.XX.plist & com.apple.ScreenSaverPhotoChooser.XX.plist saver plists
if [ -d /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/ ]; then
	rm -rf /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver*
else
	mkdir /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost
fi

# Set bash to become case-sensitive
shopt -u nocaseglob


if [[ -n $startTime ]]; then
	/usr/libexec/PlistBuddy -c "Add :idleTime integer $startTime" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

if [[ -n $justMain ]]; then
	/usr/libexec/PlistBuddy -c "Add :mainScreenOnly bool $justMain" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

# Make sure the moduleDict dictionary exists
	/usr/libexec/PlistBuddy -c "Add :moduleDict dict" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist

if [[ -n $screenSaverName ]]; then
	/usr/libexec/PlistBuddy -c "Add :moduleDict:moduleName string $screenSaverName" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
	/usr/libexec/PlistBuddy -c "Add :moduleName string $screenSaverName" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

if [[ -n $screenSaverPath ]]; then
	/usr/libexec/PlistBuddy -c "Add :moduleDict:path string $screenSaverPath" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
	/usr/libexec/PlistBuddy -c "Add :modulePath string $screenSaverPath" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi


# Variables for the ~/Library/Preferences/com.apple.screensaver.plist

# Remove the com.apple.screensaver.plist, comment out if you do not wish to remove this file
rm -rf /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.screensaver.plist


if [[ -n $requirePassword ]]; then
	/usr/libexec/PlistBuddy -c "Add :askForPassword integer $requirePassword" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.screensaver.plist
fi

if [[ -n $timeBeforeRequiringPassword ]]; then
	/usr/libexec/PlistBuddy -c "Add :askForPasswordDelay integer $timeBeforeRequiringPassword" /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.screensaver.plist
fi

# Echo out on completion..
echo "Set Screen Saver for user: "$loggedInUser"..."

# Now copy created template files to all user's home folders already on the computer
# Set permissions accordingly

for i in `ls /Users/ | grep -v Shared | grep -v .localized`
do
	cp /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.screensaver.plist /Users/$i/Library/Preferences/
	chown $i /Users/$i/Library/Preferences/com.apple.screensaver.plist
	
	cp /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist /Users/$i/Library/Preferences/ByHost/
	chown $i /Users/$i/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
	echo "Set Screen Saver for user: "$i"..."
done

echo "Done setting Screen Saver Settings"

