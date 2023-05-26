-- COMPILE TO EXEC: 	osacompile -o bw bw.scpt
-- RUN SCRIPT FILE: 	osascript bw.scpt
-- ADD TO PATH: 			export PATH="/filepath/bw.scpt:$PATH"
-- ALIAS:							alias bw='osascript /filepath/bw.scpt'									

-- My thanks to & debug assist from  VikingOSX (https://discussions.apple.com/profile/VikingOSX/participation)

use framework "Foundation"
use framework "AppKit"
use scripting additions

property ca : current application
property prefpane : "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_ColorFilters"

(ca's NSWorkspace's sharedWorkspace)'s openURL:(ca's NSURL's URLWithString:prefpane)

tell application "System Events"
	tell application process "System Preferences"
		set frontmost to true
		tell window "Accessibility"
			delay 1
			click first checkbox of tab group 1 of group 1
		end tell
	end tell
end tell

tell application "System Preferences" to if it is running then quit
return