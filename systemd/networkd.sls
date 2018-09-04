{% from "systemd/map.jinja" import systemd with context %}

systemd_networkd_pkgs:
  pkg.installed:
    - pkgs: 
      - pciutils
    - refresh: True
    - allow_updates: True

{%- for name, params in systemd.networkd.configs.items() %}
systemd_networkd_config_{{name}}:
  file.managed:
    - name: /etc/systemd/network/{{name}}
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - replace: True
    - contents_pillar: systemd:networkd:configs:{{name}}
    - require:
      - pkg: systemd_networkd_pkgs
{%- endfor %}

systemd_networkd_service:
  service.running:
    - name: systemd-networkd
    - enable: True
    - require:
      - pkg: systemd_networkd_pkgs
{%- for name, params in systemd.networkd.configs.items() %}
      - file: systemd_networkd_config_{{name}}
{%- endfor %}
  cmd.run:
    - name: systemctl restart systemd-networkd
    - require:
      - service: systemd_networkd_service
    - onchanges:
      - pkg: systemd_networkd_pkgs
{%- for name, params in systemd.networkd.configs.items() %}
      - file: systemd_networkd_config_{{name}}
{%- endfor %}
