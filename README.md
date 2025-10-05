# ⛽ Gasolina — App Flutter

> Sistema móvil para consultar el calendario de gasolina en Venezuela, con acceso rápido a la tasa oficial USD/BS y atajos inteligentes. ¡Todo en la palma de tu mano!

---

## 🏗️ Estructura del Proyecto

### 📁 Organización de Carpetas

```
gasolina/
├── lib/
│   ├── main.dart              # Punto de entrada de la app
│   ├── theme.dart             # Temas y colores
│   ├── data/
│   │   ├── bcv_service.dart   # Servicio para tasa BCV
│   │   └── schedules.dart     # Lógica de calendario de placas
│   └── widgets/               # Widgets personalizados (vacío)
├── assets/
│   └── icon/
│       └── app_icon.png       # Ícono de la app
├── test/
│   └── widget_test.dart       # Pruebas básicas
├── android/                   # Proyecto Android
├── ios/                       # Proyecto iOS
├── web/                       # Web (Flutter web)
├── linux/                     # Desktop Linux
├── macos/                     # Desktop Mac
├── windows/                   # Desktop Windows
├── pubspec.yaml               # Configuración y dependencias
└── README.md                  # Este archivo
```

---

## 🚀 Tecnologías Utilizadas

- **Flutter 3.9+** — Framework multiplataforma
- **Dart** — Lenguaje principal
- **Material Design 3** — UI moderna
- **shared_preferences** — Almacenamiento local
- **quick_actions** — Atajos desde el launcher
- **http** — Consultas a APIs
- **intl** — Formateo de fechas y números

---

## 🎯 Características

- Consulta visual del calendario de gasolina por terminal de placa
- Tasa oficial USD/BS en tiempo real (BCV)
- Atajo "Ir a Hoy" desde el ícono de la app
- Tema claro/oscuro automático
- Persistencia de preferencias del usuario
- UI responsiva y moderna

---

## 🔧 Instalación y Ejecución

```bash
git clone https://github.com/tu_usuario/gasolina.git
cd gasolina
flutter pub get
flutter run
```

---

## 📋 Buenas Prácticas y Organización

- Código modular y reutilizable
- Separación clara entre lógica, UI y servicios
- Uso de constantes y temas centralizados
- Pruebas básicas incluidas
- Estructura lista para escalar

---

## 🛣️ Próximas Mejoras

- [ ] Notificaciones push
- [ ] Widgets de calendario avanzados
- [ ] Mejoras de accesibilidad
- [ ] Soporte offline
- [ ] Más personalización visual

---

## 👤 Autor

Desarrollado y mantenido por WildOusx.

¿Tienes sugerencias o encontraste un error? ¡Abre un issue o pull request!
