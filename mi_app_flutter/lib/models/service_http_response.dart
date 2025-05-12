class ServiceHttpResponse {
  int? status;
  dynamic body;

  ServiceHttpResponse({this.status, this.body});

  // Método para crear una instancia de ServiceHttpResponse desde un mapa
  factory ServiceHttpResponse.fromMap(Map<String, dynamic> map) {
    return ServiceHttpResponse(
      status: map['status'],
      body:
          map['body'], // Puedes agregar lógica para convertir el body según su tipo
    );
  }

  // Método para convertir una instancia de ServiceHttpResponse a un mapa
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'body': body, // Considera convertir el cuerpo a JSON si es necesario
    };
  }

  @override
  String toString() {
    return 'ServiceHttpResponse{status: $status, body: $body}';
  }
}
