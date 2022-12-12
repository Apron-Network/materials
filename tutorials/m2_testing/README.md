# Step By Step Test Instruction for Milestone 2 Features

This document introduces how to setup a brief test Apron network to verify milestone 1 features.
The network will be launched in two docker-compose clusters.

Note: all those steps should be done on Linux system with docker installed.

## Prepare the Test Network and Essential Components

Please download the latest date of apron node images from [here](https://drive.google.com/file/d/1fUIg4J3jyyI-6G76A-RRRrdQtlRIKw00/view?usp=sharing),
apron gateway image from [here](https://drive.google.com/file/d/1tzyKmrzXlv7CDDXOvAmjRH7ejPbrCTCZ/view?usp=sharing),
and service reg tool image from [here](https://drive.google.com/file/d/10kb4eM1bmC_vuIbca9y8wQVGPLAk_R1m/view?usp=sharing).

then load the images into system by this two commands:

```
docker load < apron_node_base_20211214.tar.gz
docker load < apron_gateway_20211214.tar.gz
docker load < apron_service_reg_20211214.tar.gz
```

### Setup Test Apron Network and Explorer

Before starting up the network, the network should be created for all services running inside.

```
docker network create --subnet=192.168.0.0/16 m2-testing
```

The compose file contains multiple services, but there are some manual operations required,
so the full service should be started manually.

Firstly, start apron-node and explorer service via this command

```
docker-compose up apron-node apron-explorer
```

After service started up, the explorer can be accessed via `http://localhost:3001`,
then switch the ws endpoint to `ws://localhost:9944` to connect to the local node.

The testing account used in Gateway is hard coded, so please add this account into the network via **Raw seed** `0xe40891ed4fa2eb6b8b89b1d641ae72e8c1ba383d809eeba64131b37bf0aa3898` 

The account must be `5F7Xv7RaJe8BBNULSuRTXWtfn68njP1NqQL5LLf41piRcEJJ`

![Add Account](https://github.com/Apron-Network/apron-node/blob/upgrade_contract/scripts/images/add_acount.png)

After account added, transfer some tokens for further testing.

### Setup contracts

Download the contracts from [here](https://github.com/Apron-Network/apron-gateway-rust/tree/main/release).
Before deploying the contracts, ensure the controller is `5F7Xv7RaJe8BBNULSuRTXWtfn68njP1NqQL5LLf41piRcEJJ`

![Market Contract](https://github.com/Apron-Network/apron-node/blob/upgrade_contract/scripts/images/market_contract.png)

Then deploy the contracts on page. Please make sure the two points below:

* Ensure the controller is `5F7Xv7RaJe8BBNULSuRTXWtfn68njP1NqQL5LLf41piRcEJJ`
* Ensure the market addr is the address of market contract created above.

After the contract installed, copied the contract address and put into *alice/env* and *bob/env* file with this command:

```
echo MARKET_CONTRACT=<market_contract_addr> > alice/.env
echo STAT_CONTRACT=<stat_contract_addr> >> alice/.env

echo MARKET_CONTRACT=<market_contract_addr> > bob/.env
echo STAT_CONTRACT=<stat_contract_addr> >> bob/.env

```

### Start Service Registration Tool and Gateway

The docker-compose cluster launched above contains a service registration tool page, which can be used to register services.
The tool can be started via this command:

```
docker-compose up -d apron-gateway-alice apron-service-reg-tool httpbin-service ws-echo-service
```

This command will start up the left contains, which includes service reg tool, gateway, and two testing services.
Access the tool page via *http://localhost:3000/*, and you can see a page without services.
There will be two nodes in testnet, which are *alice* and *bob*. By the way, in this demo,
service reg tool is connected to *alice* node, which means the *alice* is ServiceSideGateway.


### Start another node

Switch to *bob* directory and start the bob cluster via `docker-compose up -d` command then wait some time until the node is up.


After making sure all the contains are running without errors, the test network is ready to be used.


## Register services

Service need to be registered before it can be used by client, the alice docker cluster contains two service containers,
*httpbin* and *echo websocket service*, which can be used to demo full data flow.

### Register services

Access the registration tool page via address *http://localhost:3001* and register those two services. The service registration tool currently is connecting to *alice* node, so all the services are registered on *alice* node. In the coming descriptions, Node *alice* will be referred as *ServiceSideNode*, which means this node is the node connecting to service.  While *bob* will be referred as *ClientSideNode*, which means this node will accept connections from client and pass request to service via the p2p network. Here are some screenshots.

* Edit service

![Edit service](https://github.com/Apron-Network/materials/blob/main/graphics/Apron%20service%20reg-edit.png?raw=true "Edit Service")

* Service detail

![Service detail](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/Apron%20service%20reg-detail.png "Service Detail")

* Edit Service detail

![Edit service detail](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/Apron%20service%20reg-edit-detail.png "Edit Service Detail")

* Service settings

![Service settings](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/Apron%20service%20reg-setting.png "Service Settings")

* Delete service

![Delete service](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/Apron%20service%20reg-delete.png "Delete Service")

For testing purpose, we can create those two services:

**httpbin service**

1. Click *create* button on left upper corner
1. Fill information like this:
  * Service name: httpbin demo
  * Description: A httpbin demo service
  * Price plan: demo price plan
  * Schema: http
  * Base url: http://192.168.0.32
1. Click confirm button

**echo websocket service**

1. Click *create* button on left upper corner
1. Fill information like this:
  * Service name: ws echo demo
  * Description: A ws echo demo service
  * Price plan: demo price plan
  * Schema: ws
  * Base url: ws://192.168.0.33:8080
1. Click confirm button

After submitting the request, wait around 10-15 seconds to get service data on chain. Can check alice console log to find *result: Ok("success")* text.
And the service list should be visible in *service market* contract page.

## User

As described above, user will connect to *ClientSideNode* and try to access services behind *ServiceSideNode*. According to the scripts starting the *ClientSideNode*, the access point for client side should be *localhost:8081*

### Use httpbin service

This testing requires cli tool [httpie](https://httpie.org/). After service registered, user can connect to ClientSideNode with this command:

```shell
http -v 'localhost:8081/v1/aaaaaaaaaaabcdefg/qqq?abcd=1&ab=2' a:1 b:3
```

There will be some logs printed from console of two nodes, which shows the data is transferred from ClientSideNode to ServiceSideNode. And the response from service will be shown in console launched `httpie` like this:

```shell
GET /v1/aaaaaaaaaaabcdefg/qqq?abcd=1&ab=2 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: localhost:8976
User-Agent: HTTPie/1.0.3
a: 1
b: 3



HTTP/1.1 200 OK
content-length: 429
date: Tue, 14 Dec 2021 10:25:02 GMT

{
  "args": {
    "ab": "2",
    "abcd": "1"
  },
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "A": "1",
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "B": "3",
    "Connection": "keep-alive",
    "Host": "localhost:8976",
    "User-Agent": "HTTPie/1.0.3"
  },
  "json": null,
  "method": "GET",
  "origin": "172.17.0.1",
  "url": "http://localhost:8976/anything?abcd=1&ab=2"
}
```

As the response shown, the header, query params, url path are returned from service as expected.


### Use websocket echo service

In this test, the command line tool [websocat](http://www.squaremobius.net/websocat/) will be used. After service registered, user can connect to service with this command:

```
websocat 'ws://localhost:8976/ws/v1/abcdefgh'
```

After connection established, user can get a message like this:

```
Request served by 8fa4bda08cde
```

And after typing anything with enter, the same text will be returned from service as expected. The traffic log is also shown in console of two nodes.


