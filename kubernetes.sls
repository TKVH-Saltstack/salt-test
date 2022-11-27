{% set kubeadmversion = pillar['kubernetes']['kubeadm']['version'] %}
{% set kubeletversion = pillar['kubernetes']['kubelet']['version'] %}

kubernetes_addrepo_kubernetes:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io kubernetes-xenial main
    - file: /etc/apt/sources.list.d/kubernetes.list
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg

kubernetes_install_packages:
  pkg.installed:
  - pkgs:
    - kubeadm: {{ kubeadmversion }}*
    - kubelet: {{ kubeletversion }}*
  - require:
    - pkgrepo: kubernetes_addrepo_kubernetes
