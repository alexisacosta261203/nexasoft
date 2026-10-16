import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/data/almacen_local.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const clave = 'nexasoft_incidencias_v1';

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('lee registros anteriores con campos que ya no son obligatorios',
      () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
      clave: jsonEncode({
        'incidencias': [
          {
            'id': 'INC-ANT',
            'titulo': 'Registro previo',
            'descripcion': 'Descripción previa',
            'estado': 'En proceso',
          },
        ],
      }),
    });

    final registros = await AlmacenLocal().leer();

    expect(registros, hasLength(1));
    expect(registros.single.id, 'INC-ANT');
    expect(registros.single.estado, 'En proceso');
    expect(registros.single.cliente, isEmpty);
    expect(registros.single.categoria, 'Software');
    expect(registros.single.fecha, isEmpty);
    expect(registros.single.prioridad, 'Media');
  });

  test('guardar conserva registros para la siguiente lectura', () async {
    final incidencia = Incidencia(
      id: 'INC-GUARDADA',
      titulo: 'Persistencia',
      descripcion: 'Prueba de guardado',
      cliente: 'Cliente de prueba',
      categoria: 'Redes',
      estado: 'Pendiente',
      fecha: '2026-10-16',
    );

    await AlmacenLocal().guardar([incidencia]);
    final registros = await AlmacenLocal().leer();

    expect(registros.single.toJson(), incidencia.toJson());
  });

  test('crear persiste la incidencia y la recarga al iniciar de nuevo',
      () async {
    final gestor = GestorIncidencias();
    await gestor.iniciar();
    await gestor.crear(
      'Nueva incidencia',
      'Prueba de persistencia',
      'Cliente de prueba',
      'Software',
    );

    final gestorReiniciado = GestorIncidencias();
    await gestorReiniciado.iniciar();

    expect(gestorReiniciado.incidencias.first.titulo, 'Nueva incidencia');
    expect(gestorReiniciado.contar('Pendiente'), gestor.cantidadPendientes);
  });

  test('cambiar estado persiste el cambio para la siguiente sesión', () async {
    final gestor = GestorIncidencias();
    await gestor.iniciar();
    final incidencia =
        gestor.incidencias.firstWhere((item) => item.estado == 'Pendiente');

    await gestor.cambiarEstado(incidencia.id, 'Resuelta');

    final gestorReiniciado = GestorIncidencias();
    await gestorReiniciado.iniciar();

    expect(gestorReiniciado.porId(incidencia.id)?.estado, 'Resuelta');
    expect(gestorReiniciado.contar('Pendiente'), gestor.cantidadPendientes);
  });

  test('prioridad elegida al crear y cambiada se conserva al reiniciar',
      () async {
    final gestor = GestorIncidencias();
    await gestor.iniciar();
    await gestor.crear(
      'Incidencia de prioridad alta',
      'Prueba de prioridad',
      'Cliente de prueba',
      'Software',
      prioridad: 'Alta',
    );
    final idNueva = gestor.incidencias.first.id;
    expect(gestor.porId(idNueva)?.prioridad, 'Alta');

    await gestor.cambiarPrioridad(idNueva, 'Baja');

    final gestorReiniciado = GestorIncidencias();
    await gestorReiniciado.iniciar();
    expect(gestorReiniciado.porId(idNueva)?.prioridad, 'Baja');
  });

  test('combina texto, estado y prioridad y permite volver a todos',
      () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
      clave: jsonEncode([
        _registro('INC-1', 'WiFi intermitente', 'Pendiente', 'Alta'),
        _registro('INC-2', 'WiFi lento', 'Pendiente', 'Media'),
        _registro('INC-3', 'Correo y WiFi', 'Resuelta', 'Alta'),
        _registro('INC-4', 'Error de teclado', 'Pendiente', 'Alta'),
      ]),
    });
    final gestor = GestorIncidencias();
    await gestor.iniciar();

    final combinadas = gestor.filtrar(
      texto: 'wifi',
      estado: 'Pendiente',
      prioridad: 'Alta',
    );

    expect(combinadas.map((item) => item.id), ['INC-1']);
    expect(gestor.filtrar(), hasLength(4));
  });

  test('rechaza prioridades fuera de las opciones aprobadas', () {
    expect(
      () => Incidencia(
        id: 'INC-INVALIDA',
        titulo: 'Prueba',
        descripcion: '',
        cliente: '',
        categoria: 'Software',
        estado: 'Pendiente',
        fecha: '',
        prioridad: 'Urgente',
      ),
      throwsArgumentError,
    );
  });
}

Map<String, String> _registro(
  String id,
  String titulo,
  String estado,
  String prioridad,
) {
  return {
    'id': id,
    'titulo': titulo,
    'descripcion': 'Incidencia de prueba',
    'cliente': 'Cliente de prueba',
    'categoria': 'Software',
    'estado': estado,
    'fecha': '2026-10-16',
    'prioridad': prioridad,
  };
}
