import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/incidencia.dart';

class AlmacenLocal {
  final prefs = SharedPreferencesAsync();
  final clave = 'nexasoft_incidencias_v1';

  Future<List<Incidencia>> leer() async {
    final guardadas = await prefs.getString(clave);
    final texto = guardadas ??
        await rootBundle.loadString('assets/data/incidencias.json');
    final decoded = jsonDecode(texto);
    final dynamic lista = switch (decoded) {
      List<dynamic> registros => registros,
      Map<String, dynamic> datosAnteriores => datosAnteriores['incidencias'],
      _ => null,
    };
    if (lista is! List<dynamic>) {
      throw const FormatException(
        'Los datos de incidencias deben ser una lista o incluir "incidencias".',
      );
    }

    return lista.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Cada registro de incidencia debe ser un objeto.',
        );
      }
      return Incidencia.desdeJson(item);
    }).toList();
  }

  Future<void> guardar(List<Incidencia> lista) async {
    final datos = lista.map((x) => x.toJson()).toList();
    await prefs.setString(clave, jsonEncode(datos));
  }

  Future<void> restaurarDatosDeEjemplo() async {
    await prefs.remove(clave);
  }
}
