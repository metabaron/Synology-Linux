#!/bin/bash

##Edit start here
rsync_command="rsync"
rsync_pid=`pidof $rsync_command`

tv_directory="/home/newsgroup/downloads/complete/TV"
movies_directory="/home/newsgroup/downloads/complete/Renamed_movies"
home_directory="/home/newsgroup"

sabnzbd_pause="http://www.***.net/sabnzbd/api?mode=pause&apikey=***************"
sabnzbd_resume="http://www.***.net/sabnzbd/api?mode=resume&apikey==***************"

synology_server="mathieu@***.dyndns.org"
synology_TV="/volume1/video/TV"
synology_Movies="/volume1/video/Movies"
##Edit stop here

echo -e "Starting synchronisation"
if [ -n "$rsync_pid" ]
then
    echo -e "\tRsync already running"
else
    echo -e "\tPausing Sabnzbd so that nothing is going to be downloaded while synchronizing and deleting files"
    wget --output-file=$home_directory/sabnzbd_pause_log $sabnzbd_pause --output-document=$home_directory/sabnzbd_pause
    if [ `stat --printf="%s" $home_directory/sabnzbd_pause` == "3" ]
    then
        echo -e "\tSabnzbd stopped, we can keep going on"
        echo -e "\tRun rsync on TV series"
        if [ -d "$tv_directory" ]
        then
            echo -e "\t\tRun synchronisation for new series and their nfo + tbn (not the actual downloaded episodes)"
            cd $tv_directory
            find . -name "*" -type f | grep -i -v "Season " > $home_directory/all_except_season_folder.txt
            wait
            rsync --recursive --compress --times --progress -e "ssh -i $home_directory/.ssh/id_rsa" --files-from $home_directory/all_except_season_folder.txt $tv_directory $synology_server:$synology_TV
            wait
            rm $home_directory/all_except_season_folder.txt

            echo -e "\t\tNow, let's sync the downloaded series"
            cd $tv_directory
            find . -regextype posix-egrep -regex ".+Season .+(nfo|avi|tbn)" > $home_directory/episodes.txt
            wait
            rsync --remove-source-files --recursive --compress --times --progress -e "ssh -i $home_directory/.ssh/id_rsa" --files-from $home_directory/episodes.txt $tv_directory $synology_server:$synology_TV
            wait
			echo -e "\t\tNow, let's ask our Synology to reindex our files"
            cat episodes.txt | sed 's#\(.*\)/.*#\1#' |sort -u > $home_directory/directories.txt
            while read line
            do
                ssh -i $home_directory/.ssh/id_rsa "/usr/syno/sbin/synoindex -A $synology_TV/$line"
            done < $home_directory/directories.txt
            rm $home_directory/directories.txt
            rm $home_directory/episodes.txt
            echo -e "\t\tRsync on $tv_directory done"
        else
            echo -e "\t\tCannot rsync $tv_directory - Directory do not exist"
        fi
        echo -e "\tRun rsync on movies"
        if [ -d "$movies_directory" ]
        then
            echo -e "\t\tStarting movies synchronisation"
            rsync --remove-source-files --recursive --compress --times --progress -e "ssh -i $home_directory/.ssh/id_rsa" $movies_directory $synology_server:$synology_Movies
            wait
            find $movies_directory/* -type d -empty -delete
            wait
            echo -e "\t\tRsync on $movies_directory done"
        else
            echo -e "\t\tCannot rsync $movies_directory - Directory do not exist"
        fi
        echo -e "\tRestarting Sabnzbd"
		        wget --output-file=$home_directory/sabnzbd_resume_log $sabnzbd_resume --output-document=$home_directory/sabnzbd_resume
        if [ `stat --printf="%s" $home_directory/sabnzbd_resume` == "3" ]
        then
            echo -e "\tSabnzbd up and running"
            echo -e "\tDeleting all files used to pause and resume Sabnzbd"
            rm -rf $home_directory/sabnzbd_pause_log $home_directory/sabnzbd_pause $home_directory/sabnzbd_resume_log $home_directory/sabnzbd_resume
            echo -e "Files deleted"
        else
            echo -e "\tCannot resume Sabnzbd"
            echo -e "\tPlease have a look to log files sabnzbd_resume_log and sabnzbd_resume"
        fi
    else
        echo -e "\tCannot pause Sabnzbd so no synchronisation done"
        echo -e "\tPlease have a look to log files sabnzbd_pause_log and sabnzbd_pause"
    fi
fi

echo -e "Synchronisation done"