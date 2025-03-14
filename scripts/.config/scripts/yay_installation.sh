sudo pacman -S --needed git base-devel && \
tmpdir=$(mktemp -d) && \
git clone https://aur.archlinux.org/yay.git "$tmpdir" && \
cd "$tmpdir" && \
makepkg -si && \
cd - && \
rm -rf "$tmpdir"
