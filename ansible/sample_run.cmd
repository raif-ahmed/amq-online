
To configure first ocp cluster

Ensure SSL certificates is generated, for sample self signed you can use create_demo_ssl.sh

export K8S_AUTH_HOST="https://api.cluster-63ff.63ff.sandbox828.opentlc.com:6443"
export K8S_AUTH_API_KEY="BPk9Vn2for5pbCZArps-AGfDhWl5kSv21-V3JRf0fkY"
export K8S_AUTH_VERIFY_SSL=no

ansible-playbook install.yml -e amqonline_app_messaging_route_url="demo-app-messaging.apps.cluster-63ff.63ff.sandbox828.opentlc.com" -e amqonline_app_certificate_file_name="messaging-endpoint_cluster-63ff"


-------------------------------------

To configure Second ocp cluster

Ensure SSL certificates is generated and also trust the first cluster certificate,
for sample self signed you can use create_demo_ssl_with_remote_trust.sh


export K8S_AUTH_HOST="https://api.cluster-3b4d.3b4d.sandbox893.opentlc.com:6443"
export K8S_AUTH_API_KEY="467Ysp5rtzerxFyoQSo4B53QfZvhIWTn4VAC-p66d5M"
export K8S_AUTH_VERIFY_SSL=no

ansible-playbook install.yml -e amqonline_app_messaging_route_url="demo-app-messaging.apps.cluster-3b4d.3b4d.sandbox893.opentlc.com" -e amqonline_app_certificate_file_name="messaging-endpoint_cluster-3b4d" -e amqonline_app_remote_deploy="yes" -e amqonline_app_remote_messaging_route_url="demo-app-messaging.apps.cluster-63ff.63ff.sandbox828.opentlc.com" -e amqonline_app_remote_certificate_file_name="messaging-endpoint_cluster-63ff"
