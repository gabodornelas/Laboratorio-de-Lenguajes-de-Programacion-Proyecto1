# Tarea 1: Motor de Aventura de Texto (CI-3661)

**Integrantes:**  
- Gabriel De Ornelas — *15-10377*  
- Blanyer Vielma — *16-11238*  

---

## Cómo Compilar y Ejecutar

Este proyecto usa **Stack** como sistema de construcción para proyectos en Haskell.  

1. **Compilar el proyecto:**  
   ```bash
   stack build
   ```

2. **Ejecutar el programa:**  
   ```bash
   stack exec TextAdventureEngine-exe
   ```

---

## Justificación de Diseño

### Estructura del Proyecto

```
Laboratorio-de-Lenguajes-de-Programacion-Proyecto1
├── app
│   └── Main.hs               # Punto de entrada del programa
├── src
│   └── Engine
│       ├── Core.hs           # Lógica pura del juego
│       ├── Parser.hs         # Análisis y validación de comandos del usuario
│       ├── Persistence.hs    # Manejo carga del estado del juego
│       └── Types.hs          # Definiciones de tipos de datos principales
└── README.md                 # Documentación del proyecto
```
---

### 1. Elección de Estructuras de Datos

Se utilizan varias estructuras de datos para representar el estado del juego de manera eficiente y clara. De las cuales destaca el uso de Map de la librería `Data.Map`. Esta estructura es util por permitir asociar un par clave-valor, lo cual es ideal para representar el mundo mas facilmente como un grafo dirigido y permitir acceso rapido a los elementos por su clave.  

- Las **salas** se representan como nodos en un grafo, donde cada sala tiene un mapa de conexiones a otras salas (nodos adyacentes) y un mapa de objetos presentes en la sala.  
- Los **objetos** dentro de cada sala se almacenan en una lista, sin embargo se acceden a ellas mediante el uso de la funcion find en conjunto con el nombre del objeto para facilitar su busqueda.
- El **inventario** del jugador también se representa como una lista de objetos que el jugador ha recogido.
---

### 2. Separación de Lógica Pura e Impura

#### `Engine.Core`
Contiene la **lógica pura** encargada de recibir el estado del juego y un comando, y devolver un nuevo estado (sin modificar el original) del juego junto con mensajes para el jugador. Esto incluye funciones para:
- Mover al jugador entre salas.
- Manipular el inventario.
- Actualizar el estado del juego según las acciones del jugador.

#### `Engine.Persistence`
Contiene funciones para manejar la **persistencia del estado del juego**, permitiendo cargar un estado inicial desde un archivo para el modelado del mundo.
 
#### `Main`
Gestiona toda la **interacción con el usuario** (logica impura) para recibir comandos y mostrar resultados en la consola. Utiliza las distintas funciones de los modulos del Engine para cargar archivos, parsear comandos, y actualizar el estado del juego:
- Cargar el estado inicial del juego desde un archivo.
- Leer la entrada del usuario.
- Mostrar mensajes y el estado actual del juego.
---
