import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  static const estados = ['Pendiente', 'En proceso', 'Resuelta'];
  static const prioridades = Incidencia.prioridades;

  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  List<Incidencia> buscar(String texto) {
    return filtrar(texto: texto);
  }

  List<Incidencia> filtrar({
    String texto = '',
    String estado = 'Todos',
    String prioridad = 'Todas',
  }) {
    if (estado != 'Todos' && !estados.contains(estado)) {
      throw ArgumentError.value(estado, 'estado', 'Estado no permitido');
    }
    if (prioridad != 'Todas' && !prioridades.contains(prioridad)) {
      throw ArgumentError.value(
        prioridad,
        'prioridad',
        'Prioridad no permitida',
      );
    }

    final consulta = texto.trim().toLowerCase();
    return incidencias
        .where((x) {
          final coincideTexto = consulta.isEmpty ||
              x.titulo.toLowerCase().contains(consulta) ||
              x.descripcion.toLowerCase().contains(consulta);
          final coincideEstado = estado == 'Todos' || x.estado == estado;
          final coincidePrioridad =
              prioridad == 'Todas' || x.prioridad == prioridad;
          return coincideTexto && coincideEstado && coincidePrioridad;
        })
        .toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    if (estado == 'Pendiente') return cantidadPendientes;
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    if (!estados.contains(estado)) {
      throw ArgumentError.value(estado, 'estado', 'Estado no permitido');
    }
    final incidencia = porId(id);
    if (incidencia == null) {
      throw StateError('No se encontró la incidencia $id');
    }

    final estadoAnterior = incidencia.estado;
    if (estadoAnterior == estado) return;

    incidencia.estado = estado;
    try {
      await datos.guardar(incidencias);
    } catch (_) {
      incidencia.estado = estadoAnterior;
      rethrow;
    }
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  Future<void> cambiarPrioridad(String id, String prioridad) async {
    Incidencia.validarPrioridad(prioridad);
    final incidencia = porId(id);
    if (incidencia == null) {
      throw StateError('No se encontró la incidencia $id');
    }

    final prioridadAnterior = incidencia.prioridad;
    if (prioridadAnterior == prioridad) return;

    incidencia.prioridad = prioridad;
    try {
      await datos.guardar(incidencias);
    } catch (_) {
      incidencia.prioridad = prioridadAnterior;
      rethrow;
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria, {String prioridad = 'Media'}) async {
    Incidencia.validarPrioridad(prioridad);
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: prioridad,
    );
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    try {
      await datos.guardar(incidencias);
    } catch (_) {
      incidencias.remove(nuevo);
      cantidadPendientes--;
      rethrow;
    }
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
