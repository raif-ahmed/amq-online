
To configure first ocp cluster

Ensure SSL certificates is generated, for sample self signed you can use create_demo_ssl.sh

export K8S_AUTH_HOST="https://api.cluster-ad86.ad86.sandbox81.opentlc.com:6443"
export K8S_AUTH_API_KEY="JZKvbdfQIq-qOUIlbbuPUtKTNriRFslvQBJEo2Rmkyg"
export K8S_AUTH_VERIFY_SSL=no

ansible-playbook install.yml -e amqonline_app_messaging_route_url="demo-app-messaging.apps.cluster-ad86.ad86.sandbox81.opentlc.com" -e amqonline_app_certificate_file_name="messaging-endpoint_cluster-ad86"


-------------------------------------

To configure Second ocp cluster

Ensure SSL certificates is generated and also trust the first cluster certificate,
for sample self signed you can use create_demo_ssl_with_remote_trust.sh


export K8S_AUTH_HOST="https://api.cluster-e77b.e77b.sandbox1014.opentlc.com:6443"
export K8S_AUTH_API_KEY="CmmeZXlzg0fbyt4DcyqOg2GlzFN1NyvXkRrAJ5QNcZE"
export K8S_AUTH_VERIFY_SSL=no

ansible-playbook install.yml -e amqonline_app_messaging_route_url="demo-app-messaging.apps.cluster-e77b.e77b.sandbox1014.opentlc.com" -e amqonline_app_certificate_file_name="messaging-endpoint_cluster-e77b" -e amqonline_app_remote_deploy="yes" -e amqonline_app_remote_messaging_route_url="demo-app-messaging.apps.cluster-ad86.ad86.sandbox81.opentlc.com" -e amqonline_app_remote_certificate_file_name="messaging-endpoint_cluster-ad86"
