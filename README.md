# Event Driven OpenFaaS with Postgres

This is an sample of how to create an event driven application using

1. OpenFaaS faasd
2. Postgres
3. NATS
4. [wal-listener](https://github.com/ihippik/wal-listener) 


## Install

1. install `faasd`
2. Copy the new docker-compose
   ```sh
   make install 
   # or manually run 
   # sudo cp -r postgres /var/lib/faasd
   # sudo cp -r wal_listener /var/lib/faasd
   # sudo cp docker-compose.yaml /var/lib/faasd
   ```
3. Restart faasd
   ```sh
   make restart
   # or manually: sudo systemctl restart faasd faasd-provider
   ```

## Verifying the install

```sh
make init-db
# psql -U postgres -h localhost -d app -f postgres/init_app.sql
```

You can then see the logs as wal-listener reacts to the inserts by using 

```sh
make logs-listener
```
