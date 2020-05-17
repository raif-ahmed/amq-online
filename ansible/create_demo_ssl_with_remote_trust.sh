AMQ_URL=demo-app-messaging.apps.cluster-e483.e483.sandbox1287.opentlc.com
REMOTE_AMQ_URL=demo-app-messaging.apps.cluster-91f1.91f1.sandbox171.opentlc.com

CLUSTER_ID=cluster-e483
REMOTE_CLUSTER_ID=cluster-91f1


AMQ_KEYSTORE=messaging-endpoint_$CLUSTER_ID
AMQ_KEYSTORE_PASSWORD=passw0rd

REMOTE_AMQ_KEYSTORE=messaging-endpoint_$REMOTE_CLUSTER_ID
REMOTE_AMQ_KEYSTORE_PASSWORD=passw0rd

AMQ_CLIENT_KEYSTORE=client_$CLUSTER_ID
AMQ_CLIENT_KEYSTORE_PASSWORD=passw0rd



cd /tmp/certs

keytool -genkey -noprompt -keyalg RSA -alias amq-broker -dname "CN=${AMQ_URL}, ou=IVO, o=Rechtspraak, c=NL" -keystore $AMQ_KEYSTORE.jks -storepass $AMQ_KEYSTORE_PASSWORD -keypass $AMQ_KEYSTORE_PASSWORD -deststoretype pkcs12
keytool -genkey -noprompt -keyalg RSA -alias amq-client -dname "CN=${AMQ_URL}, ou=IVO, o=Rechtspraak, c=NL" -keystore $AMQ_CLIENT_KEYSTORE.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -keypass $AMQ_CLIENT_KEYSTORE_PASSWORD -deststoretype pkcs12


keytool -export -alias amq-broker -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${AMQ_KEYSTORE}.der
openssl x509 -inform DER -in ${AMQ_KEYSTORE}.der -out ${AMQ_KEYSTORE}.crt
openssl x509 -in ${AMQ_KEYSTORE}.crt -out ${AMQ_KEYSTORE}.pem -outform PEM


keytool -export -alias amq-client -keystore ${AMQ_CLIENT_KEYSTORE}.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -file ${AMQ_CLIENT_KEYSTORE}.der
openssl x509 -inform DER -in ${AMQ_CLIENT_KEYSTORE}.der -out ${AMQ_CLIENT_KEYSTORE}.crt
openssl x509 -in ${AMQ_CLIENT_KEYSTORE}.crt -out ${AMQ_CLIENT_KEYSTORE}.pem -outform PEM


keytool -import -trustcacerts -noprompt -alias amq-server -keystore ${AMQ_CLIENT_KEYSTORE}.jks -storepass $AMQ_CLIENT_KEYSTORE_PASSWORD -file ${AMQ_KEYSTORE}.der
keytool -import -trustcacerts -noprompt -alias amq-client -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${AMQ_CLIENT_KEYSTORE}.der
keytool -import -trustcacerts -noprompt -alias amq-remote-server -keystore ${AMQ_KEYSTORE}.jks -storepass $AMQ_KEYSTORE_PASSWORD -file ${REMOTE_AMQ_KEYSTORE}.der


openssl pkcs12 -in $AMQ_KEYSTORE.jks -nocerts -nodes  -out $AMQ_KEYSTORE.key -passin pass:$AMQ_KEYSTORE_PASSWORD
openssl pkcs12 -in $AMQ_CLIENT_KEYSTORE.jks -nocerts -nodes  -out ${AMQ_CLIENT_KEYSTORE}.key -passin pass:$AMQ_CLIENT_KEYSTORE_PASSWORD


#To convert a JKS (.jks) keystore to a PKCS12 (.p12) keystore

keytool -importkeystore -srckeystore ${AMQ_KEYSTORE}.jks -destkeystore ${AMQ_KEYSTORE}.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $AMQ_KEYSTORE_PASSWORD -deststorepass $AMQ_KEYSTORE_PASSWORD

keytool -importkeystore -srckeystore ${AMQ_CLIENT_KEYSTORE}.jks -destkeystore ${AMQ_CLIENT_KEYSTORE}.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $AMQ_CLIENT_KEYSTORE_PASSWORD -deststorepass $AMQ_CLIENT_KEYSTORE_PASSWORD

#Validate your P12 file.
#openssl pkcs12 -in $AMQ_KEYSTORE.p12 -noout -info
#openssl pkcs12 -in $AMQ_CLIENT_KEYSTORE.p12 -noout -info



exit


 
