# Maintainer: ShedOS <https://github.com/Theshedman/shedos>
#
# The four Catppuccin Mocha palettes ShedOS ships, as data. The engine that
# renders them is shedos-theme-engine; nothing here is executable, and a theme
# package is exactly this shape.

pkgname=shedos-theme-catppuccin
pkgver=2026.08.09
pkgrel=1
pkgdesc='Catppuccin Mocha palettes for the ShedOS theme engine'
arch=('any')
url='https://github.com/shed-os/shedos-theme-catppuccin'
license=('GPL-3.0-or-later')

optdepends=(
    'catppuccin-gtk-theme-mocha: the GTK themes these palettes name'
)

source=("git+https://github.com/shed-os/shedos-theme-catppuccin.git#tag=$pkgver")
sha256sums=('SKIP')

package() {
    cd "$srcdir/shedos-theme-catppuccin"

    local _file
    for _file in tree/usr/share/shedos/themes/palettes/*.toml \
                 tree/usr/share/shedos/themes/metadata/*.toml; do
        install -Dm644 "$_file" "$pkgdir/${_file#tree/}"
    done
}
