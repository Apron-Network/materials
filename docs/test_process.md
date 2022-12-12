# Test Process

## Setup Nodes

### Setup Apron Node

The Apron node is deployed by docker for now. The newest docker image can be downloaded [here](https://drive.google.com/drive/folders/1W9X3BAYs9mU2VuBsnPd2axxRtPkXS9co?usp=sharing).

After image downloaded, use this command to load it:

```bash
docker load < apron-node-2021xxxx.tar.gz
```

_**Dev Mode**_

Download the dev docker-compose file from [here](https://github.com/Apron-Network/apron-gateway-p2p/blob/master/full/docker-compose-dev.yml) and start the docker compose cluster in dev mode.

```bash 
$ ln -s docker-compose-dev.yml docker-compose.yml
$ docker-compose up -d
```

_**Boot Node of Private Network**_

Download the boot configuration file from [here](https://github.com/Apron-Network/apron-gateway-p2p/blob/master/full/docker-compose-boot.yml) and start the docker compose cluster.


```bash
$ ln -s docker-compose-boot.yml docker-compose.yml
$ docker-compose up -d
```
When the node starts you should see output simillar to this. You can get apron gateway boot node addr information, such as `/ip4/xxx.xxx.xxx.xxx/tcp/2145/p2p/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

```bash
$ docker-compose logs apron-gateway
Attaching to apron-node, apron-gateway, polkadot-frontend
apron-gateway        | 2021/08/10 16:12:10 Host ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
apron-gateway        | 2021/08/10 16:12:10 Connect to me on:
apron-gateway        | 2021/08/10 16:12:10   /ip4/xxx.xxx.xxx.xxx/tcp/2145/p2p/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
apron-gateway        | 2021/08/10 16:12:10   /ip4/xxx.xxx.xxx.xxx/tcp/2145/p2p/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Besides, a blockchain expoler can be used in the boot up cluster. Navigate to http://<boot_addr>:3001/?rpc=ws%3A%2F%2F<boot_addr>%3A9944#/explorer with browser to use the explorer.


_**Client Node Join the Private Network**_

Download the configuration file from [here](https://github.com/Apron-Network/apron-gateway-p2p/blob/master/full/docker-compose-client.yml), and use the boot node addr shown in boot node log in `--bootnodes` of `apron-node` section. Then start the docker compose to start client node.

#### Client Starts
```bash
$ ln -s docker-compose-client.yml docker-compose.yml
$ docker-compose up -d
```

### Install Contracts

The Services Market is the Apron that registers the node service, provides the service registration and the query, the following figure is the registration of a new node service.

Services Statistics records the availability and usage of a service over a period of time, and can submit the service usage provided by the service provider to a peer-to-peer contract. Note that only the service registrant using the same account can submit the service usage.

The contracts can be deployed via `apron-deployer` tool. Get the `apron-deployer` from `git clone https://github.com/Apron-Network/apron-deployer.git`

```
cd apron-deployer
yarn 
yarn run deploy
```
You will get several files generated. `marketAddress` is the address for market contract. `statAddress` is the address for statistics contract. These addresses will be used in next step.

## Setup Marketplace

The marketplace code can be found [here](https://github.com/Apron-Network/apron-marketplace).

Before settint the marketplace, a *Polkadot JS Extension* should be installed in advanced.
The extension can be downloaded from [https://polkadot.js.org/extension/](https://polkadot.js.org/extension/).

Download the code by this command:

```bash
git clone https://github.com/Apron-Network/apron-marketplace.git
```

The `services_market` and `services_statistics` contract address should be prepared before building this app.
The address should be updated into `public/configAddress.js`.

```javascript
window.mainAddress = {
    market: "<services market address>",
    statistics: "<services statistics address>",
    basepath: "<NODE RPC>"
};
```

> `<services market address>` and `<services market address>` is the contract's address after the contracts are deployed.
> `<NODE RPC>` is the websocket RPC provided by  Node. If you run it locally, it should be `ws://127.0.0.1:9944` by default

In the project directory, those script can be used:

`yarn start`

Runs the app in the development mode.
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.


`yarn test`

Launches the test runner in the interactive watch mode.

`yarn build`

Builds the app for production to the `build` folder.
It correctly bundles React in production mode and optimizes the build for the best performance.


## Preparing the Test Environment

The proxy test requires two nodes, one is to act as client side gateway, and the other is service side gateway.
The two nodes should be connected and have separated hostname.
Refer to *Boot Node of Private Network* section to make two nodes connected.

In the coming document, domain *alice.example.com* and *bob.example.com* will be used for testing.

## Register Service

Service is registered by RESTful request. Here is the sample request:

```bash
curl --location --request POST 'http://bob.example.com:8082/service' \
--header 'Content-Type: application/json' \
--data-raw '{
    "id" : "alice_example_com:8080",
    "domain_name": "alice.example.com",
    "providers": [
        {
            "id" : "test_provider1",
            "name": "test_provider1 http provider1",
            "desc": "test http provider1 desc",
            "base_url": "https://httpbin.org/anything",
            "schema": "https"
        }
    ]
}'
```

This command registers a service on bob node, the service can be accessed from alice node.

## Test Request Forward

The service registered above can be accessed in this way:

```bash
curl http://alice.example.com:8080/v1/testkey/foobar
```

After the request above sent, the */foobar* will be passed to services registered, which is *https://httpbin.org/anything* in this case,
which means the client will get response from *https://httpbin.org/anything/foobar*.

The gateway log can be used to verify the request is forwared as expected.
The gateway log from client side gateway (alice) should be like this:

```
2021/08/11 02:32:08 ClientSideGateway: Service name: m1-alice_apron_network:8080
2021/08/11 02:32:08 ClientSideGateway: Current services mapping: map[m1-alice_apron_network:8080:QmSK22Dvh4cgnRV535xsg5Dx86fahNrKe3vdKSCxz4fXDV]
2021/08/11 02:32:08 ClientSideGateway: Service URL requested from : http://m1-alice.apron.network:8080/v1/testkey/foobar
2021/08/11 02:32:08 ClientSideGateway: servicePeerId : QmSK22Dvh4cgnRV535xsg5Dx86fahNrKe3vdKSCxz4fXDV
2021/08/11 02:32:08 WriteBytesViaStream: data len: 292, stream: /proxy_req/1.0, data: "\n\x1bm1-alice_apron_network:8080\x12$5b592432-4cd5-4375-b467-4073fdb0e32d\x1a.QmdyB7ddj8Jy2oNxs7AmqJAShK7Vkkz9k1obH9rMBJmXzD*\atestkeyR\xa5\x01GET /v1/testkey/foobar HTTP/1.1\r\nUser-Agent: HTTPie/1.0.3\r\nHost: m1-alice.apron.network:8080\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"
2021/08/11 02:32:08 WriteBytesViaStream: written 292 data to stream: /proxy_req/1.0
2021/08/11 02:32:08 WriteBytesViaStream: Data written
Path with k: "/v1/testkey/foobar", match rslt: [[[47 118 49 47 116 101 115 116 107 101 121 47 102 111 111 98 97 82] [49] [116 101 115 116 107 101 121] [102 111 111 98 97 82]]]
2021/08/11 02:32:08 ReadBytesViaStream: protocol: /proxy_service_http_data, read msg len: 386
2021/08/11 02:32:08 ReadBytesViaStream: Received msg from stream: /proxy_service_http_data, len: 386, data: "\x12$5b592432-4cd5-4375-b467-4073fdb0e32dR\xd9\x02{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"keep-alive\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"HTTPie/1.0.3\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"172.19.0.5\", \n  \"url\": \"http://httpbin/anything/foobar\"\n}\n"
2021/08/11 02:32:08 ProxyHttpRespHandler: Read proxy data from stream: /proxy_service_http_data, request_id:"5b592432-4cd5-4375-b467-4073fdb0e32d"  raw_data:"{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"keep-alive\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"HTTPie/1.0.3\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"172.19.0.5\", \n  \"url\": \"http://httpbin/anything/foobar\"\n}\n"
```

The first line of `WriteBytesViaStream` tag in the log shows the request has been forwared to service side gateway,
and the stream string followed shows the stream used for forwarding proxy request.
And the tag `ReadBytesViaStream` shows the client side gateway getting respose from service side stream.

And the gateway log from service side gateway (bob) should be like this:

```
2021/08/11 02:32:08 ReadBytesViaStream: protocol: /proxy_req/1.0, read msg len: 292
2021/08/11 02:32:08 ReadBytesViaStream: Received msg from stream: /proxy_req/1.0, len: 292, data: "\n\x1bm1-alice_apron_network:8080\x12$5b592432-4cd5-4375-b467-4073fdb0e32d\x1a.QmdyB7ddj8Jy2oNxs7AmqJAShK7Vkkz9k1obH9rMBJmXzD*\atestkeyR\xa5\x01GET /v1/testkey/foobaR HTTP/1.1\r\nUser-Agent: HTTPie/1.0.3\r\nHost: m1-alice.apron.network:8080\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"
2021/08/11 02:32:08 Read proxy request from stream: service_id:"m1-alice_apron_network:8080"  request_id:"5b592432-4cd5-4375-b467-4073fdb0e32d"  peer_id:"QmdyB7ddj8Jy2oNxs7AmqJAShK7Vkkz9k1obH9rMBJmXzD"  account_id:"testkey"  raw_request:"GET /v1/testkey/foobaR HTTP/1.1\r\nUser-Agent: HTTPie/1.0.3\r\nHost: m1-alice.apron.network:8080\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"Path with k: "/v1/testkey/foobaR", match rslt: [[[47 118 49 47 116 101 115 116 107 101 121 47 102 111 111 98 97 82] [49] [116 101 115 116 107 101 121] [102 111 111 98 97 82]]]
2021/08/11 02:32:08 ServiceSideGateway: Write response data: "{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"keep-alive\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"HTTPie/1.0.3\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"172.19.0.5\", \n  \"url\": \"http://httpbin/anything/foobaR\"\n}\n"
2021/08/11 02:32:08 resp stream is nil false
2021/08/11 02:32:08 WriteBytesViaStream: data len: 386, stream: /proxy_service_http_data, data: "\x12$5b592432-4cd5-4375-b467-4073fdb0e32dR\xd9\x02{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Accept-Encoding\": \"gzip, deflate\", \n    \"Connection\": \"keep-alive\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"HTTPie/1.0.3\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"172.19.0.5\", \n  \"url\": \"http://httpbin/anything/foobaR\"\n}\n"
2021/08/11 02:32:08 WriteBytesViaStream: written 386 data to stream: /proxy_service_http_data
2021/08/11 02:32:08 WriteBytesViaStream: Data written
```

The first line of `ReadBytesViaStream` is getting request data from client side gateway, and then the `WriteBytesViaStream` is writing data back to client side gateway.

## Check Usage Report

The usage report data will be collected by contract, and user can check the report from marketplace page.
