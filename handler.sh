#!/bin/bash
cd $HOME;

# READ GLOBAL OPTIONS
if [ -f config.cf ]; then
  isActive=`grep -oP '(?<=active:)\d+' config.cf`
  if (($isActive == 2)); then
    echo -n "Handler was disabled in the settings";
    exit 0;
  fi
  emails=`grep -oP '(?<=emails:).+' config.cf`
fi
###
folderToProcess=`find /home/ftpi/tmp/*/* -type d -not -empty -exec stat -c '%Y %n' {} \; | sort | head -n1 | cut -f2 -d' '`;
availableDirs=`ls $folderToProcess/.. | wc -l`;
tmpDir=/tmp/video_jpg;
# If detected dir does not have files or if it is a single one (in progress)
if  ! ls $folderToProcess | grep -q 'jpg'; then
  echo 'No directories to process';
  exit 1;
fi

echo -en "Detect photo folder to process: $folderToProcess \r\n";
if ! mount | grep -q 'gdfs' ; then
  sudo gdfs -o allow_other /home/pi/gdfs.creds $HOME/gdisk;
  echo -e "Mount google drive disk at:$HOME/gdisk \r\n";
fi

echo -e "Start building MPEG from uploaded frames. It may take while..\r\n"

jpgSet=`find $folderToProcess -type f -name "*.jpg" -exec stat -c '%Y^%n' {} \; | sort`
timestamp=0
whenUploaded=0
# Process only frames with timestamp less than 4 seconds. Means that they related to 1 video
for pic in $jpgSet; do
  curTs=`echo "$pic" | cut -f1 -d'^'`
  if [ $timestamp -eq 0 ]; then
    whenUploaded=$curTs;
  fi
  ((diff = $curTs - $timestamp))
  if [[ $timestamp -gt 0 && $diff -gt 4 ]]; then
    break
  fi 
  timestamp=$curTs
  fname="$fname $(echo "$pic" | cut -f2 -d'^')"
  
done

movieFile=$(date +"%Hчасов %Mминут %Sсекунд" --date=@$whenUploaded)
movieFile="$movieFile.mp4"

# fname - collected images

echo -e "Moving selected files to the $tmpDir\n"
if [ ! -d $tmpDir ]; then
 mkdir $tmpDir
fi
mv -t $tmpDir $fname
echo -e "Process prepared frames..\n"
cd $tmpDir && \
  cat *.jpg | /usr/local/bin/ffmpeg -framerate 3 -i - -vcodec libx264 -pix_fmt yuv420p "$movieFile"

cd -

echo -e "File $movieFile has been created. Start uploading to Google Disk...\r\n";

todayDir=$(date +"%Y-%m-%d" --date=@$whenUploaded)
if [ ! -d $HOME/gdisk/$todayDir ]; then
  mkdir $HOME/gdisk/$todayDir;
fi 
cp "$tmpDir/$movieFile" "$HOME/gdisk/$todayDir/$movieFile";

echo -e "New movie successfully uploaded to your google-drive cloud kardraspberry@gmail.com. Clean up useless jpgs..\r\n";

rm -rf $tmpDir;

if [ ! -e $emails ]; then  
  echo "Привет! Новое видео $movieFile было добавлено на гугл-диск kardraspberry@gmail.com." | /usr/bin/mailx -s "Raspberry notification" -A gmail -a /tmp/ipcamera.log $emails
  echo "A new email notification has been sent to $emails"
fi
echo "Done";
