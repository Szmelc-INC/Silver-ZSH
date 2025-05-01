pkgname=silver-zsh
pkgver=1.0
pkgrel=1
pkgdesc="Preconfigured ZSH setup with Powerlevel10k and optional Better-RunCommand"
arch=('any')
url="https://github.com/Szmelc-INC/Silver-ZSH"
license=('MIT')
depends=('zsh' 'git' 'xclip' 'fzf' 'zoxide' 'curl')
optdepends=(
  'neovim: for vim alias'
  'lsd: better ls output'
  'xclip: required for copy/paste functions'
  'curl: used in weather function'
)
install=silver-zsh.install
source=(
  'setup-silver-zsh'
)
sha256sums=('SKIP')

package() {
  install -Dm755 setup-silver-zsh "$pkgdir/usr/bin/setup-silver-zsh"
}
