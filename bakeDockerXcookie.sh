#!/bin/bash
# bakeDockerXcookie.sh [trusted|untrusted]
# By default - no $1 is passed / unrecognized $1 - untrusted x-cookie is baked:
cookieType="untrusted"
# Generate a cookie that has to be used within 3600 seconds the first time:
Timeout=3600

if [[ $1 && $1 = "trusted" ]] ; then
  cookieType="$1"
fi
echo ${cookieType} 

# Define a file name for the x-cookie; remove existing x-cookie file.
Cookiefile=${HOME}/.DockerXcookie.${cookieType}
if [[ -f ${Cookiefile} ]] ; then
  rm ${Cookiefile}
fi


tmpCookiefile=${HOME}/tmp.Xcookie

# xauth -f ~/mycookie generate $DISPLAY . untrusted timeout 3600
xauth -q -f ${tmpCookiefile} generate ":0" . ${cookieType} timeout ${Timeout}
echo "xuy-1"
ls -la ${tmpCookiefile}
xauth -i -f ${tmpCookiefile} list | awk '{print $3}'

# replace host identification with ffff / family wild # <---------- CORRECT NAMING FOR THAT ???
Cookie="$(xauth -i -f ${tmpCookiefile} nlist | sed -e 's/^..../ffff/')"

# ...
touch ${Cookiefile}
echo "${Cookie}" | xauth -i -f ${Cookiefile} nmerge -
chmod 600 ${Cookiefile}

rm ${tmpCookiefile}

xauth -i -f ${Cookiefile} list | awk '{print $3}'
xauth -i -f ${Cookiefile} list 
