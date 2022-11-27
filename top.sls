base:
  '*':
    - saltminion
    - users 
    - ohmyzsh
    - tools
  '*workshop*':
    - kubetools
    - hashicorptools
  '*saltmaster*':
    - saltmaster
