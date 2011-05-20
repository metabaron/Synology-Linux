Synology Linux
==============

Bash script to synchronize your SABnzbd / Sickbeard / CouchPotato downloads on your linux box with your Synology RAID system.

Purpose
-------
I decided, when I bought a [Synology](http://www.synology.com/) to keep all my current [SABnzbd](http://sabnzbd.org/) / [Sickbeard](http://sickbeard.com/) / [CouchPotato](http://couchpotatoapp.com/) installation
on my Linux server because it's working and I have a much faster connexion on my Linux box than on my Synology RAID.

So, I wrote this script to move what I downloaded from my linux box to my Synology RAID and to keep Sickbeard directory structure, all through SSH

Contributing
------------
When to contribut? Please contact [me](https://github.com/metabaron) instead of forking the project.

Usage
-----
You can launch it on the command line or you can add it to your crontab such as:
	0 17 * * * /home/newsgroup/rsync_run.sh > /dev/null 2>&1
	
How it works?
-------------
Before being able to run the script, you should be sure that you can connect to your Synology through SSH without the need to enter any password (search for "ssh keys" on Google).

	It's stop your SABnzbd so that we are sure nothing will be download while moving everything
	Find info files for new series
	Connect to your Synology RAID through SSH and move all new info files for new series
	Find all new downloaded TV episodes
	Connect to your Synology RAID through SSH and move all new downloaded TV episodes
	Connect to your Synology RAID through SSH and move all new downloaded movies
	Restart SABnzbd
	
About me
-------------
You will find more about me through my [blog](http://blog.metabaron.net)