#!/bin/bash

# Aguardar o serviço Ollama estar disponível
echo "Aguardando o serviço Ollama..."
until $(curl --output /dev/null --silent --fail http://ollama:11434/api/health); do
  printf '.'
  sleep 5
done

echo "Verificando se o modelo mistral já está disponível..."
if ! curl -s http://ollama:11434/api/tags | grep -q "mistral"; then
  echo "Baixando o modelo mistral..."
  curl -X POST http://ollama:11434/api/pull -d '{"name": "mistral"}'
  echo "Modelo mistral baixado com sucesso!"
else
  echo "Modelo mistral já está disponível!"
fi

echo "Iniciando a aplicação translator..."
exec ruby /app/main.rb