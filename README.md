# Draft-DM-CW-Script
I created this draft DM CW script just to play Fun CW with some friends, and i decided to publish it now.
If you don't know what draft CW is, simply it is a clan war between two teams where the players need to take checkpoints distributed around the map, each point is counted for the player's team.

# General Info About The Script

1- The script needs DGS to work, if you don't know what DGS is please visit the following link https://wiki.multitheftauto.com/wiki/Resource:DGS where you can donwload DGS and add it to your server.<br>
2- The script is made to work with the default Race gamemode and the default mapmanager (it can work with a different race gamemode as long as it is based on the default Race gamemode).<br>
3- The script needs Admin rights.

# Guide For Adding Checkpoints To Maps

1- Use map editor to add "markers" in the map, then save the changes.<br>
2- Open the map folder after saving it and open the file with .map extension (the file that containes all objects of the map).<br>
3- Go to the end of the file and copy the last objects with "marker" tag, don't forget to delete them after copying.<br>
4- Head to draft script folder and paste the copied lines in the file "markers.xml".<br>
5- The markers for each map should be added into separate tags named in a specific way, for example if the map name is <br>"[DM] ghost1 ft ghost2 - Ghost Map"<br>the tags for the markers in "markers.xml" file should be <DMghost1ftghost2-GhostMap>, just remove the spaces and brakets.<br>

Note:<br>1- The current markers.xml file has two maps prepared as an example.<br>2- The color and the size of the markers doesn't matter, it is automatically set by the script to white and 4.<br>3- I know adding markers could be done easier but I didn't want to edit Race and Mapmanager scripts. :D


# In-game Commands
-- Join team one /join 1<br>
-- Join team two /join 2<br>
-- Join spectators /spec<br>
-- Set the status of the CW to "Live" begenning from the next map /live<br>
-- Set the status of the CW to "free" right away /free<br>
-- Ends the CW right away /end<br>
-- Specifies the maximum number of rounds /rounds [num]<br>
-- Set the current round number /now [num]<br>
-- Rests everything /reset

# If You Need More Help
Contact me on Discord: gst1
