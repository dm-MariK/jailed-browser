FROM ubuntu:20.04

LABEL maintainer="dm-MariK"

# Define non-root user, it's UID, gecos string and password
ARG user=jbjohn
ARG uid=1000
ARG gecos="John Doe"
ARG password=${user}

# Copy configs
COPY --chmod=640 configs/root /root
COPY --chmod=644 configs/etc /etc
COPY --chmod=644 configs/etc_skel /etc/skel

# Copy Yandex-Browser deb-package
COPY Yandex.deb /Yandex.deb

# + Install most important packages
# + Install basic fonts
# + Install additional fonts
# + Install sshuttle - Transparent proxy server for VPN over SSH
# + Install Firefox
# + Install vim-gtk3 (gvim) and kwrite text editors
# + Generate ru_RU.UTF-8 locale
# + Install Yandex-Browser
# + Set up root password
# + Add non-root user
RUN <<EOT bash
  apt-get update -y -qq
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo bash-completion net-tools vim iputils-ping nmap htop mc ssh xauth xterm mesa-utils less locales 
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ttf-mscorefonts-installer ttf-dejavu ttf-xfree86-nonfree fonts-dejavu-core fonts-freefont-ttf fonts-opensymbol fonts-urw-base35 fonts-symbola ttf-bitstream-vera 
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ttf-unifont xfonts-unifont fonts-prociono ttf-ubuntu-font-family fonts-georgewilliams fonts-hack fonts-yanone-kaffeesatz ttf-aenigma ttf-anonymous-pro ttf-engadget ttf-sjfonts ttf-staypuft ttf-summersby 
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sshuttle
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq firefox firefox-locale-ru browser-plugin-freshplayer-pepperflash
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq vim-gtk3 kwrite
  locale-gen ru_RU.UTF-8
  # ---- \begin{Install-Yandex-Browser} ----------------
  { DEBIAN_FRONTEND=noninteractive dpkg -i /Yandex.deb && rm -f /Yandex.deb ; } || \
  { DEBIAN_FRONTEND=noninteractive apt-get install -f -y -qq && \
  DEBIAN_FRONTEND=noninteractive dpkg -i /Yandex.deb && rm -f /Yandex.deb ; }
  # ---- \end{Install-Yandex-Browser} ------------------
  echo "root:${password}" | chpasswd
  # ----- \begin{non-root-user-section} --------------------------
  adduser --quiet --home /home/${user} --shell /bin/bash --uid ${uid} --disabled-password --gecos "${gecos}" --add_extra_groups ${user}
  echo "${user}:${password}" | chpasswd
  echo -e "\necho \"Your password is: ${password}\" \n" >> /home/${user}/.bashrc
  ln -s /Downloads /home/${user}/Downloads
  chmod +x /home/${user}/genLocalXcookie.sh
  # ----- \end{non-root-user-section} ----------------------------
EOT

# Set up run-time USER and WORKDIR; set up XAUTHORITY for that USER
USER ${user}
WORKDIR /home/${user}
ENV XAUTHORITY=/Xauthority
ENV LANG=ru_RU.UTF-8

# Run bash on the container's start
CMD bash
