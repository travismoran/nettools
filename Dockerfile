FROM ubuntu:22.04

MAINTAINER Travis Moran

####
#
# Docker Networking Toolkit
#


####
# Packages included
####
# bash-completion   - to make bash tab completion better
# command-not-found - when you type a command that doesn't exist, it informs you of which package a command is in
# mtr-tiny      - fast and easy to read realtime traceroutes for both IPv4 and IPv6 (tiny version skips all the GTK bloat)
# dnsutils      - provides tools such as `dig` and `nslookup` for DNS debugging
# net-tools     - basic networking tools such as `ifconfig`, `netstat`, `route`, `arp`
# nmap          - port scanning and other network reconnaissance
# traceroute    - self explanatory. alternative to `mtr`
# netcat        - `nc` tool. highly versatile TCP/UDP/unixsocket client and server
# iproute2      - provides the `ip` and `bridge` tools for advanced network configs
# tcpdump       - similar to wireshark, but CLI based. for inspecting network packets
# iputils-ping  - for the `ping` command. supports both IPv4 and v6 in the same binary, instead of `ping` + `ping6`
# openssh       - server and client. for testing ssh connectivity, and so you may ssh into the container for a better experience
# tmux          - run multiple things in one terminal session, with tabs and split windows
# screen        - similar to tmux, for running things in the background
# vim/nano      - for times when you need a text editor. remember! don't expect files on a container to be persisted. use a volume.
# curl          - curl is a tool for transferring data from or to a server using URLs
# wget          - GNU Wget is a free utility for non-interactive download of files from the Web
# sipsak        - sipsak is a SIP stress and diagnostics utility

RUN apt-get update -y && \
    apt-get install -y bash-completion command-not-found mtr-tiny dnsutils net-tools && \
    apt-get install -y nmap traceroute netcat iproute2 tcpdump iputils-ping isc-dhcp-client && \
    apt-get install -y openssh-client tmux screen vim nano && \
    apt-get install -y curl wget sipsak && \
    apt-get clean -qy

# More readable bash prompt, with timestamp and colours
# Plus set up SSH, with default root pass of 'net'
SHELL ["/bin/bash","-c"]
RUN echo 'PS1="\[\033[35m\]\t \[\033[32m\]\h\[\033[m\]:\[\033[33;1m\]\w\[\033[m\] # "' >> /root/.bashrc


# Ports 10000 to 20000 are exposed for general use in network debugging
# For example, listening on port 10100 with `nc` and connecting to it from
# outside of the container, to test connectivity

EXPOSE 10000-20000

ENTRYPOINT ["tail", "-f", "/dev/null"]