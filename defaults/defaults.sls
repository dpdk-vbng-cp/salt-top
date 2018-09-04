# -*- coding: utf-8 -*-                                                         
# vim: ft=sls                                                                   

{%- if salt['grains.get']('os') == 'Ubuntu' %}
{%- from "defaults/map.jinja" import default with context %}

default_pkgs:
  pkg.installed:
    - pkgs: {{ default.pkgs }}

{%- endif %}
