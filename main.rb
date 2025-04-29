require 'sinatra'
require 'json'
require 'httparty'
require 'logger'

# Configuração do logger
logger = Logger.new('ollama_translator.log')
logger.level = Logger::INFO

# Configuração do Sinatra
set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 3008
set :environment, :production
disable :protection
set :protection, except: [:remote_token, :frame_options, :json_csrf]

# CORS (Cross-Origin Resource Sharing)
before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
          'Access-Control-Allow-Headers' => 'Content-Type'
end

options "*" do
  200
end

# Configuração do Ollama
OLLAMA_URL = ENV['OLLAMA_URL'] || 'http://localhost:11434/api/generate'
MODEL = ENV['OLLAMA_MODEL'] || 'mistral'

# Cache para traduções
TRANSLATION_CACHE = {}

# Função para criar chave de cache
def cache_key(text, direction)
  "#{text}:#{direction}"
end

# Função para traduzir texto usando Ollama
def translate_with_ollama(text, direction)
  return { error: "Texto vazio" }.to_json if text.nil? || text.strip.empty?

  # Verificar cache
  cache_key_str = cache_key(text, direction)
  if TRANSLATION_CACHE[cache_key_str]
    logger.info("Usando tradução em cache para: #{text}")
    return TRANSLATION_CACHE[cache_key_str]
  end

  # Preparar o prompt baseado na direção
  if direction == :pt_to_en
    prompt = "Translate the following Portuguese text to English. Return only the translation as plain text without any explanations or additional text:\n\n#{text}"
  else # :en_to_pt
    prompt = "Translate the following English text to Portuguese. Return only the translation as plain text without any explanations or additional text:\n\n#{text}"
  end

  # Preparar payload para Ollama
  payload = {
    model: MODEL,
    prompt: prompt,
    stream: false
  }

  begin
    logger.info("Enviando solicitação para Ollama - Direção: #{direction}")
    logger.info("Texto para tradução: #{text}")

    # Fazer requisição para Ollama
    response = HTTParty.post(
      OLLAMA_URL,
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: 30
    )

    logger.info("Código de resposta: #{response.code}")

    if response.code == 200
      begin
        result = JSON.parse(response.body)
        translation = result['response'].strip

        # Formatar resposta como esperado pela aplicação original
        formatted_response = [{
          "translation_text" => translation
        }].to_json

        # Armazenar no cache
        TRANSLATION_CACHE[cache_key_str] = formatted_response

        logger.info("Tradução bem sucedida")
        return formatted_response
      rescue JSON::ParserError => e
        logger.error("Erro ao processar JSON: #{e.message}")
        return { error: "Erro ao processar resposta" }.to_json
      end
    else
      logger.error("Erro HTTP #{response.code}: #{response.body}")
      return { error: "Erro na tradução (#{response.code})" }.to_json
    end

  rescue StandardError => e
    logger.error("Erro inesperado: #{e.message}")
    return { error: "Erro inesperado na tradução" }.to_json
  end
end

# Endpoint para tradução de Português para Inglês
post '/pt-to-en' do
  data = JSON.parse(request.body.read) rescue {}
  text = data['inputs'] || params['inputs']

  if text.nil? || text.strip.empty?
    status 400
    return { error: "Texto vazio" }.to_json
  end

  result = translate_with_ollama(text, :pt_to_en)
  status 200
  result
end

# Endpoint para tradução de Inglês para Português
post '/en-to-pt' do
  data = JSON.parse(request.body.read) rescue {}
  text = data['inputs'] || params['inputs']

  if text.nil? || text.strip.empty?
    status 400
    return { error: "Texto vazio" }.to_json
  end

  result = translate_with_ollama(text, :en_to_pt)
  status 200
  result
end

# Rota para verificar status do serviço
get '/status' do
  {
    status: "online",
    model: MODEL,
    endpoints: ["/pt-to-en", "/en-to-pt"]
  }.to_json
end

# Iniciar o servidor
logger.info("Servidor de tradução Ollama iniciado na porta #{settings.port}")
logger.info("Usando modelo: #{MODEL}")
logger.info("URL do Ollama: #{OLLAMA_URL}")
