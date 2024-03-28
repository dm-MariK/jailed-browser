#!/bin/bash
# prepLnk2Xsocket.sh

Lnk2unixSocket=${HOME}/.x-unix-socket

# Obtain location of 'my' unix socket file
displayNum=${DISPLAY##*:}
socketNum=${displayNum%%.*}
socketFile=/tmp/.X11-unix/X${socketNum}

# [Re]Create symlink if it is required
if [[ -e ${Lnk2unixSocket} ]] ; then
  if [[ -L ${Lnk2unixSocket} ]] ; then
    # Verify whether the link points to correct target
    LnkTarget=$(readlink "${Lnk2unixSocket}")
    if [[ "${LnkTarget}" = "${socketFile}" ]] ; then
      exit 0
    else # the symlink is NOT correct
      # remove the symlink
      rm -f "${Lnk2unixSocket}"
    fi
  else # file name conflict
    echo "Filesystem object ${Lnk2unixSocket} exists and is NOT symlink."
    echo "Can not create symlink ${Lnk2unixSocket} to ${socketFile}"
    echo "File name conflict - solve it manually and run this script once again!"
    exit 1
  fi
fi
ln -s "${socketFile}" "${Lnk2unixSocket}"
