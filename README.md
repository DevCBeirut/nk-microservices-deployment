# Introduction
The **NK Microservices** project serves as a pilot project and/or a reference to be used by anyone who wishes to write software using the Microservices approach. Indeed, Microservices is a software development methodology that is being adopted widely nowadays, especially with the advancement of the technology, and the adoption of cloud computing resources.

This project is basic, open source, and welcomes everyone who wishes to contribute to it, by enhacing it, adding new features, and suggesting recommendations.

# Project components
This project is made of the following components:

* **[Gateway Microservice](https://github.com/nicolaselkhoury/nk-gateway-service)**: A REST API Microservice built using [SailsJS](https://sailsjs.com/), and serves as a Gateway, and request router.
* **[Backend Microservice](https://github.com/nicolaselkhoury/nk-backend-service)**: A REST API Microservice built using [SailsJS](https://sailsjs.com/), and serves as the first, out of many Microservices which can be incorporated and integrated with the aforementioned Gateway Service.
* **[Redis Database](https://redis.io/)**: An open source, in-memory data store, used for caching purposes, and for storing other ephemeral pieces of information such as JWT tokens.
* **[Arango Database](https://www.arangodb.com/)**: A multi-model database used for storing persistent information.

The project requires all of the aforementioned components to be set up in order to function properly.

# Project Goals:
The purpose of this project is to set up some of the many best practices required when developing Microservices:

* Proper inter-service communication using [REST APIs](https://en.wikipedia.org/wiki/Representational_state_transfer) along with solid retry mechanisms.
* Proper database communication along with solid retry mechanisms.
* Proper error handling.
* Proper project structure.
* Proper way of writing code.
* Proper logging mechanisms.
* Proper request tracing mechanisms.
* Proper authentication mechanisms.
* Proper caching mechanisms.

# Project Explanation
The project exposes CRUD and Login APIs for "persons". The project allows the creation, deletion, retrieval of all or one person record, in addition to an API that allows a person to login, and an API that refreshes JWT tokens. The purpose of this project is not about creating a solid platform for a business, but rather to be simple enough to allow developers to comprehend and adopt/enhance the APIs and logic used to write these APIs. 

That being said, section [API Explanation](#API-Explanation) a detailed explanation of every API in the project, along with a sample request and response. To better understand the project, it is recommended to read, understand, and test the code using the [POSTMAN collection](nk-gateway-service.postman_collection.json) found in this repository, or by simulating the requests found in the documentation.

# Project Setup
As part of the goals of this project, multiple modes of deployment will be provided. This sections will be updated as more deployment modes will be added. Below is the list of available deployment modes for the project:

* [Linux Machine](deployment-modes/linuxMachine.md)
* [Docker Swarm Services](deployment-modes/dockerSwarm/dockerSwarm.md)
* [Terraform - AWS EC2 Deployment](deployment-modes/terraform/aws/ec2/README.md)

# Notes
1. folder ```api/controllers``` of every service contains a list of files, each of which represents an API.
2. folder ```api/helpers``` of every service contains a list of files, each of which represents a global helper function, that can be used by other APIs or helper functions.
3. folder ```api/policies``` of every service contains a list of files, each of which represents a policy.
4. folder ```api/responses``` of every service contains a list of files, each of which represents a resonse type.
5. file ```config/custom.js``` of every service contains a list of user defined global variables.
6. file ```config/routes.js``` of every service contains a list of routes, each of which is linked to a controller file (API).
7. file ```config/http.js``` of every service adds a request ID to the incoming request. This ID is used to trace the request through its journey from and back to the client.
8. file ```config/bootstrap.js``` contains user generated scripts that get executed before the launch of the service (i.e., The backend service initializes the Arango database and collection).
# API Explanation
All the requests must hit the Gateway microservice, and never the backend microservice directly.

## Create person (Sign up)

This API allows to create a person. A person can be an admin or a regular person (denoted by a boolean value {isAdmin: false | true}).

1. The request hits the gateway service.
2. The gateway service routes the request to the backend microservice.
3. The backend service hashes the password received.
4. The backend service, performs a transaction against the database, checks if the person is already created (using the email). If the person is created, a logicalError is returned. Else, the person is created in the database, and a success response is returned to the gateway service.
5. The gateway service returns the response to the client.

### Sample request
```
curl --location --request POST 'http://localhost:1337/backend/person' \
--header 'Content-Type: application/json' \
--data-raw '{
	"firstName": "person",
	"lastName": "Lastname",
	"age": 29,
	"isAdmin": false,
	"email": "lastname@gmail.com",
	"password": "123456789",
	"dob": "1990-06-10"
}'
```

### Sample success response
```
{
  "status": "success",
  "data": {
    "_key": "861206",
    "_id": "persons/861206",
    "_rev": "_a5_7Jp6---",
    "firstName": "person",
    "lastName": "Lastname",
    "age": 29,
    "dob": "1990-06-10",
    "email": "lastname@gmail.com",
    "isAdmin": false,
    "password": "$2b$10$qTSfZxvRNf7UvwOsBYzwbuVPq.HPDOkK36YB4TBmkxMASaehF9jLC",
    "createdAt": 1596393860798,
    "updatedAt": 1596393860798,
    "isActive": true
  }
}
```

One can create another person record with the ```{isAdmin: true}``` property.

## Login

This API allows a person to login by supplying the email and password. 

1. The request hits the gateway service.
2. The gateway service routes the request to the backend microservice.
3. The backend service attempts to fetch the person from the database (using the email).
4. If the person is not found in the database, an error message is returned to the gateway service, and then to the client.
5. If the person is found, the password is hashed and compared to the hashed password retrieved from the database.
6. If the passwords don't match, an error message is returned to the gateway service, an then to the client.
7. If the passwords match, a JWT access token, and a JWT refresh tokens, are created, each of which contain some relevant information of the person.
8. The backend service returns the person information, along with the access tokens to the gateway service.
9. The gateway service stores the access tokens in Redis to be used later for authentication.
10. The gateway service returns to the client the person information, along with the access tokens.

### Sample request
```
curl --location --request POST 'http://localhost:1337/backend/login' \
--header 'Content-Type: application/json' \
--header 'Cookie: sails.sid=s%3ATJZHmggewCrVt5KwM3g-MSP5RpNesqN8.DVNdU6xcRXEXlbFXAsXCmhC1zRN3a%2F4iy5WJ3txVt7o' \
--data-raw '{
    "email": "lastname@gmail.com",
    "password": "123456789"
}'
```

### Sample response
```
{
  "status": "success",
  "data": {
    "person": {
      "_key": "861206",
      "_id": "persons/861206",
      "_rev": "_a5_7Jp6---",
      "firstName": "person",
      "lastName": "Lastname",
      "age": 29,
      "dob": "1990-06-10",
      "email": "lastname@gmail.com",
      "isAdmin": false,
      "password": "$2b$10$qTSfZxvRNf7UvwOsBYzwbuVPq.HPDOkK36YB4TBmkxMASaehF9jLC",
      "createdAt": 1596393860798,
      "updatedAt": 1596393860798,
      "isActive": true
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoibGFzdG5hbWVAZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOmZhbHNlLCJwZXJzb25JZCI6Ijg2MTIwNiIsImRhdGUiOiIyMDIwLTA4LTAyVDE4OjUxOjMzLjE0N1oifSwiaWF0IjoxNTk2Mzk0MjkzLCJleHAiOjE1OTYzOTc4OTN9.5XuJVQegumXwtSQpS0EuYMKXrWzzp0-xmVuznQESiCs",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoibGFzdG5hbWVAZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOmZhbHNlLCJwZXJzb25JZCI6Ijg2MTIwNiIsImRhdGUiOiIyMDIwLTA4LTAyVDE4OjUxOjMzLjE0OVoifSwiaWF0IjoxNTk2Mzk0MjkzLCJleHAiOjE1OTY0ODA2OTN9._LK0os4a6loHKLW1dIpmd0abQiOgpp2gUISejRAb3FA"
    }
  }
}
```

## Refresh Token

This API refresh the access and refresh tokens of a person.

1. The request hits the gateway service.
2. The gateway service routes the request to the backend microservice.
3. The backend service verifies the validity of the refresh token.
4. If the refresh token is invalid (Not found, or expired, etc), an Unauthorized response is returned to the client.
5. If the refresh token is valid, new access and refresh tokens are generated and returned to the gateway service.
6. The gateway service deletes the old tokens from Redis, and inserts the new ones, and returns them to the client.

### Sample request
```
curl --location --request PUT 'http://localhost:1337/backend/token/refresh' \
--header 'Content-Type: application/json' \
--header 'Cookie: sails.sid=s%3ATJZHmggewCrVt5KwM3g-MSP5RpNesqN8.DVNdU6xcRXEXlbFXAsXCmhC1zRN3a%2F4iy5WJ3txVt7o' \
--data-raw '{
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoibGFzdG5hbWVAZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOmZhbHNlLCJwZXJzb25JZCI6Ijg2MTIwNiIsImRhdGUiOiIyMDIwLTA4LTAyVDE4OjUxOjMzLjE0N1oifSwiaWF0IjoxNTk2Mzk0MjkzLCJleHAiOjE1OTYzOTc4OTN9.5XuJVQegumXwtSQpS0EuYMKXrWzzp0-xmVuznQESiCs",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoibGFzdG5hbWVAZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOmZhbHNlLCJwZXJzb25JZCI6Ijg2MTIwNiIsImRhdGUiOiIyMDIwLTA4LTAyVDE4OjUxOjMzLjE0OVoifSwiaWF0IjoxNTk2Mzk0MjkzLCJleHAiOjE1OTY0ODA2OTN9._LK0os4a6loHKLW1dIpmd0abQiOgpp2gUISejRAb3FA"
    }'
```

### Sample response
```
{
  "status": "success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoibGFzdG5hbWVAZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOmZhbHNlLCJwZXJzb25JZCI6Ijg2MTIwNiIsImRhdGUiOiIyMDIwLTA4LTAyVDE4OjUzOjQxLjM2M1oifSwiaWF0IjoxNTk2Mzk0NDIxLCJleHAiOjE1OTYzOTgwMjF9.0l5pJ4SLOnevdRd0egcZPgealrhj4zAf1XUejqomStE",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoibGFzdG5hbWVAZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOmZhbHNlLCJwZXJzb25JZCI6Ijg2MTIwNiIsImRhdGUiOiIyMDIwLTA4LTAyVDE4OjUzOjQxLjM2M1oifSwiaWF0IjoxNTk2Mzk0NDIxLCJleHAiOjE1OTY0ODA4MjF9.Ut1VYdV690kKUVZcKOC1MhvxxsNS3NxYKcao1MM3pkw"
  }
}
```

## Get Persons
Retrieves the list of all person records found in the database. The purpose of this API is to introduct caching.

1. The request hits the gateway service.
2. The gateway service attempts find the persons in redis.
3. If the persons are found in redis, the result is directly returned to the client.
4. The gateway service routes the request to the backend microservice.
5. If the persons are not found in redis, the gateway service routes the request to the backend service.
6. The backend service attempts to fetch the list of persons from the database.
7. The backend service returns the list to the gateway service.
8. The gateway service caches the response in redis, and returns the result to the client.

### Sample request

```
curl --location --request GET 'http://localhost:1337/backend/persons' \
--header 'Cookie: sails.sid=s%3ATJZHmggewCrVt5KwM3g-MSP5RpNesqN8.DVNdU6xcRXEXlbFXAsXCmhC1zRN3a%2F4iy5WJ3txVt7o'
```

### Sample response
```
{
  "status": "success",
  "data": [
    {
      "_key": "861206",
      "_id": "persons/861206",
      "_rev": "_a5_7Jp6---",
      "firstName": "person",
      "lastName": "Lastname",
      "age": 29,
      "dob": "1990-06-10",
      "email": "lastname@gmail.com",
      "isAdmin": false,
      "password": "$2b$10$qTSfZxvRNf7UvwOsBYzwbuVPq.HPDOkK36YB4TBmkxMASaehF9jLC",
      "createdAt": 1596393860798,
      "updatedAt": 1596393860798,
      "isActive": true
    },
    {
      "_key": "861865",
      "_id": "persons/861865",
      "_rev": "_a5AOk2K---",
      "firstName": "admin",
      "lastName": "Lastname",
      "age": 29,
      "dob": "1990-06-10",
      "email": "adminadmin@gmail.com",
      "isAdmin": false,
      "password": "$2b$10$yS3c9SOEeLcJamvCSCyhpehtGpGU2uSYFFCzfxdaiJb3Y4jIHCuIm",
      "createdAt": 1596395133827,
      "updatedAt": 1596395133827,
      "isActive": true
    }
  ]
}
```

## Get Person Details
Fetches the information of an authenticated person. The purpose of this API is to introduce a proper person authentication.

1. The request hits the gateway service.
2. The gateway service passes the request through the ```user policy```. 
3. The user policy checks the validity of the access token supplied through the headers of the request.
4. If the access token is invalid, an error response is returned to the client.
5. If the access token is valid, the relevant data is extracted from the access token, and passed to the backend service through an API call.
6. The backend service fetches the information of the person and returns them to the client.

### Sample request
```
curl --location --request GET 'http://localhost:1337/backend/person' \
--header 'authorization: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoiYWRtaW5AZ21haWwuY29tIiwiaXNBY3RpdmUiOnRydWUsImlzQWRtaW4iOnRydWUsInBlcnNvbklkIjoiODQwMDI2IiwiZGF0ZSI6IjIwMjAtMDctMzBUMTM6MzE6NTQuMTk4WiJ9LCJpYXQiOjE1OTYxMTU5MTQsImV4cCI6MTU5NjExOTUxNH0.rCHSaKxGZ9wQtLwzaowwln4BeoFMUW1yODWMB6HIqq4' \
--header 'Cookie: sails.sid=s%3ATJZHmggewCrVt5KwM3g-MSP5RpNesqN8.DVNdU6xcRXEXlbFXAsXCmhC1zRN3a%2F4iy5WJ3txVt7o'
```

```
{
  "status": "success",
  "data": [
    {
      "_key": "861206",
      "_id": "persons/861206",
      "_rev": "_a5_7Jp6---",
      "firstName": "person",
      "lastName": "Lastname",
      "age": 29,
      "dob": "1990-06-10",
      "email": "lastname@gmail.com",
      "isAdmin": false,
      "password": "$2b$10$qTSfZxvRNf7UvwOsBYzwbuVPq.HPDOkK36YB4TBmkxMASaehF9jLC",
      "createdAt": 1596393860798,
      "updatedAt": 1596393860798,
      "isActive": true
    }
  ]
```

## Delete Person
this API allows an admin to delete a person. The purpose of this API is to introduce a proper person authentication.

1. The request hits the gateway service.
2. The gateway service passes the request through the ```admin policy```. 
3. The admin policy checks the validity of the access token supplied through the headers of the request.
4. If the access token is invalid, an error response is returned to the client.
5. If the access token is valid, the policy checks that the person is an admin.
6. If the person is not an admin, an error message is returned to the client.
7. If the person is an admin, the request is routed to the backend service.
8. The backend service deletes (soft deletion) the desired person from the database.
9. A success response is returned to the client.

### Sample request

An admin is attempting to delete user with ID 861206

```
curl --location --request DELETE 'http://localhost:1337/backend/person/861206' \
--header 'authorization: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImVtYWlsIjoiYWRtaW5hZG1pbkBnbWFpbC5jb20iLCJpc0FjdGl2ZSI6dHJ1ZSwiaXNBZG1pbiI6dHJ1ZSwicGVyc29uSWQiOiI4NjE4NjUiLCJkYXRlIjoiMjAyMC0wOC0wMlQxOToxOToyNS42MThaIn0sImlhdCI6MTU5NjM5NTk2NSwiZXhwIjoxNTk2Mzk5NTY1fQ.sNQov7Vw3LeYXfvZH1fnP_Jtn5lYxnHYhMuT2oMVOS0' \
--header 'Cookie: sails.sid=s%3ATJZHmggewCrVt5KwM3g-MSP5RpNesqN8.DVNdU6xcRXEXlbFXAsXCmhC1zRN3a%2F4iy5WJ3txVt7o'
```

### Sample response

```
{
  "status": "success",
  "data": [
    {
      "_key": "861206",
      "_id": "persons/861206",
      "_rev": "_a5AbdoW--_",
      "firstName": "person",
      "lastName": "Lastname",
      "age": 29,
      "dob": "1990-06-10",
      "email": "lastname@gmail.com",
      "isAdmin": false,
      "password": "$2b$10$qTSfZxvRNf7UvwOsBYzwbuVPq.HPDOkK36YB4TBmkxMASaehF9jLC",
      "createdAt": 1596393860798,
      "updatedAt": 1596395978404,
      "isActive": false,
      "deletedAt": 1596395978404
    }
  ]
}
```

One can use the access token of a person that is not admin. The API will not allow the person to perform this operation.

# Future Enhancements

The project, in its current state is very basic. Any enhancement, addition, and modification is welcomed to the project. However, any modification to the code requires modifications to the documentation files in this repository. Some of the enhancements include but are not limited to:

* Better error handling
* Better user authentication mechanisms
* Addition of other APIs
* The incorporation of other microservices (of any kind)

This project is created by the community, and for the community. Everyone is encouraged to participate in this project, whether to learn, or to teach.



