![Animated SVG](https://raw.githubusercontent.com/serainox420/serainox420/refs/heads/personal/STUFF/silver-zsh.svg)
### **<p align="center">┏ Scripts, configs and extras for ZSH ┓</p>**

---
# Dependencies:
**Ubuntu / Debian:** `sudo apt install zsh zoxide git fzf` \
**Arch:** `sudo pacman -S zsh zoxide git fzf` \
**Alpine:** `sudo apk add zsh git && sudo apk add cargo && cargo install zoxide fzf` \
**RedHat:** `sudo yum install zsh git && sudo yum install rust cargo && cargo install zoxide fzf` \
**Fedora:** `sudo dnf install zsh zoxide git fzf`

---

# Configs:
> **Minimal** (Entropy v9) \
![image](https://github.com/user-attachments/assets/5d50c03f-8303-418c-b736-fcc2ed1bce93)

---

# Install
> `config/minimal` as example \
> Backup old config (optional):
```bash
cd &&mv .zshrc .zshrc-old && mv .p10k.zsh .p10k.zsh-old
```
> Install Configs:
```bash
cd && wget https://raw.githubusercontent.com/serainox420/Silver-ZSH/refs/heads/personal/config/minimal/.zshrc && wget https://raw.githubusercontent.com/serainox420/Silver-ZSH/refs/heads/personal/config/minimal/.p10k.zsh && source .zshrc
```
> To install different configs, replace `/minimal/` in URL with correct config folder name

> Set ZSH as default shell:
```bash
chsh -s /bin/zsh
```

---
