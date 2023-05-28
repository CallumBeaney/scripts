(*
	toggleGray.applescript
	
	For Ventura 13.* and may or may not work on macOS 14 and later.
	Reference: https://stackoverflow.com/questions/75152094/applescript-ventura-toggle-accessibility-grayscale-on-off
	
	Tested: macOS Ventura 13.4
	VikingOSX, 2023-05-26, Apple Support Communities, No warranties of any kind.
*)

use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use framework "AppKit"
use scripting additions

current application's NSWorkspace's sharedWorkspace()'s openURL:(current application's NSURL's URLWithString:"x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display")
tell application "System Events" to tell application process "System Settings"
	repeat until exists window "Display"
	end repeat
	click checkbox 1 of group 4 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "Display"
end tell

tell application "System Settings" to if it is running then quit
return