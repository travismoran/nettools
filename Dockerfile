FROM ubuntu:24.04

LABEL maintainer="Travis Moran"
LABEL description="Secure minimal nettools image for Kubernetes network troubleshooting"

ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user for running the container
RUN groupadd -r nettools && useradd -r -g nettools nettools

# Install only essential network troubleshooting tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        dnsutils \
        iputils-ping \
        net-tools \
        iproute2 \
        tcpdump \
        nmap \
        netcat-openbsd \
        traceroute \
        jq \
        vim-tiny \
        nano && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Kubernetes debugging tools (process inspection only)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        strace \
        lsof \
        lsb-release && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove package managers to prevent tool installation
# This is the primary security lock - without package managers, no new tools can be installed
RUN rm -rf /usr/bin/apt-get /usr/bin/apt /usr/bin/dpkg /usr/bin/apt-mark /usr/bin/apt-cache && \
    rm -rf /etc/apt /var/lib/apt

# Remove shell interpreters except dash (minimal shell)
RUN rm -f /bin/bash /bin/sh && \
    ln -s /bin/dash /bin/sh

# Remove write permissions on sensitive directories to prevent modifications
RUN chmod 555 /usr/local/bin /usr/bin /bin /etc && \
    find /usr -type f \( -perm /u+s -o -perm /g+s \) 2>/dev/null | xargs chmod -s 2>/dev/null || true

# Switch to non-root user
USER nettools

# Set a basic prompt
ENV PS1='nettools$ '

# Add helpful information
RUN mkdir -p /home/nettools && \
    echo "# Secure Nettools Image" > /home/nettools/README.md && \
    echo "## Available Tools" >> /home/nettools/README.md && \
    echo "- curl/wget: HTTP requests and file downloads" >> /home/nettools/README.md && \
    echo "- nmap: Network scanning and service discovery" >> /home/nettools/README.md && \
    echo "- netcat-openbsd: Network connections and data transfer" >> /home/nettools/README.md && \
    echo "- dig/nslookup: DNS queries" >> /home/nettools/README.md && \
    echo "- ping/traceroute: ICMP diagnostics" >> /home/nettools/README.md && \
    echo "- tcpdump: Packet capture and analysis" >> /home/nettools/README.md && \
    echo "- strace/lsof: Process and file descriptor analysis" >> /home/nettools/README.md && \
    echo "- jq: JSON query and manipulation" >> /home/nettools/README.md

EXPOSE 10000-20000

# Use dash instead of bash - minimal shell
CMD ["/bin/dash"]
