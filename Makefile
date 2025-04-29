.PHONY: build up down logs status clean download-model check-model restart

# Variáveis
APP_NAME=ollama-translator

# Comandos principais
build:
	docker-compose build

up:
	docker-compose up -d
	@echo "Serviço iniciado! Acesse em http://localhost:3008"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

logs-translator:
	docker-compose logs -f translator

logs-ollama:
	docker-compose logs -f ollama

status:
	docker-compose ps

# Limpar tudo
clean:
	docker-compose down -v
	docker rmi $$(docker images -q $(APP_NAME)_translator)

# Baixar o modelo manualmente
download-model:
	docker-compose exec ollama ollama pull mistral

# Verificar status do modelo
check-model:
	docker-compose exec ollama ollama list

# Iniciar tudo
all: build up
	@echo "Aguardando download do modelo Mistral..."
	@sleep 10
	@make check-model