#!/bin/bash
# bakeDockerXcookie.sh [trusted|untrusted]
# Prepare XAUTHORITY MIT-MAGIC-COOKIE-1 for a Docker container by `xauth generate`.
# Created cookies contain a server address family code (host identification) 
# that must be overwritten as follows.
# * bake a temporary trusted or untrusted cookie and put it to the temporary file,
# * read the cookie from that file,
# * change server address family code / host identification to "universal" one (ffff) 
#   that means "any host",
# * write the result to the final cookie file that will be shared with a Docker container,
# * remove the temporary cookie file.
# See here:
# <https://github.com/mviereck/x11docker/wiki/X-authentication-with-cookies-and-xhost-(%22No-protocol-specified%22-error)>
# <https://github.com/mviereck/x11docker/wiki/How-to-access-X-over-TCP-IP-network>

# By default - no $1 is passed / unrecognized $1 - untrusted x-cookie is baked:
cookieType="untrusted"
# Generate a cookie that has to be used within 3600 seconds the first time:
Timeout=3600

if [[ $1 && $1 = "trusted" ]] ; then
  cookieType="$1"
fi
echo "Will bake ${cookieType} cookie."

# Define a file name for the x-cookie; remove existing x-cookie file.
Cookiefile=${HOME}/.DockerXcookie.${cookieType}
if [[ -f ${Cookiefile} ]] ; then
  rm ${Cookiefile}
fi

# Create temporary cookie file.
tmpCookiefile=${HOME}/tmp.Xcookie

# xauth -f ~/mycookie generate $DISPLAY . untrusted timeout 3600
xauth -q -f ${tmpCookiefile} generate ":0" . ${cookieType} timeout ${Timeout} > /dev/null 2>&1
#echo "boom-1"
#ls -la ${tmpCookiefile}
#xauth -i -f ${tmpCookiefile} list | awk '{print $3}'

# Extract the the cookie string, replace host identification with ffff / family wild.
Cookie="$(xauth -i -f ${tmpCookiefile} nlist | sed -e 's/^..../ffff/')"

# Write the adjusted cookie to the final cookie file, restrict its access rights.
touch ${Cookiefile}
echo "${Cookie}" | xauth -i -f ${Cookiefile} nmerge -
chmod 600 ${Cookiefile}

# Remove temporary cookie file.
rm ${tmpCookiefile}

#xauth -i -f ${Cookiefile} list | awk '{print $3}'
#xauth -i -f ${Cookiefile} list 
