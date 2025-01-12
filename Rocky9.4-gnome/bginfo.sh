#!/usr/bin/bash
#  Function : adds sysinfo text to desktop
#  built on :  Rocky Linux 9.4
#  created  :  campbell1@fastmail.com.au
#  
#  yum install ImageMagick ImageMagick-devel ImageMagick-perl
#  cp 01-background /etc/dconf/db/local.d/01-background ; dconf update
#  shc -o bginfo -f bginfo.sh

while : ; do

BGFILE=/tmp/sys.info

> $BGFILE
echo "BGINFO" >> $BGFILE
echo "IP Address: " `hostname -I | awk '{print $1}'` >> $BGFILE
echo "CPU's: " `cat /proc/cpuinfo | grep processor | wc -l`  >> $BGFILE
echo "Memory: " `free -g | grep ^Mem | awk '{print $2 " GB"}'`  >> $BGFILE
echo "Last Run: " `date +%D@%H:%M` >> $BGFILE
echo "Hostname: " `hostname` >> $BGFILE
echo "Nameserver: " `cat /etc/resolv.conf | grep nameserver | awk '{print $2}'` >> $BGFILE
echo "Built on : " `ls -lct / | tail -1 | awk '{print $6 "-" $7 " " $8}'` >> $BGFILE
echo "Uptime : " `uptime -s` >> $BGFILE
echo "Hardware : " `hostnamectl | grep "Hardware Model" | awk -F ":" '{print $2}'`  >> $BGFILE
echo "Firmware : " `hostnamectl | grep "Firmware" | awk -F ":" '{print $2}'`  >> $BGFILE
echo "Mac ADDR : " `nmcli device show | grep  GENERAL.HWADDR | grep -v 00:00:00:00:00:00 | awk '{print $2}'`  >> $BGFILE
echo " " >> $BGFILE

desktop_user=`loginctl | grep seat | grep active | grep -v gdm| awk '{print $3}'`

if [ -n "$desktop_user" ]; then
    filename=`sudo -u $desktop_user gsettings get org.gnome.desktop.background picture-uri`
    path_filename=$(echo "$filename"  | sed 's/file:\/\///')
    if [[ "$path_filename" =~ xml ]] ; then
         image_filename=$(echo "$path_filename" | sed 's/.xml/.png/')  
    else
         image_filename=$path_filename 
    fi
    real_image_filename=$(echo "$image_filename" |   sed "s/'//g")
     
     if [[ ! -e "$real_image_filename.original" ]]; then
         cp  $real_image_filename  $real_image_filename.original
     fi


      cat /tmp/sys.info  | convert -pointsize 20 -gravity center -background none -fill yellow label:@- /tmp/info.png
      cp -f $real_image_filename.original  /tmp/
      real_image_filename_basename=$(basename "$real_image_filename.original")
      composite -gravity center /tmp/info.png /tmp/$real_image_filename_basename /tmp/merged.png
      cp -f /tmp/merged.png  $real_image_filename
    

else
    echo "No user logged into a GNOME desktop session."
     
fi

sleep 300
done

