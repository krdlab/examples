set -eu
vagrant ssh -c 'sudo service rabbitmq-server stop' rabbit3
vagrant ssh -c 'sudo service rabbitmq-server stop' rabbit2
vagrant ssh -c 'sudo service rabbitmq-server stop' rabbit1
