# gestorgalpon_app

El frontend se desarrollo con Flutter ( lenguaje de programacion Dart)

## Primeros pasos:

## Pre-requisitos

- Tener Flutter SDK instalado
- Tener VSCode instalado
- Tener la extensión "Flutter" y "Dart" instalada en VS Code
  
## Descargar flutter

1. Ir a la pagina oficial de flutter https://flutter.dev/
2. Navegar con el boton Get started
3. Descarga el SDK para Windows
4. Extrae el archivo ZIP en una ubicación permanente (ej: C:\flutter)

## Configuraciones iniciales

1. Configuracion variables de entorno:
  - Busca "Variables de entorno" en el menú inicio
  - Haz clic en "Variables de entorno..."
  - En "Variables del sistema", busca Path y haz clic en "Editar"
  - Haz clic en "Nuevo" y agrega la ruta: C:\flutter\bin
  - Haz clic en "Aceptar" para guardar
    
## Para verificar si flutter se instalo se pone en consola o terminal vscode flutter --version

## Configuraciones finales

1. Abre el vscode
2. En terminal ( si se agregó el flutter en el PATH del sistema) 
3. se pone flutter doctor 

## Para descargas las dependencias por si acaso dentro en el proyecto se pone :
- Flutter pub upgrade
  Esto descargara las dependencias que vienen en el .yaml
