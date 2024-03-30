#!/bin/bash
# genLocalXcookie.sh
# Generate / update an "individual" x-cookie using auth info from the shared x-cookie.
# Shared x-cookie is provided to the container from host by using "-v"  docker create option
# and contains "universal" host identification 'ffff' that means "any host".
# "Individual" x-cookie has host identification set to the container's host-name. 
# --- created by dm-MariK ---

sharedXcookieFile=/Xauthority
localXcookieFile=${HOME}/.Xauthority

# Obtain auth "token" of the shared x-cookie.
sharedCookieToken="$(xauth -i -f ${sharedXcookieFile} list | awk '{print $3}')"

# Check whether the local x-cookie [if exists] contains the same auth "token". 
# Exit if Yes. Remove the local x-cookie if No.
if [[ -f "${localXcookieFile}" ]] ; then
  localCookieToken="$(xauth -i -f ${localXcookieFile} list | awk '{print $3}')"
  if [[ "${localCookieToken}" = "${sharedCookieToken}" ]] ; then
    exit 0
  else
    echo "${localXcookieFile} contains outdated x-cookie. Removing it."
    rm -f "${localXcookieFile}"
  fi
fi

# Bake new local x-cookie using auth "token" from the shared x-cookie.
touch "${localXcookieFile}"
xauth -i -f "${localXcookieFile}" add ${HOSTNAME}/unix:0  MIT-MAGIC-COOKIE-1 ${sharedCookieToken}
if [[ $? -eq 0 ]] ; then
  echo "Now run: export XAUTHORITY=${localXcookieFile}"
  echo "(to use local individual x-cookie instead of shared one from the host)"
fi
