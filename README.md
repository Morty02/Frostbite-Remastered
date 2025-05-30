## Autor: Carlos Pereira 30211766

## Características

- Mecánicas de juego clásicas con gráficos y sonido actualizados.
- Niveles desafiantes llenos de retos y enemigos.
- Controles suaves para saltar y moverse entre los témpanos de hielo.

## Comenzando

### Requisitos previos

- Love2D (versión 11.3 o superior) instalado.

### Ejecutar el juego

1. Clona el repositorio:
   ```
   git clone https://github.com/yourusername/frostbite-remastered.git
   ```
2. Navega al directorio del proyecto:
   ```
   cd frostbite-remastered
   ```
3. Ejecuta el juego usando Love2D. Puedes hacerlo de varias formas en Windows:

   - **Desde la línea de comandos**:
     ```
     "C:\Program Files\LOVE\love.exe" "C:\Users\Tu_usuario\Documents\GitHub\Frostbite"
     ```
   - **Arrastrando la carpeta**: Arrastra la carpeta del proyecto (la que contiene `main.lua`) sobre el archivo `love.exe` o un acceso directo a `love.exe`.
   - **Desde editores compatibles**: ZeroBrane Studio, Sublime Text, Notepad++ y SciTE permiten iniciar el juego directamente desde el editor.

## Estructura del proyecto

```
frostbite-remastered
├── src
│   ├── main.lua          # Punto de entrada del juego
│   ├── conf.lua          # Configuración
│   ├── game              # Lógica y clases del juego
│   │   ├── player.lua    # Clase del jugador
│   │   ├── iceberg.lua   # Clase de témpano de hielo
│   │   ├── fish.lua      # Clase de pez
│   │   ├── enemy.lua     # Clase de enemigo
│   │   └── level.lua     # Gestión de niveles
│   └── assets            # Recursos del juego
│       ├── sounds        # Archivos de sonido
│       └── fonts         # Archivos de fuentes
└── README.md             # Documentación del proyecto
```

## Contribuciones

¡Las contribuciones son bienvenidas! No dudes en enviar un pull request o abrir un issue para cualquier sugerencia o mejora.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
