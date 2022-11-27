tools_install_packages:
  pkg.installed:
  - pkgs:
    - sudo
    - vim
    - openssh-server
    - curl
    - wget
    - netcat

tools_sudo_config:
  file.append:
    - name: /etc/sudoers
    - text: 
      - "%sudo   ALL=(ALL:ALL) ALL"
      - "%sudo   ALL=(ALL) NOPASSWD: ALL"
    - require:
      - pkg: tools_install_packages

tools_sshd_config:
  file.keyvalue:
    - name: /etc/ssh/sshd_config
    - key_values: 
        PermitRootLogin: 'no'
        PasswordAuthentication: 'no'
    - separator: ' '
    - uncomment: '# '
    - append_if_not_found: True
    - require:
      - pkg: tools_install_packages
