#!/bin/bash
# createWrapper.sh [container_host_name] [trusted|untrusted]
cookieType="untrusted"
hostName=jailed-browser
# --------------------
Repo=${HOME}/GIT/
# --------------------
if [[ $2 ]] ; then
  if [[ $2 = "trusted" ]] ; then
    cookieType="$2"
  fi
fi
if [[ $1 ]] ; then 
  hostName="$1"
fi

${Repo}/jailed-browser/prepLnk2Xsocket.sh
${Repo}/jailed-browser/bakeDockerXcookie.sh

docker build ${Repo}/jailed-browser/ -t jailed-browser
docker create --name "${hostName}" -ti -h "${hostName}" -v $HOME/Downloads/jailed-browser:/Downloads -v /etc/localtime:/etc/localtime -v $HOME/.x-unix-socket:/tmp/.X11-unix/X0 -v ${HOME}/.DockerXcookie.${cookieType}:/Xauthority -e DISPLAY=":0" jailed-browser

docker start -ai "${hostName}"
