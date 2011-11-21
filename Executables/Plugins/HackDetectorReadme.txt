HackDetector 0.2
by MasterOfChaos

Atm it finds the following exploits
-Zerg Mineralhack
-Nuke anywhere
-Multicommand
-Automine at the start of the game
-Rally exploit

Additionally it has a experimental antispoof integrated and allows you to drop pausehackers.

Multicommand
It now checks for a command alternating with select. If this happens at least 3 times(corresponds to 3 control groups being commanded) it displays a message.
There are some false positives, so you should only accuse your opponent if you get this message often.

Automine
Automine consists of fours selects alternating with gaters/moves to different targets in the first possible frame(5 on bnet, 2 on LAN). Detecting these is similar to multicommand, except moves with different target are also considered here.

Nuke anywhere
Whenever an opponent selects a nuke you get a message. As selecting a nuke is required for nuke anywhere exploit and not possible without a hack it should work reliably.

Zerg mineralhack
It shows a message if a CancelTrain command is given to a zerg larva. There might be other variants of this hack (related to muta->guard/devourer and hyd->lurker), so if you find a replay where a minhack is not detected post it here.

Set enemy Rallypoint
AdvLoader 2.0 allowed observers to change the rallypoints of enemy buildings. For 1.15.2 there are hacks which allow the same for every player/observer. I have added detection for this exploit, but I have only one replay with it, so I'm not entirely sure if it works correctly.

Spoof detector:
Sends whois commands to bnet to find out if the players are really in the game they are. There are sometimes false postives caused by bnet lag. So you should check with /whois if it finds a spoofer. In games with korean names it does not work correctly (at least with a non korean windows locale) as the result of /whois is empty.
And you might get banned by bnet for the flood of /whois you send. So I have disabled it by default.

Anti-Pausehack:
Enables the dropbutton even if the opponent pausehacks. I think in a two player game both players get a disconnect, with more players the game should continue normally.
Thanks to Python_Max from ICCup for this method.

Debug logging:
Press Ctrl+Shift+D in the config dialog to show an additional tab with debug features. Allows to log all actions in a game. This extensive logging might slow down the game a bit.

If you have a replay where the opponent uses an exploit which is not detected by this detector please post a replay here. Rigged UMS maps do not count as an exploit.

Download and usage
Now it is a plugin. Copy it to your Launcher folder and check it in the plugin list.
http://winner.cspsx.de/Starcraft/Tool/HackDetector.zip

As usual blizzard might ban you for using this. The chance for that is a bit higher that with chaosplugin, and about the same as LatencyChanger or any of the AdvLoader plugins.