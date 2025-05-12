FROM ubuntu:22.04

LABEL maintainer="Travis Moran"

ENV DEBIAN_FRONTEND=noninteractive

# Install core networking/debugging and utility tools
RUN apt-get update -y && \
    apt-get install -y \
        bash-completion command-not-found mtr-tiny dnsutils net-tools \
        nmap traceroute netcat iproute2 tcpdump iputils-ping isc-dhcp-client \
        openssh-client tmux screen vim nano \
        curl wget sipsak supervisor gnupg lsb-release unzip software-properties-common git && \
    apt-get clean -qy

# Copy supervisor configuration
COPY conf/interactive_shell.conf /etc/supervisor/conf.d/interactive_shell.conf

# Add bash prompt customization
SHELL ["/bin/bash","-c"]
RUN echo 'PS1="\[\033[35m\]\t \[\033[32m\]\h\[\033[m\]:\[\033[33;1m\]\w\[\033[m\] # "' >> /root/.bashrc

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y azure-cli && \
    rm microsoft.gpg

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install k9s
RUN K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" && \
    tar -xzf k9s.tar.gz && \
    mv k9s /usr/local/bin/k9s && \
    rm k9s.tar.gz

# Install kustomize
RUN KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | grep '"tag_name":' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+') && \
    curl -Lo kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" && \
    tar -xzf kustomize.tar.gz && \
    mv kustomize /usr/local/bin/kustomize && \
    rm kustomize.tar.gz

# Install Flux CLI
RUN FLUX_VERSION=$(curl -s https://api.github.com/repos/fluxcd/flux2/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -sL "https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_linux_amd64.tar.gz" -o flux.tar.gz && \
    tar -xzf flux.tar.gz && \
    mv flux /usr/local/bin/flux && \
    rm flux.tar.gz


# Add enhanced Bash prompt with kube context and autocomplete
RUN cat <<EOT >> /root/.bashrc

# Enable bash completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# kubectl completion
source <(kubectl completion bash)

# flux completion
flux completion bash > /etc/bash_completion.d/flux

# Show current kube context in the prompt
function kube_ps1() {
  CONTEXT=$(kubectl config current-context 2>/dev/null)
  if [ -n "$CONTEXT" ]; then
    echo "[k8s:$CONTEXT] "
  fi
}

export PS1="\[\033[35m\]\t \[\033[32m\]\h\[\033[m\]:\[\033[33;1m\]\w\[\033[m\] \$(kube_ps1)# "

EOT

# Expose a wide range of ports for debugging and testing
EXPOSE 10000-20000

# Default command runs supervisord with interactive shell config
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/interactive_shell.conf"]
