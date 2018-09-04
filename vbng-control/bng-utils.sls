# -*- coding: utf-8 -*-                                                         
# vim: ft=sls                                                                   

{%- if salt['grains.get']('os') == 'Ubuntu' %}

bng_utils_git:
  file.directory:
    - name: /opt/bng-utils
    - user: root
    - group: root
    - mode: 755
  git.latest:
    - name: https://github.com/dpdk-vbng-cp/bng-utils.git
    - target: /opt/bng-utils
    - user: root
    - branch: master
    - force_reset: False 
    - force_clone: True
    - require:
      - file: bng_utils_git

bng_utils_config:
  file.managed:
    - name: /etc/default/redis-connector
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - replace: True
    - contents_pillar: bng_utils:config

bng_utils_service:
  file.managed:
    - name: /etc/systemd/system/redis-connector.service
    - source: salt://vbng-control/files/redis-connector.service
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - replace: True
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: bng_utils_service
  service.running:
    - name: redis-connector
    - require:
      - file: bng_utils_config
      - file: bng_utils_service

{%- endif %}
