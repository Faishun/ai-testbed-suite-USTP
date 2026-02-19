AI Testbed Suite
===========================================================================

Ubuntu/Debian machine recommended for this setup!

If you'd like to start with VM setup, the socat command for port forwarding will be useful for you:
```bash
socat -v TCP-LISTEN:8000,reuseaddr,fork TCP:<IP_to_access_your_VM_from_host>:8000
```
Otherwise, you can also use an SSH tunnel:
```bash
ssh -o AddressFamily=inet -o ExitOnForwardFailure=yes -R 127.0.0.1:8000:localhost:8000 user@VM_IP -p FORWARDED_PORT_FOR_SSH
```

This suite was tested with **LM Studio,** since it supports **MacOS/Linux/Windows** simultaneously. Download it to start seamlessly: https://lmstudio.ai/download

**LM Studio** provides a more user-friendly deployment of your local models and allows you to manage
how your GPU and CPU resources are being used and twist the parameters however you like.

**Note:** setup.sh is for normal installation, after which run.sh must be run. If you conda env is broken, run setup_test.sh
**all.sh** script is all-in-one, running setup.sh and rush.sh after it for one-shot installation.

What to expect from this testbed suite?
===========================================================================

This suite includes **AgentDojo, Garak, Augustus (Garak Alternative) and LocalGuard (Garak + Inspect AI).** The web interface integration allows you to
monitor your results way easier and download them on the fly.
