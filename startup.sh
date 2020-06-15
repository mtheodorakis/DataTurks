#!/bin/bash

# Starting httpd
echo "Staring Apache2 httpd"
/etc/init.d/apache2 start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Apache2 HTTPD. Exit status was $status"
  exit $status
fi
sleep 5

# Starting dataturks backend
echo "Staring Dataturks backend"
pushd dataturks-be
java -Djava.net.useSystemProxies=true -server -jar dataturks-1.0-SNAPSHOT.jar server onprem.yml &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Dataturks backend process. Exit status was $status"
  exit $status
fi
popd
sleep 10

# Starting dataturks frontend
echo "Staring Dataturks frontend"
pushd dataturks-fe
echo "Staring npm run start-onprem"
npm run start-onprem
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Dataturks process. Exit status was $status"
  exit $status
fi
popd

while true; do sleep 1; done