{% from "defaults/map.jinja" import default with context %}


{% for module, params in default.kernel.modules.items() %}

{% if 'options' in params %}
kmod_{{module}}_options_file:
  file.managed:
    - name: /etc/modprobe.d/{{module}}.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - contents: |
        # Module {{module}} options
{% for optkey, optval in params.get('options', {}).items() %}
        options {{module}} {{optkey}}={{optval}}
{% endfor %}
{% endif %}


kmod_{{module}}:
  pkg.installed:
    - pkgs:
      - git
    - refresh: True
    - allow_updates: True
  kmod.present:
    - name: {{module}}
    - require:
      - pkg: kmod_{{module}}
{% if 'options' in params %}
      - file: kmod_{{module}}_options_file
{% endif %}
  file.managed:
    - name: /etc/modules-load.d/{{module}}.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - contents: |
        # Load {{module}} module
        {{module}}
  cmd.run:
    - name: /usr/sbin/depmod -a
    - onchanges:
      - pkg: kmod_{{module}}
{% endfor %}
