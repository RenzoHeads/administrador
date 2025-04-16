require_relative 'database'

# Usuario
class Usuario < Sequel::Model(DB[:usuarios])
  one_to_many :listas
  one_to_many :tareas
end

# Lista
class Lista < Sequel::Model(DB[:listas])
  many_to_one :usuario
  one_to_many :tareas
end

# Categoria
class Categoria < Sequel::Model(DB[:categorias])
  one_to_many :tareas
end

# Tarea
class Tarea < Sequel::Model(DB[:tareas])
  many_to_one :usuario
  many_to_one :lista
  many_to_one :categoria

  one_to_many :recordatorios
  one_to_many :comentarios
  one_to_many :adjuntos

  many_to_many :etiquetas, join_table: :tarea_etiquetas
end

# Etiqueta
class Etiqueta < Sequel::Model(DB[:etiquetas])
  many_to_many :tareas, join_table: :tarea_etiquetas
end

# TareaEtiqueta (tabla intermedia)
class TareaEtiqueta < Sequel::Model(DB[:tarea_etiquetas])
end

# Recordatorio
class Recordatorio < Sequel::Model(DB[:recordatorios])
  many_to_one :tarea
end

# Comentario
class Comentario < Sequel::Model(DB[:comentarios])
  many_to_one :tarea
end

# Adjunto
class Adjunto < Sequel::Model(DB[:adjuntos])
  many_to_one :tarea
end
