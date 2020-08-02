# Introduction

This article details the steps needed to deploy the NK Microservices project on a Linux machine.

# Deployment

## Arango Database

The Arango Database can be deployed in [multiple modes](https://www.arangodb.com/docs/stable/deployment.html): 
* Single instance
* Master/Slave
* Active Failover
* Cluster
* Multiple Datacenters
* Standalone Agency

For simplicity purposes, it is best to deploy the database as a single instance. Moreover, the database can be deployed as a standalone Docker container using the following command:

```
docker run -d --name person-db --restart always -p 8529:8529 -e ARANGO_STORAGE_ENGINE=rocksdb -e ARANGO_ROOT_PASSWORD=openSesame arangodb/arangodb:3.6.3

```

The command above creates a Docker container hosting the Arango database, exposes port 8529, and secures the database with the following credentials:
* username: root
* password openSesame

Once deployed, through a web browser, login to the database ```http://localhost:8529```, create a database named ```persons```, and inside this database, create a collection named ```persons```.


## Redis Database

The Redis database can be installed on the machine by following any tutorial online, or as Docker container using the following command:

```
docker run -d --name redis --restart always -p 6379:6379 redis:6.0.5
```

# Gateway Service

1. Clone the repository: ```git clone https://github.com/nicolaselkhoury/nk-gateway-service.git```
2. Navigate to the repository and install the dependecies: ```npm install```
3. Install SailsJS globally: ```npm install -g sails```
3. export the required environment variables:
    * export JWT_SECRET=mydirtylittlesecret     // The JWT Secret
    * export REDIS_HOST=localhost               // The Redis host
    * export REDIS_PORT=6379                    // The Redis port
    * export BACKEND_HOST=localhost             // The Backend host
    * export BACKEND_PORT=1338                  // The backend port
    * export REQUEST_MAX_ATTEMPTS=2             // The number of times a failed request must be retried before signaling an error
4. Launch the gateway service: ```sails lift```

# Backend Service

1. Clone the repository: ```git clone https://github.com/nicolaselkhoury/nk-backend-service.git```
2. Navigate to the repository and install the dependecies: ```npm install```
3. export the required environment variables:
    * export ARANGODB_HOST=localhost             // The Arango database host
    * export ARANGODB_PORT=8529                  // The Arango database port
    * export ARANGODB_USERNAME=root              // The Arango database username
    * export ARANGODB_PASSWORD=openSesame        // The Arango database password
    * export ARANGODB_DB_NAME=persons            // The database name
    * export ARANGO_MAX_RETRY_ATTEMPTS=3         // The number of times a failed database connection request must be retried before signaling an error
    * export ARANGO_RETRY_DELAY=250              // The amount of wait time between connection attempts (in ms)
    * export JWT_SECRET=mydirtylittlesecret      // The JWT secret
    * export JWT_ACCESS_TOKEN_VALIDITY=3600      // The TTL of a JWT access token (in seconds)
    * export JWT_REFRESH_TOKEN_VALIDITY=86400    The TTL of a JWT refresh token (in seconds)
4. Launch the gateway service: ```sails lift```