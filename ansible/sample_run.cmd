
To configure first ocp cluster

Ensure SSL certificates is generated, for sample self signed you can use create_demo_ssl.sh

export K8S_AUTH_HOST="https://api.cluster-91f1.91f1.sandbox171.opentlc.com:6443"
export K8S_AUTH_API_KEY="4GdcMJcGbW2QdJEE9BReuEY4uPvBuYkndb3n_3VIq4I"
export K8S_AUTH_VERIFY_SSL=no

ansible-playbook install.yml -e amqonline_app_messaging_route_url="demo-app-messaging.apps.cluster-91f1.91f1.sandbox171.opentlc.com" -e amqonline_app_certificate_file_name="messaging-endpoint_cluster-91f1"


-------------------------------------

To configure Second ocp cluster

Ensure SSL certificates is generated and also trust the first cluster certificate,
for sample self signed you can use create_demo_ssl_with_remote_trust.sh


export K8S_AUTH_HOST="https://api.cluster-e483.e483.sandbox1287.opentlc.com:6443"
export K8S_AUTH_API_KEY="yBwfOM1zrvkflVErZ5bTbyh_cSjgjz3xw_lr8Yr75Mo"
export K8S_AUTH_VERIFY_SSL=no

ansible-playbook install.yml -e amqonline_app_messaging_route_url="demo-app-messaging.apps.cluster-e483.e483.sandbox1287.opentlc.com" -e amqonline_app_certificate_file_name="messaging-endpoint_cluster-e483" -e amqonline_app_remote_deploy="yes" -e amqonline_app_remote_messaging_route_url="demo-app-messaging.apps.cluster-91f1.91f1.sandbox171.opentlc.com" -e amqonline_app_remote_certificate_file_name="messaging-endpoint_cluster-91f1"
