# -*- coding: utf-8 -*-                                                         
# vim: ft=sls                                                                   

{%- if salt['grains.get']('os') == 'Ubuntu' %}
{%- from "vbng-control/map.jinja" import accel_ppp with context %}

accel_ppp_pkgs:
  pkg.installed:
    - pkgs: {{ accel_ppp.pkgs }}

accel_ppp_git:
  file.directory:
    - name: /opt/accel-ppp
    - user: root
    - group: root
    - mode: 755
  git.latest:
    - name: https://github.com/dpdk-vbng-cp/accel-ppp.git
    - target: /opt/accel-ppp
    - user: root
    - branch: redis
    - force_reset: False 
    - force_clone: True
    - require:
      - file: accel_ppp_git

accel_ppp_prepare_build:
  file.directory:
    - name: /opt/accel-ppp/build
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cmake ..
    - cwd: /opt/accel-ppp/build
    - require:
      - file: accel_ppp_prepare_build

accel_ppp_build:
  cmd.run:
    - name: make -j
    - cwd: /opt/accel-ppp/build
    - require: 
      - cmd: accel_ppp_prepare_build

accel_ppp_install:
  cmd.run:
    - name: make install
    - cwd: /opt/accel-ppp/build
    - require:
      - cmd: accel_ppp_build

accel_ppp_conf:
  file.managed:
    - name: /etc/accel-ppp.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - replace: True
    - contents_pillar: accel_ppp:config

accel_ppp_secrets:
  file.managed:
    - name: /etc/ppp/chap-secrets
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - template: jinja
    - contents: |
        intel * bng_admin *

accel_ppp_defaults:
  file.managed:
    - name: /etc/default/accel-ppp
    - source: salt://vbng-control/files/accel-ppp
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - replace: True

accel_ppp_service:
  file.managed:
    - name: /etc/systemd/system/accel-ppp.service
    - source: salt://vbng-control/files/accel-ppp.service
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - replace: True
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: accel_ppp_service
  service.running:
    - name: accel-ppp
    - require:
      - file: accel_ppp_secrets
      - file: accel_ppp_defaults
      - file: accel_ppp_conf
      - file: accel_ppp_service

{%- endif %}
