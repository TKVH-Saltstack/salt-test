{% set ohmyzshpath = pillar['ohmyzsh']['path'] %}
{% set saltminionversion = pillar['salt']['minion']['version'] %}

saltminion_addrepo_saltstack:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltproject.io/salt/py3/debian/11/amd64/latest/salt-archive-keyring.gpg

saltminion_install_packages:
  pkg.installed:
  - pkgs:
    - salt-minion: {{ saltminionversion }}*
  - require:
    - pkgrepo: saltminion_addrepo_saltstack

saltminion_create_minionconf:
  file.managed:
    - name: /etc/salt/minion.d/minion.conf

saltminion_install_minionconf:
  file.keyvalue:
    - name: /etc/salt/minion.d/minion.conf
    - key_values:
        master: '192.168.1.139'
        startup_states: 'highstate'
        master_finger: 'f6:8f:93:f8:bd:b8:29:38:93:3a:bc:a8:f8:da:10:01:7d:1f:c4:2a:ea:14:cd:bc:d8:be:17:44:c0:1c:79:79'
    - separator: ': '
    - append_if_not_found: True
    - require:
      - pkg: saltminion_install_packages

saltminion_refresh_service:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - file: saltminion_install_minionconf
      - pkg: saltminion_install_packages
