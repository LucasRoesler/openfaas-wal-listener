# Event Driven OpenFaaS with Postgres

This is an sample of how to create an event driven application using

1. OpenFaaS faasd
2. Postgres
3. NATS
4. [my fork](https://github.com/LucasRoesler/wal-listener/tree/feature-openfaas-hacks) of [wal-listener](https://github.com/ihippik/wal-listener) 

The goal is that we can call OpenFaaS functions in response to Create, Update, and Delete events in the db.

## Install

1. install `faasd`
2. Copy the new docker-compose
   ```sh
   make install 
   # or manually run 
   # sudo cp -rf postgres /var/lib/faasd
	# sudo mkdir -p /var/lib/faasd/postgres/pgdata
	# sudo mkdir -p /var/lib/faasd/postgresql/run
	# sudo cp -rf wal_listener /var/lib/faasd
	# sudo cp docker-compose.yaml /var/lib/faasd
	# sudo chown -R 1000:1000 /var/lib/faasd/postgres
   ```
3. Restart faasd
   ```sh
   make restart
   # or manually: sudo systemctl restart faasd faasd-provider
   ```

4. Deploy the same receiver function

   ```sh
   faas-cli deploy --name receive-event --image theaxer/receive-message:latest --fprocess='./handler' --annotation topic="sample_app"
   ```

   You can then verify that the connector is sending events to tne receiver fucntion by manually publishing the topic (you need to install the [natscli](https://github.com/nats-io/natscli))

   ```sh
   $ nats pub sample_app "manual push"
   15:21:39 Published 11 bytes to "sample_app"
   $ faas-cli logs receive-event
   WARNING! Communication is not secure, please consider using HTTPS. Letsencrypt.org offers free SSL/TLS certificates.
   2021-01-24T14:19:35Z 2021/01/24 14:19:35 POST / - 200 OK - ContentLength: 27
   2021-01-24T14:19:35Z 2021/01/24 14:19:35 stderr: 2021/01/24 14:19:35 received "manual push"
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 SIGTERM received.. shutting down server in 10s
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Removing lock-file : /tmp/.lock
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Error scanning stdout: read |0: file already closed
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Error scanning stderr: read |0: file already closed
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Forked function has terminated: signal: terminated
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Started logging stderr from function.
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Started logging stdout from function.
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 OperationalMode: http
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Timeouts: read: 10s, write: 10s hard: 10s.
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Listening on port: 8080
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Writing lock-file to: /tmp/.lock
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Metrics listening on port: 8081
   2021-01-24T14:21:17Z Forking - ./handler []
   2021-01-24T14:21:39Z 2021/01/24 14:21:39 POST / - 200 OK - ContentLength: 27
   2021-01-24T14:21:39Z 2021/01/24 14:21:39 stderr: 2021/01/24 14:21:39 received "manual push"
   ```

## Verifying db events are sent

1. Generate some changes in the db

   ```sh
   make init-db
   # psql -U postgres -h localhost -d app -f postgres/init_app.sql
   ```

2. You can then see the logs as wal-listener reacts to the inserts by using 

   ```sh
   make logs service=wal-listener
   ```

3. Finally, see that our receiver function was invoked

   ```sh
   $ faas-cli logs receive-event
   WARNING! Communication is not secure, please consider using HTTPS. Letsencrypt.org offers free SSL/TLS certificates.
   2021-01-24T14:19:35Z 2021/01/24 14:19:35 POST / - 200 OK - ContentLength: 27
   2021-01-24T14:19:35Z 2021/01/24 14:19:35 stderr: 2021/01/24 14:19:35 received "manual push"
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 SIGTERM received.. shutting down server in 10s
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Removing lock-file : /tmp/.lock
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Error scanning stdout: read |0: file already closed
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Error scanning stderr: read |0: file already closed
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Forked function has terminated: signal: terminated
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Started logging stderr from function.
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Started logging stdout from function.
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 OperationalMode: http
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Timeouts: read: 10s, write: 10s hard: 10s.
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Listening on port: 8080
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Writing lock-file to: /tmp/.lock
   2021-01-24T14:21:17Z 2021/01/24 14:21:17 Metrics listening on port: 8081
   2021-01-24T14:21:17Z Forking - ./handler []
   2021-01-24T14:21:39Z 2021/01/24 14:21:39 POST / - 200 OK - ContentLength: 27
   2021-01-24T14:21:39Z 2021/01/24 14:21:39 stderr: 2021/01/24 14:21:39 received "manual push"
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 POST / - 200 OK - ContentLength: 386
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 stderr: 2021/01/24 15:04:25 received "{\"id\":\"92c431a7-9027-4656-9d39-f52ee90d5dd6\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\",\"name\":\"John Wick\",\"email\":\"wick@trouble.com\",\"id\":\"99a9c7bf-8f31-4c30-998e-9740f87bdaa0\"},\"commitTime\":\"2021-01-24T15:04:25.58604Z\"}"
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 POST / - 200 OK - ContentLength: 383
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 stderr: 2021/01/24 15:04:25 received "{\"id\":\"80a8d33a-0ae5-4aed-825d-1a7f9e24adfb\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"name\":\"James Bond\",\"email\":\"bond@mi6.com\",\"id\":\"5a6a9672-722a-40c9-8f10-17cf527a6b41\",\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\"},\"commitTime\":\"2021-01-24T15:04:25.58604Z\"}"
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 POST / - 200 OK - ContentLength: 384
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 stderr: 2021/01/24 15:04:25 received "{\"id\":\"326ea179-dddb-4c04-bd56-9f02bdec9aaa\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\",\"name\":\"Elim Garak\",\"email\":\"garak@ds9.com\",\"id\":\"b1f3cc48-6366-4bff-b0c5-3f5beed02f44\"},\"commitTime\":\"2021-01-24T15:04:25.58604Z\"}"
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 POST / - 200 OK - ContentLength: 392
   2021-01-24T15:04:25Z 2021/01/24 15:04:25 stderr: 2021/01/24 15:04:25 received "{\"id\":\"15755624-195a-4617-8d60-6b7cb748caf9\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"id\":\"3879dc32-78cd-456d-8a64-fe7fab540a7f\",\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\",\"name\":\"Sarah Walker\",\"email\":\"walker@nerdherd.com\"},\"commitTime\":\"2021-01-24T15:04:25.58604Z\"}"
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 POST / - 200 OK - ContentLength: 387
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 stderr: 2021/01/24 15:05:00 received "{\"id\":\"38f4ae55-86a1-466a-8ebd-c2f5a1054439\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"updated_at\":\"2021-01-23 16:50:53.543372+00\",\"name\":\"John Wick\",\"email\":\"wick@trouble.com\",\"id\":\"99a9c7bf-8f31-4c30-998e-9740f87bdaa0\",\"created_at\":\"2021-01-23 16:50:53.543372+00\"},\"commitTime\":\"2021-01-24T15:05:00.007715Z\"}"
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 stderr: 2021/01/24 15:05:00 received "{\"id\":\"bce01097-815d-4d73-90b9-89230ddca39b\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"email\":\"bond@mi6.com\",\"id\":\"5a6a9672-722a-40c9-8f10-17cf527a6b41\",\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\",\"name\":\"James Bond\"},\"commitTime\":\"2021-01-24T15:05:00.007715Z\"}"
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 POST / - 200 OK - ContentLength: 384
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 POST / - 200 OK - ContentLength: 385
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 stderr: 2021/01/24 15:05:00 received "{\"id\":\"45f0fc1f-a44f-4546-a7dd-2fec7079667d\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"name\":\"Elim Garak\",\"email\":\"garak@ds9.com\",\"id\":\"b1f3cc48-6366-4bff-b0c5-3f5beed02f44\",\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\"},\"commitTime\":\"2021-01-24T15:05:00.007715Z\"}"
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 POST / - 200 OK - ContentLength: 393
   2021-01-24T15:05:00Z 2021/01/24 15:05:00 stderr: 2021/01/24 15:05:00 received "{\"id\":\"cd03a0b0-8c98-4809-9347-9f469c773de0\",\"schema\":\"public\",\"table\":\"users\",\"action\":\"UPDATE\",\"data\":{\"created_at\":\"2021-01-23 16:50:53.543372+00\",\"updated_at\":\"2021-01-23 16:50:53.543372+00\",\"name\":\"Sarah Walker\",\"email\":\"walker@nerdherd.com\",\"id\":\"3879dc32-78cd-456d-8a64-fe7fab540a7f\"},\"commitTime\":\"2021-01-24T15:05:00.007715Z\"}"
   ```