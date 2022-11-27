{% set ohmyzshpath = pillar['ohmyzsh']['path'] %}
{% set kubectlversion = pillar['kubernetes']['kubectl']['version'] %}
{% set kubeadmversion = pillar['kubernetes']['kubeadm']['version'] %}
{% set kubeletversion = pillar['kubernetes']['kubelet']['version'] %}

include:
- ohmyzsh

kubetools_addrepo_kubernetes:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io kubernetes-xenial main
    - file: /etc/apt/sources.list.d/kubernetes.list
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg

kubetools_install_packages:
  pkg.installed:
  - pkgs:
    - kubectl: {{ kubectlversion }}*
  - require:
    - pkgrepo: kubetools_addrepo_kubernetes

kubetools_kubectl_completions:
  file.append:
    - name: {{ ohmyzshpath }}/zshrc
    - text:
      - alias k=kubectl
      - source <(kubectl completion zsh)
      - complete -o default -F __start_kubectl k
    - require:
      - pkg: kubetools_install_packages
