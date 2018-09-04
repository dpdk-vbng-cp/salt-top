base:
  '*':
    - defaults
    - systemd
  'roles:vbng-control':
    - match: grain
    - vbng-control
