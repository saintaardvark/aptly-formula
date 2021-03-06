include:
  - aptly.create_repos

{% set gpgid = salt['pillar.get']('aptly:gpg_keypair_id', '') %}
{% set gpgpassphrase = salt['pillar.get']('aptly:gpg_passphrase', '') %}

{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
publish_{{ repo }}_repo:
  cmd.run:
    # NOTE: You may have to run this command manually the first time. The next
    # version of aptly is supposed to have a -batch option to pass -no-tty to
    # the gpg calls.
    - name: aptly -batch=true publish repo -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ repo }}
    - user: aptly
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    # unless is 2014.7 only, on 2014.1 it doesn't run and you just get an error
    # saying the repo has already been published
    - unless: aptly -batch=true publish update -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ opts['distribution'] }}
{% endfor %}
