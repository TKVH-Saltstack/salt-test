{% set ohmyzshpath = pillar['ohmyzsh']['path'] %}
{% set terraformversion = pillar['hashicorp']['terraform']['version'] %}
{% set vaultversion = pillar['hashicorp']['vault']['version'] %}

include:
- ohmyzsh

hashicorptools_addrepo_hashicorp:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com focal main
    - file: /etc/apt/sources.list.d/hashicorp.list
    - key_url: https://apt.releases.hashicorp.com/gpg

hashicorpstools_install_packages:
  pkg.installed:
  - pkgs:
    - terraform: {{ terraformversion }}*
    - vault: {{ vaultversion }}*
  - require:
    - pkgrepo: hashicorptools_addrepo_hashicorp

hashicorptools_terraform_completions:
  file.append:
  - name: {{ ohmyzshpath }}/zshrc
  - text:
    - complete -o nospace -C /usr/bin/terraform terraform
  - require:
    - pkg: hashicorpstools_install_packages

hashicorptools_vault_completions:
  file.append:
  - name: {{ ohmyzshpath }}/zshrc
  - text:
    - complete -C /usr/bin/vault vault
  - require:
    - pkg: hashicorpstools_install_packages
