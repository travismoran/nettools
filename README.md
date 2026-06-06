# Secure Minimal Nettools

A lightweight, security-hardened container image designed for network troubleshooting and diagnostics in Kubernetes environments. Built with minimal attack surface and locked-down permissions for safe deployment in corporate environments.

## Overview

This image provides essential network troubleshooting tools without the overhead or security risks of traditional full-featured debugging containers. It's designed to be:

- **Minimal**: Only tools needed for network diagnostics
- **Secure**: Hardened against privilege escalation and unauthorized modifications
- **Locked Down**: No package managers to prevent tool installation
- **Non-root**: Runs as unprivileged user by default
- **Corporate-safe**: No penetration testing or attack tools included

## Security Features

### Hardening Measures

- **Non-root user execution** - Container runs as `nettools` user, not root
- **No package managers** - `apt-get`, `apt`, `dpkg`, `apt-cache`, `apt-mark` removed
- **No apt configuration** - `/etc/apt` directory removed to prevent package sources
- **Minimal shell** - `dash` only (bash removed) to reduce attack surface
- **Read-only system directories** - `/bin`, `/usr/bin`, `/usr/local/bin`, `/etc` set to read-only (555 permissions)
- **SUID/SGID removal** - All setuid/setgid bits removed from binaries
- **Immutable image** - No way to install new tools or modify the environment

### What's NOT Included (By Design)

- ❌ `kubectl` - prevents cluster API access and privilege escalation
- ❌ Package managers - prevents unauthorized tool installation
- ❌ Penetration tools - `masscan`, `hydra`, `metasploit`, `sqlmap`, `nikto`
- ❌ Bash shell - minimal shell only (`dash`)
- ❌ sudo/privilege escalation tools

## Available Tools

### Network Diagnostics

| Tool | Purpose | Example |
|------|---------|---------|
| `ping` | ICMP connectivity tests | `ping 8.8.8.8` |
| `traceroute` | Route path analysis | `traceroute example.com` |
| `dig` | DNS queries and resolution | `dig example.com` |
| `nslookup` | DNS lookup tool | `nslookup example.com 8.8.8.8` |
| `netcat-openbsd` | Network connections and data transfer | `nc -zv example.com 443` |
| `nmap` | Network scanning and port enumeration | `nmap -p 80,443 10.0.0.0/24` |
| `tcpdump` | Packet capture and analysis | `tcpdump -i eth0 -n 'tcp port 80'` |

### Data Transfer

| Tool | Purpose | Example |
|------|---------|---------|
| `curl` | HTTP/HTTPS requests | `curl -v https://example.com` |
| `wget` | File download utility | `wget https://example.com/file.tar.gz` |

### System/Process Analysis

| Tool | Purpose | Example |
|------|---------|---------|
| `strace` | System call tracing | `strace -p <PID>` |
| `lsof` | List open files and connections | `lsof -i -P -n` |

### Data Processing

| Tool | Purpose | Example |
|------|---------|---------|
| `jq` | JSON query and manipulation | `curl https://api.example.com \| jq '.data'` |

### System Information

| Tool | Purpose | Example |
|------|---------|---------|
| `ifconfig`/`ip` | Network interface configuration | `ip addr show` |
| `netstat`/`ss` | Network statistics | `ss -tlnp` |
| `route` | Routing table information | `route -n` |

## Usage Examples

### Basic DNS Lookup
```bash
docker run --rm travismoran/nettools dig google.com
docker run --rm travismoran/nettools nslookup google.com 8.8.8.8
```

### Test HTTP Connectivity
```bash
docker run --rm travismoran/nettools curl -v https://example.com
docker run --rm travismoran/nettools curl -I https://example.com
```

### Network Port Scanning
```bash
docker run --rm travismoran/nettools nmap -p 80,443 example.com
docker run --rm travismoran/nettools nmap -sV -p 22,80,443 10.0.0.1
```

