export AMQ_URL=messaging-1.apps.cluster-d524.d524.sandbox941.opentlc.com
export REMOTE_AMQ_URL=messaging-1.apps.cluster-8656.8656.sandbox114.opentlc.com

CLUSTER_ID=cluster-d524
REMOTE_CLUSTER_ID=cluster-8656


export AMQ_KEYSTORE=messaging-endpoint_$CLUSTER_ID
export AMQ_KEYSTORE_PASSWORD=passw0rd

export REMOTE_AMQ_KEYSTORE=messaging-endpoint_$REMOTE_CLUSTER_ID
export REMOTE_AMQ_KEYSTORE_PASSWORD=passw0rd

export AMQ_CLIENT_KEYSTORE=client_$CLUSTER_ID
export AMQ_CLIENT_KEYSTORE_PASSWORD=passw0rd

export AMQ_ONLINE_INFRA_PROJ=amq-online-infra
export AMQ_ONLINE_DEMO_PROJ=amqp-demo

export EXPOSE_ENDPOINT_SECRET_NAME=server-secret
export REMOTE_CONNECTOR_SECRET_NAME=remote-secret


output=$(oc get project ${AMQ_ONLINE_DEMO_PROJ})

if [ -z "${output}" ]; then
    echo "project doesn't exists." 
    oc new-project ${AMQ_ONLINE_DEMO_PROJ}
fi


cd ssl_certs


keytool -genkey -noprompt -keyalg RSA -alias amq-broker -dname "CN=${AMQ_URL}, ou=IVO, o=Rechtspraak, c=NL" -keystore $AMQ_KEYSTORE.jks -storepass $AMQ_KEYSTORE_PASSWORD -keypass $AMQ_KEYSTORE_PASSWORD -deststoretype pkcs12
keytool -genkey -noprompt -keyalg RSA -alias amq-client -dname "CN=${AMQ_URL}, ou=IVO, o=Rechtspraak, c=NL" -keystore $AMQ_CLIENT_KEYSTORE.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -keypass $AMQ_CLIENT_KEYSTORE_PASSWORD -deststoretype pkcs12


keytool -export -alias amq-broker -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${AMQ_KEYSTORE}_cert.der
openssl x509 -inform DER -in ${AMQ_KEYSTORE}_cert.der -out ${AMQ_KEYSTORE}_cert.crt
openssl x509 -in ${AMQ_KEYSTORE}_cert.crt -out ${AMQ_KEYSTORE}_cert.pem -outform PEM


keytool -export -alias amq-client -keystore ${AMQ_CLIENT_KEYSTORE}.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -file ${AMQ_CLIENT_KEYSTORE}_cert.der
openssl x509 -inform DER -in ${AMQ_CLIENT_KEYSTORE}_cert.der -out ${AMQ_CLIENT_KEYSTORE}_cert.crt
openssl x509 -in ${AMQ_CLIENT_KEYSTORE}_cert.crt -out ${AMQ_CLIENT_KEYSTORE}_cert.pem -outform PEM


keytool -import -trustcacerts -noprompt -alias amq-server -keystore ${AMQ_CLIENT_KEYSTORE}.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -file ${AMQ_KEYSTORE}_cert.der
keytool -import -trustcacerts -noprompt -alias amq-client -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${AMQ_CLIENT_KEYSTORE}_cert.der
keytool -import -trustcacerts -noprompt -alias amq-remote-server -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${REMOTE_AMQ_KEYSTORE}_cert.der


openssl pkcs12 -in $AMQ_KEYSTORE.jks -nocerts -nodes  -out $AMQ_KEYSTORE.key -passin pass:$AMQ_KEYSTORE_PASSWORD
openssl pkcs12 -in $AMQ_CLIENT_KEYSTORE.jks -nocerts -nodes  -out ${AMQ_CLIENT_KEYSTORE}.key -passin pass:$AMQ_CLIENT_KEYSTORE_PASSWORD

openssl rsa -in $AMQ_KEYSTORE.key -text > ${AMQ_KEYSTORE}_key.pem


#To convert a JKS (.jks) keystore to a PKCS12 (.p12) keystore

keytool -importkeystore -srckeystore ${AMQ_KEYSTORE}.jks -destkeystore ${AMQ_KEYSTORE}.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $AMQ_KEYSTORE_PASSWORD -deststorepass $AMQ_KEYSTORE_PASSWORD

keytool -importkeystore -srckeystore ${AMQ_CLIENT_KEYSTORE}.jks -destkeystore ${AMQ_CLIENT_KEYSTORE}.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $AMQ_CLIENT_KEYSTORE_PASSWORD -deststorepass $AMQ_CLIENT_KEYSTORE_PASSWORD

#Validate your P12 file.
#openssl pkcs12 -in $AMQ_KEYSTORE.p12 -noout -info
#openssl pkcs12 -in $AMQ_CLIENT_KEYSTORE.p12 -noout -info

oc -n ${AMQ_ONLINE_INFRA_PROJ} delete secret ${EXPOSE_ENDPOINT_SECRET_NAME}
oc -n ${AMQ_ONLINE_INFRA_PROJ} create secret tls ${EXPOSE_ENDPOINT_SECRET_NAME} --cert=${AMQ_KEYSTORE}_cert.crt --key=$AMQ_KEYSTORE.key


oc -n ${AMQ_ONLINE_DEMO_PROJ} delete secret ${EXPOSE_ENDPOINT_SECRET_NAME}
oc -n ${AMQ_ONLINE_DEMO_PROJ} create secret tls ${EXPOSE_ENDPOINT_SECRET_NAME} --cert=${AMQ_KEYSTORE}_cert.crt --key=$AMQ_KEYSTORE.key

oc -n ${AMQ_ONLINE_DEMO_PROJ} delete secret ${REMOTE_CONNECTOR_SECRET_NAME}
oc -n ${AMQ_ONLINE_DEMO_PROJ} create secret tls ${REMOTE_CONNECTOR_SECRET_NAME} --cert=${REMOTE_AMQ_KEYSTORE}_cert.crt --key=$REMOTE_AMQ_KEYSTORE.key


sed -i'' -e "s/routeHost:.*/routeHost: $AMQ_URL/g" ../demo-ssl-objects_wth_connectors.yaml
sed -i'' -e "s/- host:.*/- host: $REMOTE_AMQ_URL/g" ../demo-ssl-objects_wth_connectors.yaml


oc create -f ../demo-ssl-objects_wth_connectors.yaml

exit


 
