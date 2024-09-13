################################################################
## Script de ejemplos y ejercicios: introducción a data.table ##
################################################################

#setwd()


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


###############################
## Importar y exportar datos ##
###############################

# Creación de objeto data.table sencillo 

library(data.table)
library(dplyr)
library(ggplot2)

DT = data.table(
  ID = c("b","b","b","a","a","c"),
  a = 1:6,
  b = 7:12,
  c = 13:18
)

DT

# Para comparar como se ve un df vs DT
# as.data.frame(DT)

#####################
## Importar datos ###
#####################

# Asegurar que los datos existen

## Si no haz creado la carpeta de data en tu directorio de trabajo
# # Revisa si existe, si no crea la carpeta
# if (!file.exists("data")) {
#   dir.create("data")
# }

# # Descarga el archivo de datos en la carpeta de data
# download.file(url = "https://github.com/sofiazorrilla/data.table_long/raw/main/data/universal_top_spotify_songs.csv.gz", destfile = "data/universal_top_spotify_songs.csv.gz")

# Leer archivo

data  <- fread("data/universal_top_spotify_songs.csv.gz")

head(data)

# Escribir archivo

# ¿qué le falta al comando para que escriba el archivo comprimido?
fwrite(DT, "data/testDT.csv", sep = ",")

##################################################
## Operaciones sobre las filas: filtros y orden ##
##################################################

# Filtros por índices

data[1:2,] 

data[1:2] 

# Filtros por condicion

data_MX <- data[country == "MX",] 

dim(data_MX)

data_MX_viejos <- data[country == "MX" & album_release_date <= 2000,]

dim(data_MX_viejos)

# ¿Qué canciones viejas son populares en México?

# Ordenar filas por bailabilidad
ordered_data_MX = data_MX[order(danceability, decreasing = T)]

data_MX[order(-danceability)]

# seleccionar la columna de bailabilidad como vector y seleccionar los valores únicos
# mostrar solo los primeros valores

unique(ordered_data_MX$danceability) |> head()

## Ejercicio: 

# 1. Carga el archivo de canciones utilizando la función fread que revisamos en el tema anterior
# 2. Utiliza un filtro para quedarte con las filas que pertenezcan al pais que te interese
# 3. Ordena de manera descendente por ranking

# Pregunta:

# ¿De qué rango de años son las 50 canciones más escuchadas?



##################################################
## Operaciones sobre las columnas: seleccion #####
##################################################

# Seleccionar por indice

data[,c(2,3,7),]

# Seleccionar por nombre

data[,name] 

# Seleccionar múltiples columnas

data[,list(artists,name,album_name)]

data[,.(artists,name,album_name)]

data[,spotify_id:weekly_movement]

# Seleccionar multiples columnas guardadas en una variable

variables <- c("artists","name","album_name")

data[ , ..variables]

## Ejercicio:

## A) Me gustaría tener un data frame en donde solo tuviera la información de las características de las canciones (por ejemplo: duración, energía, etc.)
# 
# 1. Enlista los nombres de columnas y analiza de qué tratan
# 2. Guarda los nombres de las columnas que solo contengan información acerca las características en un objeto
# 3. Selecciona las columnas de la tabla data usando el objeto de nombres de columnas.

## B) Genera un objeto data.table que tenga los registros del mes de septiembre 2024 y las columnas que describen las características de las cancions (utiliza un solo comando).



# Deseleccionar columnas

data[,-c("name","artists")] %>% colnames()

data[,!c("spotify_id")] %>% colnames()

data[,!(key:time_signature)] %>% colnames()

# Renombrar columnas

data[, .(artista = artists, song_name = name)]


##################################################
## Operaciones sobre las columnas: Modificacion ##
##################################################

### Contar el número de coincidencias 
data[country == "MX" & acousticness > 0.5, length(spotify_id)]

data[country == "MX" & acousticness > 0.5, .N]

### Ejercicio

