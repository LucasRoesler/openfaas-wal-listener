
.PHONY: install
install: 
	sudo cp -rf postgres /var/lib/faasd
	sudo cp -rf wal_listener /var/lib/faasd
	sudo cp docker-compose.yaml /var/lib/faasd


.PHONY: restart
restart:
	sudo systemctl restart faasd faasd-provider

.PHONEY: init-db
init-db:
	psql -U postgres -h localhost -d app -f postgres/init_app.sql

mins ?= "2"

.PHONY: logs-faasd
logs-faasd:
	sudo journalctl -t faasd --since="${mins} minutes ago"

.PHONY: logs-listener
logs-listener:
	sudo journalctl -t openfaas:wal-listener --since="${mins} minutes ago"

