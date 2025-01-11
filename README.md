# Silver-ZSH
> #### Scripts, configs and extras for ZSH

---
## Dependencies:
**Ubuntu / Debian:** `sudo apt install zsh zoxide` \
**Arch:** `sudo pacman -S zsh zoxide` \
**Alpine:** `sudo apk add zsh && sudo apk add cargo && cargo install zoxide` \
**RedHat:** `sudo yum install zsh && sudo yum install rust cargo && cargo install zoxide` \
**Fedora:** `sudo dnf install zsh zoxide`

---

## Configs:
> **Minimal** (Entropy v9) \
![image](https://github.com/user-attachments/assets/5d50c03f-8303-418c-b736-fcc2ed1bce93)

---

## Install
> `config/minimal` as example \
> Backup old config (optional):
```bash
cd &&mv .zshrc .zshrc-old && mv .p10k.zsh .p10k.zsh-old
```
> Install Configs:
```bash
cd && wget https://raw.githubusercontent.com/serainox420/Silver-ZSH/refs/heads/personal/config/.zshrc && wget https://raw.githubusercontent.com/serainox420/Silver-ZSH/refs/heads/personal/config/.p10k.zsh && source .zshrc
```
> Set ZSH as default shell:
```bash
chsh -s /bin/zsh
```

---