#Pregunta:
#¿Cuántas canciones que se hayan publicado de antes del 2000 han estado dentro del top 50? (Utiliza .N)

## Cambiar la duracion de de ms a minutos y obtener el promedio

data[, duration_ms/1000/60] %>% mean()

data[,mean(duration_ms/1000/60)]

#### Hacer filtros y posteriormente efectuar operaciones

data[country == "MX", mean(popularity)]

## Ejercicio

#Calcula el promedio y desviación estandar en los movimientos diarios de ranking (el cambio en las clasificaciones en comparación con el día anterior) en las canciones populares de México.

### Agregar nuevas columnas a flights
data[, .(duration_min = duration_ms/1000/60)]

#### Modificar la tabla que está guardada en memoria con el operador := 
data[, date_dif := snapshot_date - album_release_date]

data

### Agregar múltiples columnas a la tabla de referencia

## Ejercicio

## 1) Agrega una nueva columna (year_release) a la tabla original que solo muestre el año de publicación del album de la canción

# 2) En un solo comando: genera una columna de diferencia entre la fecha de publicación y la fecha en la que la canción apareció en el top50. Además generar una columna de duración de la canción en minutos

##################################################
## Operaciones sobre las columnas: Agrupacion ####
##################################################

### Contar el numero de registro agrupando por cancion
data[,.N,by = name]

### Multiples factores por los cuales agrupar
times_song_per_album_per_country <- data[,.N,by = .(album_name,name,country)] 


### Ejercicio

# Genera una tabla en la que calcules el número de paises en el que un album estuvo en el top 50
# Haz una gráfica para visualizar los resultados


### Agrupar por expresion
data[,.N,by = .(country,PopAbove80 = popularity > 80)] %>% head()

### Ejercicio

# Calcula cuántas veces una canción ha sido ranqueada como la número 1 (para cualquier pais). Muestra las 5 canciones que hayan tenido el ranking 1 más veces.

#########################################
### Cadenas de operaciones ##############
#########################################

# ¿cómo contarías el número de paises en los que una canción ha estado en el top 50?
data[,.N, by = .(name,country)][,.(ncountry = .N), by = name]

# Ejemplo de cadenas con data.frame
as.data.frame(data)[1:10,][1:2,]


##################################################
## Ejercicios           ##########################
##################################################

## Ejercicio 1
# Eres un analista de datos en una plataforma de streaming musical. Tu jefe te ha pedido que analices las tendencias de 73 paises para contestar las siguietes preguntas:

# ¿Cuáles son los 5 álbumes más populares y cómo ha evolucionado su popularidad promedio (medida a través del ranking de las canciones de cada album) a lo largo del tiempo (mensualmente) en nuestra plataforma de streaming? (muestralo en un gráfico)



# Ejercicio 2

# ¿Cuáles son los 5 artistas que han mantenido una popularidad más constante a nivel internacional a lo largo del tiempo? En este caso vamos a considerar la popularidad como el número de paises en el que un artista es escuchado en el top50.

# En particular debes:
  
#   Calcular el número de países en los que la música de cada artista es popular para cada mes.

# Identificar a los 5 mejores artistas que aparecen de manera consistente en la mayor cantidad de países durante el período de tiempo dado.

# Visualizar las tendencias de popularidad mensual de estos 5 mejores artistas, destacando el primer mes en que aparecieron en el conjunto de datos.




### Ejercicio 3

# Se busca encontrar patrones entre las características de las canciones populares de cada pais. Por ejemplo: ¿existen diferencias entre el tipo de canciones (felices o tristes) que escuchan paises de diferentes continentes?

# Nota: El archivo country.codes.csv tiene la relación entre los códigos de los paises, los nombres de los paises y el continente al que pertenecen. Puedes utilizar funciones del paquete dplyr (left_join()) para unir las tablas.



### Ejercicio 4. 
# Utilizando las características de las canciones hipotetiza acerca del tipo de relaciones y las diferencias entre las canciones de diferentes regiones del mundo.

