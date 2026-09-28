# Catbreeds

Prueba técnica Flutter para explorar razas de gatos usando
[The Cat API](https://api.thecatapi.com/v1/breeds). Construí un catálogo con
búsqueda por nombre en inglés, paginación, detalle, reintentos y manejo de
estados. La interfaz y accesibilidad están en español; los datos de la API se
conservan tal como llegan.

Inicié desde **Very Good CLI / Very Good Ventures**. Conservé la estructura
inicial, `very_good_analysis`, internacionalización y convenciones de test; el
contador de ejemplo y la documentación genérica de plantilla ya no aportaban al
producto, por eso los retiré.

## Arquitectura que tomé

Organicé el código por funcionalidad y separé `domain` (Dart puro), `data`
(adaptadores HTTP) y `presentation` (BLoC y UI). El dominio no conoce Flutter,
BLoC, Dio ni GetIt. Elegí una Clean Architecture simplificada: solo agregué el
caso de uso de búsqueda porque valida una regla real antes de consultar la API.

Usé BLoC para coordinar búsqueda, paginación, reintentos y detalle. No mezclé
ese flujo con `FutureBuilder` o `StreamBuilder`, porque habría creado dos
fuentes de estado. Los barrels exponen contratos entre capas; dentro de cada
capa prefiero imports concretos y visibles.

## Ejecutar la app

La app tiene tres flavors:

| Flavor | Uso | Android application ID |
| --- | --- | --- |
| `development` | Desarrollo local | `com.pruebapragma.verygoodcore.cat_breeds.dev` |
| `staging` | QA e integración | `com.pruebapragma.verygoodcore.cat_breeds.stg` |
| `production` | Distribución | `com.pruebapragma.verygoodcore.cat_breeds` |

La clave se pasa localmente mediante `--dart-define-from-file`; no se guarda en
Git. Crea `.secrets/cat_api.json` con este formato:

```json
{
  "CAT_API_KEY": "tu_clave"
}
```

Ejecuta el flavor que necesites:

```sh
flutter run --flavor development --target lib/main_development.dart --dart-define-from-file=.secrets/cat_api.json
flutter run --flavor staging --target lib/main_staging.dart --dart-define-from-file=.secrets/cat_api.json
flutter run --flavor production --target lib/main_production.dart --dart-define-from-file=.secrets/cat_api.json
```

`--dart-define` evita publicar la clave en el repositorio, pero no convierte una
clave dentro de un binario móvil en un secreto absoluto. En un producto real la
restringiría en el proveedor o usaría un backend intermediario.

La configuración de flavors existe para Android e iOS.

---

## Calidad

Dejé pruebas para dominio, datos, BLoC, DI, UI, responsive, límites de Atomic
Design y adaptación Android/iOS. GitHub Actions ejecuta formato, análisis,
pruebas, cobertura y builds APK de depuración de los tres flavors.

```sh
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/check_coverage.dart
```

El chequeo de cobertura exige como mínimo 90% de líneas globales y en las capas
de dominio, datos y BLoC de `breeds`. Las pruebas usan fakes y no requieren
clave ni conexión a The Cat API.

---

<!-- Notas heredadas de la plantilla original. La presentación del proyecto continúa abajo.

## Bloc Lints 🔍

This project uses the [bloc_lint](https://pub.dev/packages/bloc_lint) package to enforce best practices using [bloc](https://pub.dev/packages/bloc).

To validate linter errors, run

```bash
dart run bloc_tools:bloc lint .
```

You can also validate with VSCode-based IDEs using the [official bloc extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc).

To learn more, visit https://bloclibrary.dev/lint/

---

## Working with Translations 🌐

This project follows the [official internationalization guide for Flutter][internationalization_link] using [ARB files][arb_documentation_link] for translations.

### Adding Strings

1. To add a new localizable string, open the `app_en.arb` file at `lib/l10n/arb/app_en.arb` and add a new key/value pair with the relevant description (optional):

```arb
{
    "@@locale": "en",
    "breedsTitle": "Cat breeds",
    "@breedsTitle": {
        "description": "Title of the cat breeds page"
    },
    "breedsComingSoon": "The breed catalog is coming soon.",
    "@breedsComingSoon": {
        "description": "Placeholder shown until the catalog is implemented"
    }
}
```

1. Use the new string:

```dart
import 'package:cat_breeds/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.breedsTitle);
}
```

### Adding Supported Locales

Update the `CFBundleLocalizations` array in the `Info.plist` at `ios/Runner/Info.plist` to include the new locale.

```xml
    ...

    <key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
	</array>

    ...
```

### Adding Translations

1. For each supported locale, add a new ARB file in `lib/l10n/arb`:

```
├── l10n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

1. Add the translated strings to the new `.arb` file:

`app_es.arb`

```arb
{
    "@@locale": "es",
    "breedsTitle": "Razas de gatos",
    "@breedsTitle": {
        "description": "Título de la página de razas de gatos"
    },
    "breedsComingSoon": "El catálogo de razas estará disponible pronto.",
    "@breedsComingSoon": {
        "description": "Texto temporal hasta implementar el catálogo"
    }    
}
```

### Generating Translations

To use the latest translations changes, you will need to generate them:

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Alternatively, run `flutter run` and code generation will take place automatically.

[internationalization_link]: https://docs.flutter.dev/ui/internationalization
[arb_documentation_link]: https://github.com/google/app-resource-bundle
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
-->

## Resumen de las tareas

| Tarea | Lo que hice |
| --- | --- |
| 1. Contrato y alcance | Definí API, assets locales y los criterios de la aplicación. |
| 2. Dominio puro | Modelé entidades, fallos, resultado y puerto de repositorio en Dart puro. |
| 3. Datos | Añadí DTOs, Dio, mapeo de errores y el adaptador del repositorio. |
| 4. Composición | Registré dependencias con GetIt solo en el *composition root*. |
| 5. Design system | Creé tokens y componentes visuales compartidos. |
| 6. Atomic Design | Organicé átomos, moléculas, organismos y templates; además probé sus límites. |
| 7. Estado y rutas | Implementé BLoC y rutas de catálogo/detalle con GoRouter. |
| 8. Adaptación visual | Ajusté breakpoints, texto ampliado y controles Material/Cupertino. |
| 9. Calidad | Añadí pruebas unitarias y de widgets, LCOV y validaciones de CI. |
| 10. Concurrencia | Optimicé imágenes y transformación de respuestas sin crear isolates innecesarios. |

## Diseño y plataforma

La identidad visual —tarjetas, fotos, colores, espaciado y tipografía— es
propia de Catbreeds. Para los controles interactivos centralicé la adaptación:

| Necesidad | Android | iOS |
| --- | --- | --- |
| Pantalla y navegación | `Scaffold` / `AppBar` | `CupertinoPageScaffold` / `CupertinoNavigationBar` |
| Búsqueda | `TextField` | `CupertinoTextField` |
| Botones | Material | `CupertinoButton` |
| Carga | `CircularProgressIndicator` | `CupertinoActivityIndicator` |

De esa forma las páginas usan componentes adaptativos y no contienen un `if`
para decidir Android frente a iOS.

## Qué haría con más tiempo

- Validaría y firmaría los tres schemes de iOS en macOS con Xcode y un equipo
  Apple Developer.
- Añadiría pruebas de integración en dispositivo y *golden tests* para detectar
  regresiones visuales.
- Incorporaría caché persistente y una estrategia *offline-first*.
- Movería el acceso a la API a un backend si la clave tuviera privilegios o
  coste relevante.
- Añadiría telemetría y reporte de errores por flavor antes de publicar.

Estas decisiones quedaron fuera porque el alcance era un catálogo técnico, no
un lanzamiento a producción. Preferí entregar límites claros, pruebas y una
experiencia completa antes que simular infraestructura que la prueba no usa.

## Comandos útiles

```powershell
flutter pub get
flutter analyze
flutter test
dart run bloc_tools:bloc lint .
```
