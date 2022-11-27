{% set admins = pillar['admins'] %}
{% set ohmyzshpath = pillar['ohmyzsh']['path'] %}

ohmyzsh_install_packages:
  pkg.installed:
    - pkgs:
      - zsh
      - git
      - neofetch
      - fonts-firacode
      - fonts-powerline
      - curl
      - unzip

ohmyzsh_download_installer:
  file.managed:
    - name: /opt/install.sh
    - mode: 755
    - source: https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    - skip_verify: True
    - require:
      - pkg: ohmyzsh_install_packages

ohmyzsh_install_ohmyzsh:
  cmd.run:
    - name: if [[ $(/opt/install.sh) == *"folder already exists"* ]]; then echo changed=no; elif [[ $(/opt/install.sh) == *"is now installed!"* ]]; then echo changed=yes; fi
    - cwd: /opt/
    - env:
      - ZSH: {{ ohmyzshpath }}
      - KEEP_ZSHRC: yes
    - stateful: True
    - require:
      - file: ohmyzsh_download_installer

ohmyzsh_completions_directory:
  file.directory:
    - name: {{ ohmyzshpath }}/cache/completions
    - makedirs: True
    - mode: 777
    - require:
      - cmd: ohmyzsh_install_ohmyzsh

ohmyzsh_install_spaceshiptheme:
  git.cloned:
    - name: https://github.com/spaceship-prompt/spaceship-prompt.git
    - target: "{{ ohmyzshpath }}/custom/themes/spaceship-prompt"
    - require:
      - cmd: ohmyzsh_install_ohmyzsh

ohmyzsh_enable_spaceshiptheme:
  file.symlink:
    - name: {{ ohmyzshpath }}/custom/themes/spaceship.zsh-theme
    - target: {{ ohmyzshpath }}/custom/themes/spaceship-prompt/spaceship.zsh
    - require:
      - git: ohmyzsh_install_spaceshiptheme

ohmyzsh_install_zshrc:
  file.append:
    - name: {{ ohmyzshpath }}/zshrc
    - text: |
        # oh-my-zsh
        ZSH="{{ ohmyzshpath }}"
        ZSH_THEME="spaceship"
        DISABLE_AUTO_UPDATE="true"
        DISABLE_MAGIC_FUNCTIONS="true"
        DISABLE_AUTO_TITLE="true"
        ENABLE_CORRECTION="true"
        plugins=(git)
        export EDITOR='vim'
        ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
        if [[ ! -d $ZSH_CACHE_DIR ]]; then
          mkdir -p $ZSH_CACHE_DIR
        fi
        source $ZSH/oh-my-zsh.sh
        # spaceship zsh theme
        SPACESHIP_DIR_TRUNC=0
        SPACESHIP_TIME_SHOW=true
        SPACESHIP_USER_SHOW=always
        SPACESHIP_HOST_SHOW=always
        SPACESHIP_KUBECTL_SHOW=true
        # Misc
        export LC_ALL=$LANG
        alias ll="ls -hlt"
        alias l="ls -halt"
        neofetch
    - require:
      - pkg: ohmyzsh_install_packages

### Change shell to zsh for main users
{% for admin in admins %}
chsh_{{ admin }}:
  user.present:
    - name: {{ admin }}
    - shell: /bin/zsh
    - require:
      - pkg: ohmyzsh_install_packages 
{% endfor %}

### Append generic .zshrc to users
{% for admin in admins %}
ohmyzsh_zshrc_{{ admin }}:
  file.append:
    - name: /home/{{ admin }}/.zshrc
    - text:
      - source {{ ohmyzshpath }}/zshrc
    - require:
      - file: ohmyzsh_install_zshrc
{% endfor %}
