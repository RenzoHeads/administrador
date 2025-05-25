require 'json'
require 'securerandom'
require 'langchain'

# # === CONTROLADORES PARA listas ===

# # Crear lista
post '/listas/crear' do
    data = JSON.parse(request.body.read)
    lista = Lista.new(
      usuario_id: data['usuario_id'],
      nombre: data['nombre'],
      descripcion: data['descripcion'],
      color: data['color']
    )
    lista.save
    [200, lista.to_json]
  end
  
get '/listas/:usuario_id' do
    listas = Lista.where(usuario_id: params[:usuario_id]).all
    listas.empty? ? [404, 'Sin listas'] : [200, listas.to_json]
  end


    # Actualizar lista
put '/listas/actualizar/:id' do
    data = JSON.parse(request.body.read)
    lista = Lista.first(id: params[:id])
    if lista
      lista.update(
        usuario_id: data['usuario_id'],
        nombre: data['nombre'],
        descripcion: data['descripcion'],
        color: data['color']
      )
      [200, lista.to_json]
    else
      [404, 'Lista no encontrada']
    end
  end

    # Eliminar lista
delete '/listas/eliminar/:id' do
    lista = Lista.first(id: params[:id])
    if lista
      lista.destroy
      [200, 'Lista eliminada']
    else
      [404, 'Lista no encontrada']
    end
  end   

  #Obtener cantidad de tareas por lista
get '/listas/cantidad_tareas/:id' do
  content_type :json
  lista = Lista.first(id: params[:id])
  if lista
    cantidad_tareas = Tarea.where(lista_id: lista.id).count
    { cantidad_tareas: cantidad_tareas }.to_json
  else
    status 404
    { error: 'Lista no encontrada' }.to_json
  end
end

#Obtener cantidad de tareas en estado pendiente por lista
get '/listas/cantidad_tareas_pendientes/:id' do
  content_type :json
  lista = Lista.first(id: params[:id])
  if lista
    cantidad_tareas_pendientes = Tarea.where(lista_id: lista.id, estado_id: 1).count # Asumiendo que el estado "pendiente" tiene id 1
    { cantidad_tareas_pendientes: cantidad_tareas_pendientes }.to_json
  else
    status 404
    { error: 'Lista no encontrada' }.to_json
  end
end

#Obtener cantidad de tareas en estado completada por lista
get '/listas/cantidad_tareas_completadas/:id' do
  content_type :json
  lista = Lista.first(id: params[:id])
  if lista
    cantidad_tareas_completadas = Tarea.where(lista_id: lista.id, estado_id: 2).count # Asumiendo que el estado "completada" tiene id 2
    { cantidad_tareas_completadas: cantidad_tareas_completadas }.to_json
  else
    status 404
    { error: 'Lista no encontrada' }.to_json
  end
end


#Obtener lista por id 

get '/listas/obtener/:id' do
  content_type :json
  lista = Lista.first(id: params[:id])
  if lista
    { lista: lista.to_json }.to_json
  else
    status 404
    { error: 'Lista no encontrada' }.to_json
  end
end

# Obtener listas por usuario con nombre, cantidad de tareas pendientes y cantidad total de tareas
get '/listas/usuario/:usuario_id' do
  content_type :json

  listas = Lista.where(usuario_id: params[:usuario_id]).to_a

  resultado = listas.map do |lista|
    total_tareas = Tarea.where(lista_id: lista.id).count
    tareas_pendientes = Tarea.where(lista_id: lista.id, estado_id: 1).count
    {
      id: lista.id,
      nombre: lista.nombre,
      cantidad_tareas: total_tareas,
      cantidad_tareas_pendientes: tareas_pendientes
    }
  end
  
  { listas: resultado }.to_json
end

# Generar lista con tareas usando IA
post '/listas/generar_ia' do
  content_type :json

  request_payload = JSON.parse(request.body.read)
  user_prompt = request_payload['prompt'] || ''

  json_schema = {
    type: 'object',
    properties: {
      lista: {
        type: 'object',
        properties: {
          nombre: { type: 'string' },
          descripcion: { type: 'string' },
          color: { type: 'string', description: 'Color HEX aleatorio' },
          tareas: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                nombre: { type: 'string' },
                descripcion: { type: 'string' },
                fecha_creacion: { type: 'string', format: 'date' },
                fecha_vencimiento: { type: 'string', format: 'date' }
              },
              required: ['nombre', 'descripcion'],
              additionalProperties: false,
              description: "Una lista de tareas basada en el prompt del usuario."
            },
            minItems: 1,
            maxItems: 5,
          }
        },
        required: ['nombre', 'descripcion', 'color', 'tareas'],
        additionalProperties: false,
      }}
  }

  parser = Langchain::OutputParsers::StructuredOutputParser.from_json_schema(json_schema)
  prompt = Langchain::Prompt::PromptTemplate.new(
    template: "Genera una lista de tareas basada en el siguiente prompt del usuario: '{user_prompt}'. La fecha actual es '{fecha_actual}. 'El formato de la respuesta debe ser:\n\n{json_schema}\n\n",
    input_variables: ["user_prompt", "fecha_actual","json_schema"],
  )
  prompt_text = prompt.format(user_prompt: user_prompt, fecha_actual: Date.today, json_schema: parser.get_format_instructions)

  llm = Langchain::LLM::GoogleGemini.new(
    api_key: ENV["GEMINI_API_KEY"],
    default_options: {
      chat_model: "gemini-2.0-flash",
      temperature: 0.5,
    }
  )

  response = llm.chat(messages: [{ role: "user", parts: [{ text: prompt_text }]}])

  parsed_response = nil
  
  # En caso el parser inicial de un error, se usa el OutputParserException para volver a pasearlo (como un backup)
  begin
    parsed_response = parser.parse(response.chat_completion)
  rescue Langchain::OutputParsers::OutputParserException => e
    puts "Error: #{e}"

    fix_parser = Langchain::OutputParsers::OutputFixingParser.from_llm(
      llm: llm,
      parser: parser
    )

    parsed_response = fix_parser.parse(response.chat_completion)
  end
  
  parsed_response.to_json
end

