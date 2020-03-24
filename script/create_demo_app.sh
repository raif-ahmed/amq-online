set -x

AMQ_ONLINE_INFRA_PROJ=amq-online-infra
AMQ_ONLINE_DEMO_PROJ=amqp-demo

output=$(oc get project ${AMQ_ONLINE_DEMO_PROJ})

if [ -z "${output}" ]; then
    echo "project doesn't exists." 
    oc new-project ${AMQ_ONLINE_DEMO_PROJ}
fi

echo "Proceeding"

oc apply -f ./sample-topic.yaml

oc get routes console -o jsonpath={.spec.host} -n ${AMQ_ONLINE_INFRA_PROJ}

oc get addressspace demo-space -o 'jsonpath={.status.endpointStatuses[?(@.name=="messaging")].externalHost}' -n ${AMQ_ONLINE_DEMO_PROJ}




 


