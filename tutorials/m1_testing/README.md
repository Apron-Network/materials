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

## User

As a user, you access the `https://httpbin.org` service behind the alice through the bob gateway.

### Use Service

The service on alice can be accessed in this way from bob.

```shell
curl http://bob.example.com:8081/v1/<plese_replace_to_your_plokadotjs_wallet_address>/foobar
```
*foobar* can be replaced by anything. 

### Check Service and Usage Reponrt on Marketplace
