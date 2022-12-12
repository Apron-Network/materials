# Step By Step Test Instruction for Milestone 1 Features

This document introduces how to setup a brief test Apron network to verify milestone 1 features.
The network will be launched in two docker-compose clusters.

Note: all those steps should be done on Linux system with docker installed.

## Prepare the Test Network and Esseitial Components

### Prepare the docker images

Please download the latest date of apron node and deployer images from [here](https://drive.google.com/drive/folders/1W9X3BAYs9mU2VuBsnPd2axxRtPkXS9co?usp=sharing),

then load the image into system by this two commands:

```
docker load < apron-node-2021xxxx.tar.gz
docker load < apron-deployer-2021xxxx.tar.gz
```

### Setup Test Apron Network

In this directory, execute `setup.sh` script and wait about 30 seconds to wait environment done.

To verify the network ready, first check whether all containers are running,
then ensure output returned in next command is liking below:

```shell
$ docker logs --tail=50 alice_apron-deployer_1 | grep 'contract address is'
market contract address is :  5HX9NRcDTWnkWHcwGWosB97K2V29nQXy6VErcP4mwEUWnV1D
stats contract address is:  5CsBynhpjvPycJ19BbCPaipgURVE8SWkz9DHvBAYQqoh1tR6
```

If all containers are running and the command output looks like sample,
the test Apron network should be ready.

### Setup Marketplace

Follow the instruction in [project page](https://github.com/Apron-Network/apron-marketplace) to setup a running market place.
Make sure the two contract addresses are updated to `public/js/contractAddress.js`. For the output above, the file should be like:

```js
const configuration = {
    market: "5HX9NRcDTWnkWHcwGWosB97K2V29nQXy6VErcP4mwEUWnV1D",
    statistics:'5CsBynhpjvPycJ19BbCPaipgURVE8SWkz9DHvBAYQqoh1tR6',
    basepath:'localhost',
    name:'Apron Market'
};
window.configuration = configuration;
```

After configuration done, run those commands:

```
yarn
yarn start
```

After dependencies installed successfully, the webpage will be opened with default browser.
The address is *http://127.0.0.1:3000* and can be accessed by browser manually if not pop up.

### Setup Test Domain

The domain name can help to understand the test better, please put those lines to `/etc/hosts` file.

```
127.0.0.1 alice.example.com
127.0.0.1 bob.example.com
```

For now, the network should be ready for tests.

## Service Provider

You can use `https://httpbin.org` as a service and register it behind alice gateway. 
### Register service

Service is registered by RESTful request on gateway and market place using the below script.

```shell
curl --location --request POST "alice.example.com:4000/service" \
--header 'Content-Type: application/json' \
--data-raw '{
    "id" : "bob_example_com:8081",
    "domain_name": "bob.example.com",
    "name": "Httpbin",
        "desc": "httpbin service for testing purpose.",
        "logo": "https://via.placeholder.com/150?text=httpbin",
        "usage": "Just run the command `curl http://bob.example.com:8081`. More information please refer the official documents.",
    "providers": [
        {
            "id" : "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY",
            "name": "Bob",
            "desc": "Httpbin service for testing",
            "base_url": "https://httpbin.org/anything",
            "schema": "http"
        }
    ]
}'
```

You should change `5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY` to your polkadot js wallet address.

### Query Service

The service will be published to all Apron gateway network. So you can query the above service from Alice and Bob. 

```shell
curl --location --request GET 'http://alice.example.com:8082/service'
```


```shell
curl --location --request GET 'http://bob.example.com:8083/service'
```

The two requests aboves will return the service just created.

## User

As a user, you can access the `https://httpbin.org` service behind the alice through the bob gateway.

### Use Service

The service on alice can be accessed in this way from bob.

```shell
curl http://bob.example.com:8081/v1/<plese_replace_to_your_plokadotjs_wallet_address>/foobar
```
> *foobar* can be replaced by anything. 

The respond returned should be like this:

```
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin",
    "User-Agent": "curl/7.68.0"
  },
  "json": null,
  "method": "GET",
  "origin": "192.168.0.4",
  "url": "https://httpbin.org/anything/foobar"
}
```

The gateway service on bob node should print logs like those lines:

```
2021/08/19 15:13:45 ClientSideGateway: Service name: bob_example_com:8081
2021/08/19 15:13:45 ClientSideGateway: Current services mapping: map[bob_example_com:8081:QmTRHmxvkdRoKU2jqjPqpwrAJLmWskUmpfGscmCBykwVG7]
2021/08/19 15:13:45 ClientSideGateway: Service URL requested from : http://bob.example.com:8081/v1/5DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxeP/foobar
2021/08/19 15:13:45 ClientSideGateway: servicePeerId : QmTRHmxvkdRoKU2jqjPqpwrAJLmWskUmpfGscmCBykwVG7
Path with k: "/v1/5DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxeP/foobar", match rslt: [[[47 118 49 47 53 68 99 112 118 76 110 68 80 81 74 121 111 110 51 69 72 52 107 114 101 49 87 119 87 50 66 109 100 101 83 103 68 110 69 119 52 122 119 78 69 111 114 100 78 120 101 80 47 102 111 111 98 97 114] [49] [53 68 99 112 118 76 110 68 80 81 74 121 111 110 51 69 72 52 107 114 101 49 87 119 87 50 66 109 100 101 83 103 68 110 69 119 52 122 119 78 69 111 114 100 78 120 101 80] [102 111 111 98 97 114]]]
2021/08/19 15:13:45 WriteBytesViaStream: data len: 303, stream: /proxy_req/1.0, data: "\n\x14bob_example_com:8081\x12$bd3099c7-8730-4bcf-ba22-20bf45077ecf\x1a.QmSffkuHN9Cmb5cZVpdHkGxZvyGKuYScuoN7SLfYt4JQFx*05DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxePR\x8e\x01GET /v1/5DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxeP/foobar HTTP/1.1\r\nUser-Agent: curl/7.68.0\r\nHost: bob.example.com:8081\r\nAccept: */*\r\n\r\n"
2021/08/19 15:13:45 WriteBytesViaStream: written 303 data to stream: /proxy_req/1.0
2021/08/19 15:13:45 WriteBytesViaStream: Data written
2021/08/19 15:13:45 ReadBytesViaStream: protocol: /proxy_service_http_data, read msg len: 312
2021/08/19 15:13:45 ReadBytesViaStream: Received msg from stream: /proxy_service_http_data, len: 312, data: "\x12$bd3099c7-8730-4bcf-ba22-20bf45077ecfR\x8f\x02{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"curl/7.68.0\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"192.168.0.4\", \n  \"url\": \"https://httpbin.org/anything/foobar\"\n}\n"
2021/08/19 15:13:45 ProxyHttpRespHandler: Read proxy data from stream: /proxy_service_http_data, request_id:"bd3099c7-8730-4bcf-ba22-20bf45077ecf"  raw_data:"{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"curl/7.68.0\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"192.168.0.4\", \n  \"url\": \"https://httpbin.org/anything/foobar\"\n}\n"
```

According to the log, after receiving the request, bob find services from local mapping,
and then write request bytes via stream to remote service side gateway node (which is alice in this case).
Then it will get service response from stream (`ReadBytesViaStream` line) and shown to user.

While in alice gateway node, the logs should look like:

```
2021/08/19 15:13:45 Read proxy request from stream: service_id:"bob_example_com:8081"  request_id:"bd3099c7-8730-4bcf-ba22-20bf45077ecf"  peer_id:"QmSffkuHN9Cmb5cZVpdHkGxZvyGKuYScuoN7SLfYt4JQFx"  account_id:"5DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxeP"  raw_request:"GET /v1/5DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxeP/foobar HTTP/1.1\r\nUser-Agent: curl/7.68.0\r\nHost: bob.example.com:8081\r\nAccept: */*\r\n\r\n"
Path with k: "/v1/5DcpvLnDPQJyon3EH4kre1WwW2BmdeSgDnEw4zwNEordNxeP/foobar", match rslt: [[[47 118 49 47 53 68 99 112 118 76 110 68 80 81 74 121 111 110 51 69 72 52 107 114 101 49 87 119 87 50 66 109 100 101 83 103 68 110 69 119 52 122 119 78 69 111 114 100 78 120 101 80 47 102 111 111 98 97 114] [49] [53 68 99 112 118 76 110 68 80 81 74 121 111 110 51 69 72 52 107 114 101 49 87 119 87 50 66 109 100 101 83 103 68 110 69 119 52 122 119 78 69 111 114 100 78 120 101 80] [102 111 111 98 97 114]]]
2021/08/19 15:13:45 ServiceSideGateway: Write response data: "{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"curl/7.68.0\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"192.168.0.4\", \n  \"url\": \"https://httpbin.org/anything/foobar\"\n}\n"
2021/08/19 15:13:45 resp stream is nil false
2021/08/19 15:13:45 WriteBytesViaStream: data len: 312, stream: /proxy_service_http_data, data: "\x12$bd3099c7-8730-4bcf-ba22-20bf45077ecfR\x8f\x02{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Host\": \"httpbin\", \n    \"User-Agent\": \"curl/7.68.0\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"192.168.0.4\", \n  \"url\": \"https://httpbin.org/anything/foobar\"\n}\n"
2021/08/19 15:13:45 WriteBytesViaStream: written 312 data to stream: /proxy_service_http_data
2021/08/19 15:13:45 WriteBytesViaStream: Data written
```

The process is first reading proxy request from stream, then send request to service and send back response from service via stream to client side gateway node (bob in this case).


