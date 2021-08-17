# Step By Step Test Instruction for Milestone 1 Features

This document introduces how to setup a brief test Apron network to verify milestone 1 features.
The network will be launched in two docker-compose clusters.

Note: all those steps should be done on Linux system with docker installed.

## Prepare the Test Network and Esseitial Components

### Prepare the docker images

Please download apron node images from [here](https://drive.google.com/drive/folders/1W9X3BAYs9mU2VuBsnPd2axxRtPkXS9co?usp=sharing),
and apron-deployer image from **TODO**,
then load the image into system by this two commands:

```
docker load < apron-node-2021xxxx.tar.gz
docker load < apron-deployer-2021xxxx.tar.gz
```

### Setup Test Apron Network

In this directory, execute `setup.sh` script and wait about 30 seconds to wait environment done.

To verify the network ready, first check whether all containers are running,
then ensure output returned in next command is liking below:

```
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


