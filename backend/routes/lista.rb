require 'json'
require 'securerandom'
require 'langchain'

# === CONTROLADORES PARA LISTAS ===

# Crear lista - PROTEGIDO
post '/listas/crear' do
  authenticate_jwt!
  content_type :json
  
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

# Obtener listas por usuario - PROTEGIDO
get '/listas/:usuario_id' do
  authenticate_jwt!
  content_type :json
  
  listas = Lista.where(usuario_id: params[:usuario_id]).all
  listas.empty? ? [404, 'Sin listas'] : [200, listas.to_json]
end

# Actualizar lista - PROTEGIDO
put '/listas/actualizar/:id' do
  authenticate_jwt!
  content_type :json
  
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

# Eliminar lista y sus tareas relacionadas - PROTEGIDO
delete '/listas/eliminar/:id' do
  authenticate_jwt!
  content_type 'application/json; charset=utf-8'

  begin
    lista = Lista.first(id: params[:id])
  rescue StandardError => e
    [500, { message: 'Error al encontrar la lista' }.to_json]
  end

  return [404, { message: 'Lista no encontrada' }.to_json] unless lista

  tareas_ids = []

  begin
    tareas = Tarea.where(lista_id: lista.id)

    tareas_ids = tareas.map(&:id)

    tareas.destroy

    lista.destroy

    raise StandardError, 'Error genérico'
  rescue StandardError => e
    [500, { message: 'Error al eliminar los datos' }.to_json]
  end
  
  [200, { message: 'Lista y tareas relacionadas eliminadas', tareas_ids: tareas_ids }.to_json]
end

# Obtener cantidad de tareas por lista - PROTEGIDO
get '/listas/cantidad_tareas/:id' do
  authenticate_jwt!
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

# Obtener cantidad de tareas en estado pendiente por lista - PROTEGIDO
get '/listas/cantidad_tareas_pendientes/:id' do
  authenticate_jwt!
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

# Obtener cantidad de tareas en estado completada por lista - PROTEGIDO
get '/listas/cantidad_tareas_completadas/:id' do
  authenticate_jwt!
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




# Generar lista con tareas usando IA
post '/listas/generar_ia' do
  authenticate_jwt!
  content_type :json

  request_payload = JSON.parse(request.body.read)
  user_prompt = request_payload['prompt'] || ''
  usuario_id = request_payload['usuario_id']

  if user_prompt.empty? || usuario_id.nil?
    return [400, { error: 'Error al generar la lista' }.to_json]
  end

  json_schema = {
    type: 'object',
    properties: {
      lista: {
        type: 'object',
        properties: {
          nombre: { type: 'string' },
          descripcion: { type: 'string' },
          color: { type: 'string', description: 'Selecciona uno de estos: #4CAF50, #2196F3, #F44336, #FF9800, #9C27B0, #795548, #607D8B, #E91E63, #009688, #FFEB3B' },
          tareas: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                nombre: { type: 'string' },
                descripcion: { type: 'string' },
                fecha_creacion: { type: 'string', format: 'datetime', description: 'Debes agregar la fecha y la hora de inicio de la tarea. Formato yyyy-MM-dd hh:mm:00' },
                fecha_vencimiento: { type: 'string', format: 'datetime', description: 'Debes agregar la fecha y la hora de fin de la tarea. Formato yyyy-MM-dd hh:mm:00' },
                prioridad_id: { type: 'integer', description: 'Solo asigna el número, los valores son: 1: Baja - 2: Media - 3: Alta' },
              },
              required: ['nombre', 'descripcion', 'fecha_creacion', 'fecha_vencimiento', 'prioridad_id'],
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

  begin
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
      fix_parser = Langchain::OutputParsers::OutputFixingParser.from_llm(
        llm: llm,
        parser: parser
      )
      parsed_response = fix_parser.parse(response.chat_completion)
    end

    # Guardar en la base de datos
    lista_data = parsed_response["lista"]
    lista = Lista.create(
      usuario_id: usuario_id,
      nombre: lista_data["nombre"],
      descripcion: lista_data["descripcion"],
      color: lista_data["color"]
    )

    tareas = []
    if lista_data["tareas"].is_a?(Array)
      lista_data["tareas"].each do |tarea_data|
        tarea = Tarea.create(
          lista_id: lista.id,
          usuario_id: usuario_id,
          titulo: tarea_data["nombre"],
          descripcion: tarea_data["descripcion"],
          fecha_creacion: tarea_data["fecha_creacion"] || Date.today.to_s,
          fecha_vencimiento: tarea_data["fecha_vencimiento"] || Date.today.to_s,
          estado_id: 1, # Estado pendiente por defecto
          prioridad_id: tarea_data["prioridad_id"] || 1,
          categoria_id: 2 # Luego se modificará esto, por ahora se asigna una categoría por defecto
        )
        tareas << tarea
      end
    end

    resultado = {
      lista: lista,
      tareas: tareas
    }

    [200, resultado.to_json]
  rescue StandardError => e
    puts "Sharay: #{e.message}"
    [500, { error: 'Error al generar la lista con IA' }.to_json]
  end
end
