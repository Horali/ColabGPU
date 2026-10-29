# ColabGPU Bridge

Seamlessly connect your local development environment to a remote Google Colab GPU (T4 / A100) via Cloudflare Tunnel (`cloudflared`) and SSH.

## Features
- **GPU Remote Execution**: Run Python scripts, PyTorch/CUDA training, and bash commands directly on Colab from local terminal.
- **Two-way File Transfer**: Push local datasets/scripts and pull model weights/checkpoints with one command.
- **Interactive Shell**: Jump straight into a remote interactive Colab shell.
- **Zero-Password SSH**: Authenticates cleanly via dedicated ed25519 SSH keys.

---

## Quick Setup

### 1. In Google Colab
Run this in a cell to start SSH and the Cloudflare tunnel:

```python
!pip install -q colab_ssh --upgrade
!killall cloudflared 2>/dev/null || true
!mkdir -p /root/.ssh /run/sshd
!echo "<YOUR_LOCAL_PUBLIC_KEY>" > /root/.ssh/authorized_keys
!chmod 600 /root/.ssh/authorized_keys
!/usr/sbin/sshd -p 22

from colab_ssh import launch_ssh_cloudflared
launch_ssh_cloudflared(password="colab123")
```

### 2. On Your Local Machine (PowerShell)
Set your current tunnel hostname:
```powershell
.\colab.ps1 -SetHost <your-subdomain>.trycloudflare.com
```

---

## Usage

### Run Commands on Colab GPU
```powershell
.\colab.ps1 nvidia-smi
.\colab.ps1 python3 /content/check_gpu.py
.\colab.ps1 pip install transformers accelerate
```

### Push / Pull Files
```powershell
# Upload local file to Colab /content/
.\colab.ps1 -Push .\check_gpu.py

# Download remote model/data from Colab to local folder
.\colab.ps1 -Pull /content/checkpoint.pt
```

### Interactive Shell
```powershell
.\colab.ps1
```
