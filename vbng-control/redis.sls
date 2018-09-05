# -*- coding: utf-8 -*-                                                         
# vim: ft=sls                                                                   

{%- if salt['grains.get']('os') == 'Ubuntu' %}

redis_service:
  pkg.installed:
    - pkgs: 
      - redis
    - refresh: True
    - allow_updates: True
  service.running:
    - name: redis
    - enable: True
    - require:
      - pkg: redis_service

{%- endif %}
