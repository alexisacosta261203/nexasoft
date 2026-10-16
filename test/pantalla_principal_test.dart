import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/ui/pantalla_principal.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const clave = 'nexasoft_incidencias_v1';

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
      clave: jsonEncode([
        _registro('INC-1', 'WiFi pendiente alta', 'Pendiente', 'Alta'),
        _registro('INC-2', 'WiFi pendiente media', 'Pendiente', 'Media'),
        _registro('INC-3', 'WiFi resuelta alta', 'Resuelta', 'Alta'),
        _registro('INC-4', 'Teclado pendiente alta', 'Pendiente', 'Alta'),
      ]),
    });
  });

  testWidgets('combina búsqueda y filtros y permite limpiarlos',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: PantallaPrincipal()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('search-field')), 'wifi');
    await tester.tap(find.byKey(const ValueKey('state-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pendiente').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('priority-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alta').last);
    await tester.pumpAndSettle();

    expect(find.text('WiFi pendiente alta'), findsOneWidget);
    expect(find.text('WiFi pendiente media'), findsNothing);
    expect(find.text('WiFi resuelta alta'), findsNothing);
    expect(find.text('Teclado pendiente alta'), findsNothing);
    expect(find.text('1 registros'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reset-filters')));
    await tester.pumpAndSettle();

    expect(find.text('WiFi pendiente alta'), findsOneWidget);
    expect(find.text('WiFi pendiente media'), findsOneWidget);
    expect(find.text('WiFi resuelta alta'), findsOneWidget);
    expect(find.text('Teclado pendiente alta'), findsOneWidget);
    expect(find.text('4 registros'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'sin coincidencias',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No se encontraron incidencias con estos criterios.'),
      findsOneWidget,
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
    'descripcion': 'Descripción de prueba',
    'cliente': 'Cliente de prueba',
    'categoria': 'Software',
    'estado': estado,
    'fecha': '2026-10-16',
    'prioridad': prioridad,
  };
}
