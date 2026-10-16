class Incidencia {
  static const prioridades = ['Baja', 'Media', 'Alta'];

  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String _prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    String prioridad = 'Media',
  }) : _prioridad = validarPrioridad(prioridad);

  String get prioridad => _prioridad;

  set prioridad(String value) {
    _prioridad = validarPrioridad(value);
  }

  static String validarPrioridad(String value) {
    if (!prioridades.contains(value)) {
      throw ArgumentError.value(value, 'prioridad', 'Prioridad no permitida');
    }
    return value;
  }

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    final prioridad = m['prioridad']?.toString();
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      prioridad:
          prioridades.contains(prioridad) ? prioridad! : 'Media',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad,
    };
  }
}
