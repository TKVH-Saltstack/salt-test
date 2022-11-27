{% set admins = pillar['admins'] %}

{% for admin in admins %}
admin_config_{{ admin }}:
  user.present:
    - name: {{ admin }}
    - groups:
      - sudo
ssh_authorized_config_{{ admin }}:
  file.append:
    - name: /home/{{ admin }}/.ssh/authorized_keys
    - makedirs: True
    - sources:
      - salt://ssh_authorized_keys/{{ admin }}.pub 
{% endfor %}
