# WSL only: sourced from .zshrc when $WSL_DISTRO_NAME is set

# Windows clipboard (WSLg also sets WAYLAND_DISPLAY, but wl-copy doesn't reach Windows apps)
clip() { clip.exe }

# Open a file or directory with the Windows default app (`open .` opens Explorer)
alias open='explorer.exe'
