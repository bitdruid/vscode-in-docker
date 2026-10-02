FROM jlesage/baseimage-gui:ubuntu-26.04-v4.14

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

# Packages are installed via the base image's add-pkg: /etc/passwd is generated at
# runtime, so it provides a temporary user database for postinst scripts and cleans
# up apt caches afterwards. Plain apt-get fails here ("invalid user: root:root").
RUN add-pkg ca-certificates curl gpg sudo git gh nano fonts-firacode \
        libx11-xcb1 libxcb-dri3-0 libdrm2 libgbm1 libasound2t64

# VS Code, via the same script that updates it on container start (see 60-autoupdate.sh).
COPY --chmod=755 rootfs/usr/local/bin/vscode-update /usr/local/bin/vscode-update
RUN vscode-update

# zsh with oh-my-zsh, powerlevel10k and plugins, staged in /etc/skel and copied into
# the home on first start (see 50-app-home.sh). MesloLGS NF is the p10k-patched font.
RUN add-pkg zsh fontconfig \
    && git clone -q --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh \
    && for p in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do \
        git clone -q --depth=1 "https://github.com/zsh-users/$p.git" "/etc/skel/.oh-my-zsh/custom/plugins/$p"; \
    done \
    && git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/skel/.oh-my-zsh/custom/themes/powerlevel10k \
    && mkdir -p /usr/share/fonts/truetype/meslo \
    && for f in Regular Bold Italic "Bold Italic"; do \
        curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$(echo "$f" | sed 's/ /%20/g').ttf" \
            -o "/usr/share/fonts/truetype/meslo/MesloLGS NF $f.ttf"; \
    done \
    && fc-cache -f

# Passwordless sudo for the baseimage 'app' user.
RUN printf 'app ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/app \
    && chmod 0440 /etc/sudoers.d/app

# Startup script, cont-init hooks, vscode-update helper, home skeleton.
COPY rootfs/ /
RUN chmod +x /startapp.sh /etc/cont-init.d/*.sh /usr/local/bin/*

# Give 'app' a real home instead of /config. The XDG_* defaults of the base image
# point into /config/xdg; move them into the home so everything lives in one place.
RUN set-cont-env APP_NAME "Code" \
    && set-cont-env HOME /home/app \
    && set-cont-env XDG_CONFIG_HOME /home/app/.config \
    && set-cont-env XDG_DATA_HOME /home/app/.local/share \
    && set-cont-env XDG_STATE_HOME /home/app/.local/state \
    && set-cont-env XDG_CACHE_HOME /home/app/.cache

EXPOSE 5800 5900
