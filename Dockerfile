FROM ruby:3.0-slim

WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copiar Gemfile e instalar dependências
COPY Gemfile ./
RUN bundle install

# Copiar o código da aplicação
COPY . .

# Tornar o script de download do modelo executável
COPY download_model.sh /app/
RUN chmod +x /app/download_model.sh

# Expor a porta da aplicação
EXPOSE 3008

# Usar o script para fazer download do modelo antes de iniciar a aplicação
CMD ["/app/download_model.sh"]