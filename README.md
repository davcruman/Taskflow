TaskFlow 🚀
TaskFlow es una aplicación de gestión de tareas moderna y funcional desarrollada con Flutter. El objetivo del proyecto es ofrecer una herramienta organizada para el día a día, con soporte multiidioma, notificaciones locales y persistencia en la nube.

✨ Características Principales
Gestión de Tareas: Crea, edita y elimina tareas con facilidad.

Sincronización en Tiempo Real: Uso de Firebase Firestore para mantener tus tareas a salvo y sincronizadas.

Autenticación: Sistema de login y registro gestionado por Firebase Auth.

Calendario Integrado: Visualiza tus tareas de forma mensual mediante una interfaz de calendario intuitiva (Table Calendar).

Internacionalización (i18n): App disponible en 4 idiomas: 🇪🇸 Español, 🇺🇸 Inglés, 🇫🇷 Francés y 🇵🇹 Portugués.

Notificaciones Locales: Recordatorios configurables para que nunca olvides una tarea importante.

Personalización:

Soporte para Modo Claro y Modo Oscuro.

Ajustes de vibración y permisos de sistema.

Persistencia Local: Los ajustes de apariencia se guardan mediante SharedPreferences.

🛠️ Stack Tecnológico
Lenguaje: Dart

Framework: Flutter (Material 3)

Backend: Firebase (Auth, Firestore)

Estado: Provider

Librerías Clave:

easy_localization para el soporte multiidioma.

flutter_local_notifications para los avisos.

table_calendar para la vista de calendario.

intl para el formato de fechas.

📁 Estructura del Proyecto
Plaintext
lib/
├── models/         # Modelos de datos (Task, User, etc.)
├── repositories/   # Lógica de conexión con Firebase
├── services/       # Servicio de notificaciones
├── ui/
│   ├── providers/  # Gestión de estado (UIProvider)
│   └── screens/    # Pantallas (Home, Calendar, Settings, AddTask, Login)
└── assets/
    └── translations/ # Archivos JSON de idiomas (es, en, fr, pt)
🚀 Instalación y Configuración
Clonar el repositorio:

Bash
git clone https://github.com/tu-usuario/taskflow.git
Instalar dependencias:

Bash
flutter pub get
Configurar Firebase:

Debes añadir tu propio archivo google-services.json (Android) o GoogleService-Info.plist (iOS) en las carpetas correspondientes.

Ejecutar la aplicación:

Bash
flutter run

📝 Licencia
Este proyecto es de uso educativo. Desarrollado como parte del módulo de Programació multimèdia i dispositius mòbils.