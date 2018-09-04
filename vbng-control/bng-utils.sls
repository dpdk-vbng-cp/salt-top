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

{%- endif %}
