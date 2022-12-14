{% set ohmyzshpath = pillar['ohmyzsh']['path'] %}
{% set saltmasterversion = pillar['salt']['master']['version'] %}

saltmaster_addrepo_saltstack:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltproject.io/salt/py3/debian/11/amd64/latest/salt-archive-keyring.gpg

saltmaster_install_packages:
  pkg.installed:
  - pkgs:
    - salt-master: {{ saltmasterversion }}*
  - require:
    - pkgrepo: saltmaster_addrepo_saltstack

saltmaster_install_modules:
  pip.installed:
    - name: pygit2
    - require:
      - pkg: saltmaster_install_packages

saltmaster_create_masterconf:
  file.managed:
    - name: /etc/salt/master.d/master.conf

saltmaster_install_masterconf:
  file.managed:
    - name: /etc/salt/master.d/master.conf
    - contents: |
        auto_accept: True
        fileserver_backend:
        - gitfs
        gitfs_remotes: 
        - https://github.com/TKVH-Saltstack/salt-test.git
        gitfs_update_interval: 10
        ext_pillar: 
        - git: 
          - master https://github.com/TKVH-Saltstack/salt-pillar.git
    - require:
      - pkg: saltmaster_install_packages

saltmaster_refresh_service:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: saltmaster_install_masterconf
      - pkg: saltmaster_install_packages
