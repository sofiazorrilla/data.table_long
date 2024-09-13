# data.table
Repositorio de taller de introducción al paquete data.table 

## Requisitos
1. Principalmente necesitarás instalar el paquete data.table. Sin embargo, hay algunos paquetes adicionales que debes revisar que tengas:
   ```
    # Lista de paquetes que queremos asegurarnos que estén instalados
    packages <- c("data.table", "magrittr", "dplyr", "ggplot2")
    
    # Función para instalar paquetes si no están ya instalados
    install_if_missing <- function(package) {
      if (!require(package, character.only = TRUE)) {
        install.packages(package)
        library(package, character.only = TRUE)
      }
    }
    
    # Revisa cada paquete y lo instala si es necesario
    sapply(packages, install_if_missing)
   ```
Datos para la primera sesión: [Top Spotify Songs in 73 Countries](https://www.kaggle.com/datasets/asaniczka/top-spotify-songs-in-73-countries-daily-updated/data)

## Primera sesión 

1. Introducción

    - Función: Otra propuesta para manipular tablas
    - Diferencias con dplyr
    - Mencionar que hay integraciones entre ambos
    - Sintaxis
    - Cheatsheet 

2. Importar y exportar datos
    - Crear objetos data.table
    - Importar y exportar datos de archivos
    - Comparaciones de velocidad entre read.csv y fread
    - Compatibilidad de data.table y data.frame

3. Filtros y selección de columnas
    - Seleccionar por índices
    - Filtrar filas
    - Ordenar filas
    - Seleccionar columnas
    - Renombrar columnas

4. Modificación de columnas
    - Operaciones de resumen
    - Creación de nuevas columnas
    - Operadores especiales (.N)

5. Agrupación
    - Agrupación por clave
    
6. Concatenación de comandos
    - ¿Qué es y para qué sirve?
    - Ejemplos

## Segunda Sesión 


7. Unión de tablas
    - Sintaxis data.table
    - Función merge 
    - Ejemplos





## Recursos 

1. [Lista: Statistics Globe](https://www.youtube.com/playlist?list=PLu6UwBFCnlEcb47DE-yWPjoEeZp10PDJz) de videos cortos sobre funcionalidades del paquete

2. [Integración de data.table con dplyr](https://www.youtube.com/watch?v=r0ricexnF6A&ab_channel=BusinessScience)

3. [Plática de data.table Rladies STL](https://www.youtube.com/watch?v=8wAv5nCRiUo&ab_channel=RLadiesSTL)

4. [data.table cheatsheet (Data Camp)](https://images.datacamp.com/image/upload/v1653830846/Marketing/Blog/data_table_cheat_sheet.pdf)

5. [Repositorio de data.table](https://github.com/Rdatatable/data.table)

6. [Wiki data.table](https://rdatatable.gitlab.io/data.table/) 

7. [Introducción a data.table](https://bookdown.org/paradinas_iosu/CursoR/data-table.html)

- https://jangorecki.github.io/blog/2015-12-11/Solve-common-R-problems-efficiently-with-data.table.html

- https://brooksandrew.github.io/simpleblog/articles/advanced-data-table/

