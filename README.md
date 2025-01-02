# nettools

docker run -it ghcr.io/travismoran/nettools:main bash

```
bash-completion   - to make bash tab completion better
command-not-found - when you type a command that doesn't exist, it informs you of which package a command is in
mtr-tiny      - fast and easy to read realtime traceroutes for both IPv4 and IPv6 (tiny version skips all the GTK bloat)
dnsutils      - provides tools such as `dig` and `nslookup` for DNS debugging
net-tools     - basic networking tools such as `ifconfig`, `netstat`, `route`, `arp`
nmap          - port scanning and other network reconnaissance
traceroute    - self explanatory. alternative to `mtr`
netcat        - `nc` tool. highly versatile TCP/UDP/unixsocket client and server
iproute2      - provides the `ip` and `bridge` tools for advanced network configs
tcpdump       - similar to wireshark, but CLI based. for inspecting network packets
iputils-ping  - for the `ping` command. supports both IPv4 and v6 in the same binary, instead of `ping` + `ping6`
openssh       - server and client. for testing ssh connectivity, and so you may ssh into the container for a better experience
tmux          - run multiple things in one terminal session, with tabs and split windows
screen        - similar to tmux, for running things in the background
vim/nano      - for times when you need a text editor. remember! don't expect files on a container to be persisted. use a volume.
curl          - curl is a tool for transferring data from or to a server using URLs
wget          - GNU Wget is a free utility for non-interactive download of files from the Web
sipsak        - sipsak is a SIP stress and diagnostics utility
```
