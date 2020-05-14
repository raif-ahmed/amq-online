export AMQ_URL=messaging-1.apps.cluster-4d2a.4d2a.sandbox1401.opentlc.com

CLUSTER_ID=cluster-80e6

messaging-endpoint_cluster-80e6_cert.crt

export AMQ_TRUSTSTORE=messaging-endpoint_$CLUSTER_ID
export AMQ_KEYSTORE=messaging-endpoint_$CLUSTER_ID
export AMQ_KEYSTORE_PASSWORD=passw0rd

export AMQ_CLIENT_KEYSTORE=client_$CLUSTER_ID
export AMQ_CLIENT_KEYSTORE_PASSWORD=passw0rd

export AMQ_ONLINE_INFRA_PROJ=amq-online-infra
export AMQ_ONLINE_DEMO_PROJ=amqp-demo

export EXPOSE_ENDPOINT_SECRET_NAME=dummy-secret


cd ssl_certs



keytool -import -trustcacerts -noprompt -alias amq-server -keystore ${AMQ_CLIENT_KEYSTORE}.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -file ${AMQ_KEYSTORE}_cert.der
keytool -import -trustcacerts -noprompt -alias amq-client -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${AMQ_CLIENT_KEYSTORE}_cert.der


openssl pkcs12 -in $AMQ_KEYSTORE.jks -nocerts -nodes  -out $AMQ_KEYSTORE.key -passin pass:$AMQ_KEYSTORE_PASSWORD
openssl pkcs12 -in $AMQ_CLIENT_KEYSTORE.jks -nocerts -nodes  -out amq-client.key -passin pass:$AMQ_CLIENT_KEYSTORE_PASSWORD

openssl rsa -in $AMQ_KEYSTORE.key -text > ${AMQ_KEYSTORE}_key.pem


#To convert a JKS (.jks) keystore to a PKCS12 (.p12) keystore

keytool -importkeystore -srckeystore ${AMQ_KEYSTORE}.jks -destkeystore ${AMQ_KEYSTORE}.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $AMQ_KEYSTORE_PASSWORD -deststorepass $AMQ_KEYSTORE_PASSWORD

keytool -importkeystore -srckeystore ${AMQ_CLIENT_KEYSTORE}.jks -destkeystore ${AMQ_CLIENT_KEYSTORE}.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $AMQ_CLIENT_KEYSTORE_PASSWORD -deststorepass $AMQ_CLIENT_KEYSTORE_PASSWORD

#Validate your P12 file.
#openssl pkcs12 -in $AMQ_KEYSTORE.p12 -noout -info
#openssl pkcs12 -in $AMQ_CLIENT_KEYSTORE.p12 -noout -info

oc -n ${AMQ_ONLINE_INFRA_PROJ} delete secret ${EXPOSE_ENDPOINT_SECRET_NAME}
oc -n ${AMQ_ONLINE_INFRA_PROJ} create secret tls ${EXPOSE_ENDPOINT_SECRET_NAME} --cert=${AMQ_KEYSTORE}_cert.crt --key=$AMQ_KEYSTORE.key


sed -i'' -e "s/routeHost:.*/routeHost: $AMQ_URL/g" ../demo2.yaml


oc create -f ../demo2.yaml

exit


 
