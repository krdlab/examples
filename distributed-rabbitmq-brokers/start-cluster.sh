set -eu
vagrant ssh -c 'sudo service rabbitmq-server start' rabbit1
vagrant ssh -c 'sudo service rabbitmq-server start' rabbit2
vagrant ssh -c 'sudo service rabbitmq-server start' rabbit3
