Prerequisites: Python 3.12, conda (any version that works with 3.12).
===========================================================================

The suite is intended for **Host (for example, Windows) --> VM (Ubuntu/Debian) setup**

If you have a different setup, it is fully customizable within the repos individually!

If you'd like to start with VM setup, the socat command for port forwarding will be useful for you:
```bash
socat -v TCP-LISTEN:8000,reuseaddr,fork TCP:<IP_to_access_your_VM_from_host>:8000
```
Otherwise, you can also use an SSH tunnel:
```bash
ssh -o AddressFamily=inet -o ExitOnForwardFailure=yes -R 127.0.0.1:8000:localhost:8000 user@VM_IP -p FORWARDED_PORT_FOR_SSH
```

Make sure to read each README.md for each repo! It is recommended to host your models on
**LM Studio,** since it supports **MacOS/Linux/Windows** simultaneously: https://lmstudio.ai/download

**LM Studio** provides a more user-friendly deployment of your local models and allows you to manage
how your GPU and CPU resources are being used and twist the parameters however you like.

**Note:** the setup.sh and other repos have been tested in Ubuntu 22.04 VirtualBox VM environment,
however, it must work with Windows (excluding setup.sh, you'd have to clone and create your conda env manually), MacOS and other Linux distros.

What to expect from this testbed suite?
===========================================================================

This suite includes **AgentDojo, Garak and LocalGuard (Garak + Inspect AI).** The first one allows you to test your AI models
with various attacks and defenses combined, while LocalGuard scans your model with Garak and another Local LLM as a Judge and generates
a pdf report with overall score for your model and security passes/fails. 

**Then why am I including a standalone Garak version?**

Well, that is because 
1. Garak has to parse your responses and requests differently for AI models for each attack, so the **.json i have provided**
should work with all probes that Garak offers.
2. LocalGuard tests only DAN and PrompInjection! With a standalone garak env, you can freely explore
more probes, making sure that your environment doesn't break for all three testing suites. 
