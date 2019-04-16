This is a companion application which talks to the nodemcu-based software over MQTT.

It is implemented with node-red.

Deploy a node-red instance and import flow.json into it. You'll need to configure the paths of 
the file storage and the sqlite database, as well as the credentials to connect to your MQTT server.

The flow uses the following modules:
- https://flows.nodered.org/node/node-red-dashboard
- https://flows.nodered.org/node/node-red-node-sqlite
