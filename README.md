# Draft-CW-Script
I created this draft CW script just to play Fun CW with some friends, and i decided to publish it now.
If you don't know what draft CW is, simply it is a clan war between two teams where the players need to take checkpoints distributed around the map, each point is counted for the player's team.

# General Info About The Script

1- The script needs DGS to work, if you don't know what DGS is please visit the following link https://wiki.multitheftauto.com/wiki/Resource:DGS where you can donwload DGS and add it to your server.<br>
2- The script is made to work with the default Race gamemode and the default mapmanager (it can work with a different race gamemode as long as it is based on the default Race gamemode).<br>
3- The script needs Admin rights.

# Guide For Adding Checkpoints to maps

1- Use map editor to add "markers" in the map, then save the changes.<br>
2- Open the map folder after saving it and open the file with .map extension (the file that containes all objects of the map).<br>
3- Go to the end of the file and copy the last objects with <marker> tag and place, don't forget the delete them after copying them.<br>
4- Head to draft script folder and paste the copied lines in the file "markers.xml".<br>
5- The markers for each map should be added into separate tags named in a specific way, for example if the map name is <br>"[DM] ghost1 ft ghost2 - Ghost Map"<br>the tags for the markers in "markers.xml" file should be <DMghost1ftghost2-GhostMap>, just remove the spaces and brakets.<br>

Note:<br>1- The current markers.xml file has two maps prepared as an example.<br>2- The color and the size of the markers doesn't matter it is automatically set by the script to white and 4.