### Check Network Connectivity
```bash
docker run --rm travismoran/nettools ping -c 4 8.8.8.8
docker run --rm travismoran/nettools traceroute example.com
```

### Test Specific Port
```bash
docker run --rm travismoran/nettools nc -zv example.com 443
docker run --rm travismoran/nettools nc -zv 10.0.0.1 3306
```

### Interactive Shell Session
```bash
docker run --rm -it travismoran/nettools
# Now you're in a dash shell where you can run multiple commands
```

### Packet Capture
```bash
docker run --rm --cap-add=NET_ADMIN --cap-add=SYS_PTRACE travismoran/nettools \
  tcpdump -i eth0 -n 'tcp port 80'
```

### Process Analysis
```bash
docker run --rm --cap-add=SYS_PTRACE travismoran/nettools lsof -i -P -n
docker run --rm --cap-add=SYS_PTRACE travismoran/nettools strace -e network -p 1
```

### JSON API Response Processing
```bash
docker run --rm travismoran/nettools \
  sh -c "curl -s https://api.example.com/data | jq '.items[] | .name'"
```

## Kubernetes Deployment

### One-off Diagnostic Pod (Auto-cleanup)

Deploy a temporary debugging pod that automatically deletes when the command completes:

```bash
kubectl run -it --rm --image=travismoran/nettools --restart=Never \
  nettools-debug -- dig myservice.default.svc.cluster.local
```

### Interactive Troubleshooting Session

```bash
kubectl run -it --rm --image=travismoran/nettools --restart=Never \
  nettools-debug
```

This will open an interactive shell. When you exit or your connection times out, the pod is automatically deleted.

### DNS Resolution Testing

```bash
kubectl run -it --rm --image=travismoran/nettools --restart=Never \
  nettools-debug -- dig kubernetes.default.svc.cluster.local
```

### Service Connectivity Check

```bash
kubectl run -it --rm --image=travismoran/nettools --restart=Never \
  nettools-debug -- nc -zv myservice.mynamespace.svc.cluster.local 8080
```

### Network Policy Testing

```bash
kubectl run -it --rm --image=travismoran/nettools --restart=Never \
  --labels="app=nettools" nettools-debug -- curl -v http://target-service:8080
```

### Within a Pod (sidecar-style debugging)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug-pod
spec:
  containers:
  - name: app
    image: myapp:latest
  - name: nettools
    image: travismoran/nettools:latest
    imagePullPolicy: Always
    stdin: true
    tty: true
```

Then attach to the nettools container:
```bash
kubectl attach debug-pod -c nettools -i -t
```

### Persistent Debug Pod (Manual Cleanup)

If you need to keep a pod running for extended troubleshooting:

```bash
kubectl run --image=travismoran/nettools --restart=Never \
  nettools-debug -- sleep infinity
```

Connect with:
```bash
kubectl exec -it nettools-debug -- /bin/dash
```

Delete when done:
```bash
kubectl delete pod nettools-debug
```

## Network Capabilities

By default, the image includes standard network capabilities. For advanced packet capture or system tracing, mount additional Linux capabilities:

```bash
kubectl run -it --rm --image=travismoran/nettools --restart=Never \
  --cap-add=NET_ADMIN --cap-add=SYS_PTRACE nettools-debug
```

## Performance

The image is approximately **80-100 MB**, much smaller than full debugging images, making it:
- Faster to pull and start
- Suitable for quick container startup
- Efficient for large-scale deployments

## Limitations

- **No shell history** - Minimal environment, no history persistence
- **No package installation** - Cannot install additional tools (by design)
- **No elevated privileges** - Runs as non-root user
- **No Kubernetes API access** - kubectl is intentionally excluded
- **No compilation tools** - No gcc, make, or build utilities

## Support

This image is designed for network diagnostics and troubleshooting. For Kubernetes-specific issues, use dedicated debugging tools like `kubectl debug` in Kubernetes 1.23+.
