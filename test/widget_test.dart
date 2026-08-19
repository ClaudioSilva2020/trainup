import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trainup/features/splash/presentation/splash_screen.dart';

// Cobertura mínima enquanto não existe injeção de dependência.
//
// `TrainUpApp` não é testável hoje: constrói o router, que lê
// `Supabase.instance.client` direto (app_router.dart), então exige um SDK
// inicializado. Testar a árvore inteira volta a ser possível na F1b, depois que
// os gateways permitirem `overrideWithValue` de fakes.
void main() {
  testWidgets('splash apresenta a marca e os dois caminhos de entrada',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('TrainUp'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
    expect(find.text('Já tenho uma conta'), findsOneWidget);
  });
}
