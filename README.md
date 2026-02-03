===========================================================================

The suite is intended for **Host (for example, Windows) --> VM (Ubuntu/Debian) setup**

If you have a different setup, it is fully customizable within the repos individually!

If you'd like to start with VM setup, the socat command for port forwarding will be useful for you:
```bash
socat -v TCP-LISTEN:8000,reuseaddr,fork TCP:<IP_to_access_your_VM_from_host>:8000
```
Otherwise, you can also use an SSH tunnel.

Make sure to read each README.md for each repo! It is recommended to host your models on
**LM Studio,** since it supports **MacOS/Linux/Windows** simultaneously: https://lmstudio.ai/download

**LM Studio** provides a more user-friendly deployment of your local models and allows you to manage
how your GPU and CPU resources are being used and twist the parameters however you like.

**Note:** the setup.sh and other repos has been tested in Ubuntu 22.04 VirtualBox VM environment,
however, it must work with Windows (excluding setup.sh, you'd have to clone and create your conda env manually), MacOS and other Linux distros.

===========================================================================
