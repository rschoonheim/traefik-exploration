start:
	@echo "Starting the application..."
	@bash ./scripts/start.sh
	@echo "Application started successfully."

refresh-certs:
	@echo "Refreshing TLS certificates..."
	@bash ./scripts/remove-tls-certs.sh
	@make certs
	@echo "TLS certificates refreshed successfully."

certs:
	@echo "Generating TLS certificates..."
	@docker compose -f docker-compose.utilities.yaml run --rm generate-tls
	@echo "TLS certificates generated successfully."