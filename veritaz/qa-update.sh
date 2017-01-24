#!/bin/bash
URL="https://prabhakarraksan:gtuvn89yn@bitbucket.org/raksan/smart.git"
HEAD="QA"
git ls-remote  $URL refs/heads/"$HEAD" > /tmp/full_commit
HASHCODE=`sed -e 's/.\{7\}/&\n/g' /tmp/full_commit | awk 'NR==1'`

cd /apps/hosting/configs/smart;git log | grep commit | head -n 1 | awk '{ print $2  }' > /apps/hosting/configs/lastcommit
LASTCOMMIT=`sed -e 's/.\{7\}/&\n/g' /apps/hosting/configs/lastcommit | awk 'NR==1'`

gitclone() {
pkill node
cd /hosting/configs/deploy/bundle
pwd
forever stop main.js
cd /apps/hosting/configs/
pwd
cp -fr /apps/hosting/configs/deploy/smart.tar.gz /backup/build/veritaz/qa/qa_build_`date -%d%m%y-%H`.tar.gz
#tar -czvf /backup/build/veritaz/qa/qa_build_`date -%d%m%y-%H`.tar.gz /apps/hosting/configs/deploy/
rm -fr /apps/hosting/configs/deploy/*
tar -czf /backup/code/veritaz/qa/qa_`date -%d%m%y-%H`.tar.gz /apps/hosting/configs/smart
rm -fr /apps/hosting/configs/smart
rm -fr /root/.forever/*.log
cd /apps/hosting/configs/
ls -al
pwd
git clone https://prabhakarraksan:gtuvn89yn@bitbucket.org/raksan/smart.git
chown -R root:root smart/.meteor/local
cd smart
pwd
/usr/bin/git checkout QA
/usr/bin/git reset --hard $1
git log -10 --stat | mail -s "GIT Log SMART QA" qabuild@raksanconsulting.com,smartteam@raksanconsulting.com,suresh.garimella@raksan.in
}

build () {
#export MONGO_URL=mongodb://smartdb:2029/smart_dev
#export ROOT_URL=https://smartqa.raksanconsulting.com/
#export PORT=2300
#meteor add meteorhacks:cluster
#export CLUSTER_WORKERS_COUNT=auto
#echo $MONGO_URL
#echo $ROOT_URL
#echo $PORT=2300
#export METEOR_SETTINGS=$(cat /apps/hosting/configs/smart/settings.json)
meteor bundle /apps/hosting/configs/deploy/smart.tar.gz --allow-superuser 
}

patch() {
cd /apps/hosting/configs/deploy/
pwd
tar -xvzf smart.tar.gz
cd bundle/programs/server/
pwd
npm install fibers
npm install underscore
npm install source-map-support
npm install semver
cd /apps/hosting/configs/deploy/bundle/
cp -fr /apps/hosting/configs/smart/settings.json /apps/hosting/configs/deploy/bundle/
cp -fr /apps/hosting/configs/smart/settings.json /apps/hosting/configs/deploy/
cp -fr /apps/hosting/configs/builds/main.js /apps/hosting/configs/deploy/bundle/
cp -fr /apps/hosting/configs/builds/main.js /apps/hosting/configs/deploy/
cp -fr /usr/share/nginx/html/assets /apps/hosting/configs/deploy/
cp -fr /usr/share/nginx/html/logo.png /apps/hosting/configs/deploy/bundle/
passenger-config restart-app --ignore-app-not-running --ignore-passenger-not-running /apps/hosting/configs/deploy
#pwd
#forever start main.js
#forever logs
tail -f /var/log/nginx/error.log &
}

if
        [ "$HASHCODE" == $LASTCOMMIT ] ; then
        echo "Patch Failed!"
        echo "Checking.........."
        echo "`date` Current hashcode $HASHCODE on Bitbucket is not latest and already deployed and running"
else
        echo "Last Commit hashcode $LASTCOMMIT is not Latest. Started Patching with new hashcode $HASHCODE at `date`"
        gitclone
        if [ -d /apps/hosting/configs/smart ]; then
#                if [ -d /apps/hosting/configs/smart/.git/objects/pack/  ]; then
                echo "GIT clone success"
#                fi
        else
                gitclone
        fi
        build
        if [ -d /apps/hosting/configs/deploy/bundle/ ]; then
                    echo "Meteor bundle is success"
                else
                        build
                fi
        patch
        if [ -f /apps/hosting/configs/deploy/smart.tar.gz ]; then
                if [ -d /apps/hosting/configs/deploy/bundle  ]; then
                        echo "App patch is success"
#                        service nginx re
			curl -v 'https://veritazqa.fieldrepo.com/updateApplicationMetaData/MINOR'
#                        rm -fr /apps/hosting/configs/deploy/smart.tar.gz
                fi
        fi
fi

