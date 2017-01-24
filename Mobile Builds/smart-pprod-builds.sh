#!/bin/bash
pkill node
DATE=`date +%d%m%Y-%H`
cd /Users/zoylomac/smart-pprod-builds
mkdir $DATE
cd $DATE
git clone https://prabhakarraksan:gtuvn89yn@bitbucket.org/raksan/smart.git
mkdir APK
cd smart
pwd
/usr/bin/git checkout PRE-PROD
/usr/bin/git reset --hard $1
#git log -10 --stat | mail -s "GIT Log SMART DEV" qabuild@raksanconsulting.com, qateam@raksanconsulting.com
# Android APK Generation-----------------------------------------------
#export MONGO_URL=mongodb://52.66.116.226:2029/smart_uat
export ROOT_URL=https://veritazpp.fieldrepo.com/
export PORT=2300
echo $MONGO_URL
echo $ROOT_URL
echo $PORT=2300
date +%s > .meteor.id
meteor --allow-superuser reset
meteor --allow-superuser remove-platform ios
meteor --allow-superuser add-platform android
#cp -fr settings-uat.json /Users/zoylomac/settings-smuat.json
export METEOR_SETTINGS=$(cat /Users/zoylomac/settings-smuat.json)
meteor --allow-superuser build ../APK --server https://veritazpp.fieldrepo.com
cd ../APK/android
keytool -genkey -alias SMART-SS-"$DATE" -keyalg RSA \-keysize 2048 -validity 10000 -keystore ~/raksan_keystore.jks <<EOF
raksan
SMART
SMART
SMART
HYD
TS
IN
YES

EOF
END
jarsigner -digestalg SHA1 release-unsigned.apk SMART-SS-"$DATE" -keystore ~/raksan_keystore.jks <<EOF
raksan
EOF
END
/Users/zoylomac/Library/Android/sdk/build-tools/22.0.1/zipalign 4 release-unsigned.apk SMART-SS-"$DATE".apk
# iOS Generationp-------------------------------------------------------------------------
cd ../../smart/
date +%s > .meteor.id
meteor --allow-superuser reset
meteor --allow-superuser remove-platform android
meteor --allow-superuser add-platform ios
export MONGO_URL=mongodb://52.66.116.226:2029/smart_uat
export ROOT_URL=https://veritazpp.fieldrepo.com/
export METEOR_SETTINGS=$(cat /Users/zoylomac/settings-smuat.json)
meteor --allow-superuser run ios-device --mobile-server $ROOT_URL --production --settings /Users/zoylomac/settings-smuat.json
