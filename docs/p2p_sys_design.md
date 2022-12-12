# Apron Network Design Doc

## Introduction

Apron Network provides a decentralized platform which can be used to access services for DApp developers,
DApp users, and operators.

The Apron Network contains those components:

* Marketplace
* Gateway Network
* Apron Node and Contract

All of those componets will be introduced below.

## Marketplace

> Note: Using marketplace requires install polkadotjs wallet

Marketplace is a web app building based on Vuejs.
The code can be found [here](https://github.com/Apron-Network/marketplace_before_build)


## Gateway Network

Gateway network manages the services, and forwards request from client to service provider,
also the network records service usage for each user, which can be checked by user or service provider.
The code for p2p version gateway can be found [here](https://github.com/Apron-Network/apron-gateway-p2p).

![system_overview](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/ApronNetworkP2P_overview.png)


The diagram above shows the general overview of the system.
The central part is the gateway network and apron network, which are two p2p networks.
This section is focusing on gateway network and the apron network will be introduced next section.

### Build gateway network

The gateway network uses DHT for peering and content routing.
While building the network from scratch, a bootstrap node should be created in first step,
and the coming nodes should connect to the bootstrap node to join the network.

### Entities

For better describing the gateway network usage, we define those entities:

* Client: The entity require using the service regisitered to network.
* Client Side Gateway: The gateway node which client connected to.
* Service Side Gateway: The gateway node which can connect to service.
* Service: service the client requested.

The gateways in the above list are nodes in the gateway network,
while client and service are external entities.
Those entities will be used below to describe function flow.

### Regisite Service

Service should be registered before client can use it. Here is a sequence diagram for service regisitration.

![reg_new_service](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/ApronGatewayP2P_newService.png)


The node accepted service registration request, will be trade as this service's service side gateway,
and all request sent to this service will be forwarded by this gateway node.
Also the usage report of this service can only be fetched from this node.
Only the service side gateway contains all detail of the service,
and the service info is saved in local service store of the gateway.

After local service store updated, a service update datapack will be published to the full network with pubsub protocol.
All other gateway nodes received this info will save service name and related service side gateway peer id in its remote service store.


### Using Service

After service created, all other nodes can access this service via gateway network.
The client send request to any gateway node, the one accept the request will be trade as client side gateway.
Once received the request, client side gateway find the service in remote service store,
if found, the request data will be wrapped to `ApronServiceRequest` object and send to service side gateway by libp2p stream.
Besides, a message channel for this request will be built and wait for response message forwarded by service side gateway.

In service side gateway, the data sent from stream will be processed by configured message handler.
After receiving `ApronServiceRequest` data package, it will first detect whether this is a RESTful or websocket request,
since the flow of those two requests are different.


For RESTful request, service side gateawy send RESTful request to service, then packet response to `ApronServiceData` package and send back via stream.

![proxy_restful_req](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/ApronGatewayP2P_proxyRestful.png)

While for websocket request, service side gateway first creates websocket connection between service,
then two separated coroutines to handle message send from client and from service.
![proxy_ws_req](https://raw.githubusercontent.com/Apron-Network/materials/main/graphics/ApronGatewayP2P_proxyWebsocket.png)


## Apron Node and Contracts

The blockchain behinde gateay node is built based on substrate framework.
Substrate is a modular framework that enables you to create purpose-built blockchains by composing custom or pre-built components.

The apron node code can be found [here](https://github.com/Apron-Network/apron-node),
and the [deployment document](https://github.com/Apron-Network/apron-node#readme).
While the contract code can be found [here](https://github.com/Apron-Network/apron-contracts),
and the [deployment document](https://github.com/Apron-Network/apron-contracts#readme).

There two contracts are added to the node, which are *services_market* and *services_statistics*.

### services_market

This contract provides functions for adding and querying services.
For adding service, the request will be saved to internal `service_map` data structure,
and the `service_index` data will be saved to `services_map_by_provider` and `services_map_by_provider` data structure.
After all things done, an `AddService` event will be emit to the chain.

For querying services, this contract provides query by uuid, index and provider, it also support list all added services.

### services_statistics

This contract fetches usage report from gateway and provides query interface for usage.
The usage is fetched from gateway API, and the request is sent periodically,
and after fetchting the data, some internal processing will be made so the data can be queried quickly.

