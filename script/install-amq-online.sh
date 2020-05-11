set -x

AMQ_ONLINE_INFRA_PROJ=amq-online-infra



wget https://access.redhat.com/node/4541981/423/0/15323281 -O amq-online-install-1-3.zip
# wget https://access.redhat.com/sites/default/files/announcements/amq-online-install_0.zip

unzip ./amq-online-install-1-3.zip -d amq-online-install-1-3


output=$(oc get project ${AMQ_ONLINE_INFRA_PROJ})

if [ -z "${output}" ]; then
    echo "project doesn't exists." 
    oc new-project ${AMQ_ONLINE_INFRA_PROJ}
fi

echo "Proceeding"

# for more details about installing an opertor, refer to https://docs.openshift.com/container-platform/4.3/operators/olm-adding-operators-to-cluster.html#olm-installing-operator-from-operatorhub-using-cli_olm-adding-operators-to-a-cluster
oc apply -f ./amq-online.yaml

cd amq-online-install-1-3

sleep 5

oc apply -f install/components/example-plans -n ${AMQ_ONLINE_INFRA_PROJ}
oc apply -f install/components/example-roles -n ${AMQ_ONLINE_INFRA_PROJ}
oc apply -f install/components/example-authservices/standard-authservice.yaml -n ${AMQ_ONLINE_INFRA_PROJ}

exit



 


