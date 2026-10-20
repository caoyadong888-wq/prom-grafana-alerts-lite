.PHONY: demo demo-down test

demo:
	docker compose -f demo/docker-compose.yml up -d
	@echo "Prometheus  http://127.0.0.1:9090"
	@echo "Grafana     http://127.0.0.1:3000"
	@echo "Demo login  admin / admin  (local demo only)"

demo-down:
	docker compose -f demo/docker-compose.yml down -v

test:
	bash tests/run_tests.sh
