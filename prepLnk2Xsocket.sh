#!/bin/bash
# prepLnk2Xsocket.sh
# Create / refresh symlink to X unix socket file of my current X session.
# (To share it with Docker container through -v option.)

# Location of the symlink:
Lnk2unixSocket=${HOME}/.x-unix-socket

# Obtain location of 'my' X unix socket file.
# DISPLAY have the following format: <host>:<display>[.<screen>]
displayNum=${DISPLAY##*:}
socketNum=${displayNum%%.*}
socketFile=/tmp/.X11-unix/X${socketNum}

# [Re]Create symlink if it is required.
if [[ -L ${Lnk2unixSocket} ]] ; then
  echo "Symlink exists!"
  # Verify whether the link points to correct target
  LnkTarget=$(readlink "${Lnk2unixSocket}")
  echo "symlink: ${Lnk2unixSocket}"
  echo "its target: ${LnkTarget}"
  if [[ "${LnkTarget}" = "${socketFile}" ]] ; then
    echo "The link is correct. Nothing to do."
    exit 0
  else 
    # the symlink is NOT correct
    echo "remove the symlink"
    rm -f "${Lnk2unixSocket}"
  fi
fi

echo "Will create symlink ${Lnk2unixSocket} to ${socketFile}"
ln -s "${socketFile}" "${Lnk2unixSocket}"
