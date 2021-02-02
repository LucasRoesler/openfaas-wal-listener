
.PHONY: install
install:
	sudo cp -rf postgres /var/lib/faasd
	sudo mkdir -p /var/lib/faasd/postgres/pgdata
	sudo mkdir -p /var/lib/faasd/postgresql/run
	sudo cp -rf wal_listener /var/lib/faasd
	sudo cp docker-compose.yaml /var/lib/faasd
	sudo chown -R 1000:1000 /var/lib/faasd/postgres


.PHONY: restart
restart:
	sudo systemctl restart faasd faasd-provider

.PHONEY: init-db
init-db:
	psql -U postgres -h localhost -d app -f postgres/init_app.sql

mins ?= "2"

.PHONY: logs-faasd
logs-faasd:
	sudo journalctl -f -t faasd --since="${mins} minutes ago"


service ?= faasd

.PHONY: logs
logs:
	sudo journalctl -f -t openfaas:${service} --since="${mins} minutes ago"