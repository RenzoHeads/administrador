import 'dart:convert';

class Usuario {
  int? id;
  final String nombre;
  final String contrasena;
  final String email;
  final String? token;
  final String? foto;

  Usuario({
    this.id,
    required this.nombre,
    required this.contrasena,
    required this.email,
    this.token,
    this.foto,
  });

  @override
  String toString() {
    return 'Usuario{id: $id, nombre: $nombre, email: $email, foto: $foto}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'contrasena': contrasena,
      'email': email,
      'imagen_perfil': foto,  // Mapeado correcto a campo del backend
      'reset_token': token,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      contrasena: map['contrasena'],
      email: map['email'],
      token: map['reset_token'],
      foto: map['imagen_perfil'],  // Campo 'imagen' del backend a 'foto' en Dart
    );
  }

  factory Usuario.fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return Usuario.fromMap(map);
  }
}