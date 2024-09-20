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
as.data.frame(DT)

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
fwrite(DT, "data/testDT.csv.gz", sep = ",", compress = "auto")

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

data_GB <- data[country == "GB",]
ordered_data_GB = data_GB[order(daily_rank, decreasing = F)]
unique(ordered_data_GB$name) |> head(n = 50)



min(ordered_data_GB$album_release_date, na.rm = T)
max(ordered_data_GB$album_release_date, na.rm = T)

##################################################
## Operaciones sobre las columnas: seleccion #####
##################################################

# Seleccionar por indice

data[,c(2,3,7),]

# Seleccionar por nombre

data[,name] %>% class

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


data[,list(duration_ms,danceability,energy)]

variables <- c("duration_ms","danceability","energy")

data[,..variables]

head(variables)

sept_caracter <-  data[format(snapshot_date, "%Y-%m") == "2024-09",..variables]


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

data[format(album_release_date, "%Y") < "2000" & daily_rank< 50, .N]

## Cambiar la duracion de de ms a minutos y obtener el promedio

data[, duration_ms/1000/60]  %>% mean()

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

data[, year := as.numeric(format(album_release_date, "%Y"))]

# 2) En un solo comando: genera una columna de diferencia entre la fecha de publicación y la fecha en la que la canción apareció en el top50. Además generar una columna de duración de la canción en minutos

# dt[, c("col1","col2","col3") := list(val1,val2,val3)]

data[, c("diff_until_top50","duracion_minutos") := .(snapshot_date - album_release_date, duration_ms/1000/60)]

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


#########################################
### Unión de tablas        ##############
#########################################


dt1 = data.table(id = seq(1,10), letter1 = LETTERS[sample(1:10, replace = T)])

dt2 = data.table(id = seq(6,15), letter2 = LETTERS[sample(1:10, replace = T)])


# Inner join
merge(dt1,dt2,by = "id")

# left join
merge(dt1,dt2,by = "id", all.x = T)

# right join
merge(dt1,dt2,by = "id", all.y = T)

# full join
merge(dt1,dt2,by = "id", all = T)

## Sintaxis DT

# inner join
dt1[dt2, on = "id", nomatch=0]

# left join
dt1[dt2, on = "id"]

# right join
dt2[dt1, on = "id"]

#####################
## Importar datos ###
#####################

# Asegurar que los datos existen

## Si no haz creado la carpeta de data en tu directorio de trabajo
# # Revisa si existe, si no crea la carpeta
# if (!file.exists("data/bd")) {
#   dir.create("data")
#   dir.create("data/tracks")
# }

# links_bd <- list(
#   "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/bp_subgenre.csv",
#   "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/bp_genre.csv",
#   "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/bp_artist_track.csv.gz",
#   "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/bp_subgenre.csv"
#   
# )
# 
# lapply(seq_along(links_bd), function(x){download.file(url = links_bd[[x]], destfile = paste0("data/bd/tracks/", names(links_bd[x])))})
# 
# links_tracks <- list(
#  tracks1.csv.gz = "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/tracks/tracks_1.csv.gz",
#  tracks2.csv.gz = "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/tracks/tracks_2.csv.gz",
#  tracks3.csv.gz = "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/tracks/tracks_3.csv.gz",
#  tracks4.csv.gz = "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/tracks/tracks_4.csv.gz",
#  tracks5.csv.gz = "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/tracks/tracks_5.csv.gz",
#  tracks6.csv.gz = "https://raw.githubusercontent.com/sofiazorrilla/data.table_long/refs/heads/main/data/bd/tracks/tracks_6.csv.gz"
#   
# )
# 
# lapply(seq_along(links_tracks), function(x){download.file(url = links_tracks[[x]], destfile = paste0("data/bd/tracks/", names(links_tracks[x])))})


## Ejercicio: Nos gustaría explorar la distribución de canciones de diferentes géneros a lo largo del tiempo. Para esto primero tenemos que unir las tablas tracks, genre y subgenre. En el diagrama puedes ver las columnas que las unen.

# Enlistar los archivos de canciones (guardados en la carpeta de tracks)
tracks <- list.files("data/bd/tracks", full.names = T)

# Enlistar los archivos restantes en la carpeta bd
files <- c(list.files("data/bd", full.names = T, pattern = ".csv*"), tracks)

# Leer los archivos usando fread
data_files <- lapply(files,fread)
names(data_files) <- c(list.files("data/bd", pattern = ".csv*"), list.files("data/bd/tracks"))

# Guardar los datos en objetos diferentes
genre <- data_files$bp_genre.csv
subgenre <- data_files$bp_subgenre.csv
artist <- data_files$bp_artist.csv.gz
artist_track <- data_files$bp_artist_track.csv.gz
tracks <- do.call(rbind,data_files[5:8])

# Borrar la lista de archivos
rm(data_files)

# Union de tablas
tracks_genre <- merge(tracks,genre[,.(genre_id,genre_name)],by = "genre_id") 

# Visualiza el número de canciones por genero que se publicaron cada año (release_date) del 2000 al 2024

freq_tracks <- tracks_genre[,.N,by = .(genre_name, Yr = format(release_date,"%Y"))]

# Opcional: Subconjunto de los géneros con más canciones.
labels <- freq_tracks[, .SD[which.max(N)], by = genre_name][order(-N)][1:5]

# Generar un vector de 6 colores (el último debe ser gris) para colorear las líneas de los subgeneros
colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "gray")
names(colors) <- c(labels$genre_name, "other")

# Generar una nueva columna que se llame color donde solo aparecen los nombres de los 5 generos más escuchados (en sus filas correspondientes) y el resto de las celdas tiene la palabra "other". 
freq_tracks[,color := ifelse(genre_name %in% labels$genre_name, genre_name, "other")] 

library(ggrepel)

freq_tracks %>% 
  ggplot(aes(x = as.numeric(Yr), y = N, group = genre_name))+
  geom_line(color = "gray", size = 1, alpha = 0.8)+
  geom_line(data = freq_tracks[genre_name %in% labels$genre_name], aes(color = factor(color, levels = c(labels$genre_name, "other"))), size = 2)+
  geom_text_repel(data = labels, aes(label = genre_name, color = factor(genre_name, levels = c(labels$genre_name, "other"))), nudge_y= 500)+
  scale_color_manual(values = colors)+
  scale_x_continuous(limits = c(2000,2025))+
  labs(x = "Year", y = "N songs", color = "Género")+
  theme_bw()

#########################################
### Reformatear tablas     ##############
#########################################

## Larga a ancha

# Vamos a utilizar la tabla de canciones del top50 en 73 paises

# Queremos crear una tabla de conteos de cada cancion por pais por mes en el que se hizo el listado top 50
freq_song_long <- data[country != "",.(.N), by = .(name,country,month_yr = format(snapshot_date,"%Y-%m"))]
freq_song_long

freq_song_wide <- dcast(freq_song_long, month_yr+name~country, value.var = "N", fill = 0)
freq_song_wide[,1:9]

## Larga a ancha con una función de resumen

dcast(data[country != ""], country + name ~ format(snapshot_date,"%Y"), value.var = "popularity", fun.aggregate = function(x){round(mean(x, na.rm = T),digits = 1)})

## Larga a ancha: múltiples columnas simultáneas

pop_rank_per_year <- dcast(data[country != ""], country + name ~ format(snapshot_date,"%Y"), value.var = c("daily_rank", "popularity"), sep = ".", fun.aggregate = function(x){round(mean(x, na.rm = T),digits = 1)})

pop_rank_per_year


## Ancha a larga 

freq_song_long2 <- melt(freq_song_wide, id.vars = c("month_yr","name"), variable.name = "country", value.name = "N")
freq_song_long2

## Guardar valores en distintas columnas (forma 1)
colA = paste0("daily_rank.", 2023:2024)
colB = paste0("popularity.", 2023:2024)
pop_rank_year_long <- pop_rank_per_year %>% 
  melt(., measure = list(colA, colB), value.name = c("daily_rank", "popularity"), variable.name = "year")

pop_rank_year_long[,year := ifelse(year == 1, 2023,2024)]
pop_rank_year_long

## Guardar valores en dos columnas utilizando patrones en los encabezados de las tablas

pop_rank_per_year %>% 
  melt(., measure = patterns("^daily_rank.", "^popularity."), value.name = c("daily_rank", "popularity"), variable.name = "year")

# Generar una columna de variables (variables combinadas) y otra de valores.

pop_rank_per_year %>% 
  melt(., measure.vars = measure(var=as.factor, year=as.integer, sep="."), value.name = "mean")

##################################################
## SD.()                ##########################
##################################################

# Subconjunto de la tabla completa
identical(data, data[ , .SD])

# Subconjunto de columnas
data[,.SD,.SDcols = c("artists","name")] %>% str()

# Subconjunto de columnas por condición 
data[,.SD, .SDcols = is.numeric] %>% str()

# Para ver el efecto de los siguientes ejercicios lee la tabla de canciones asignando el tipo de datos de todas las columnas como caracter
data = fread("data/universal_top_spotify_songs.csv.gz", colClasses = 'character')


# Cambiar el tipo de datos a las columnas de fechas 
data[,names(.SD) := lapply(.SD,as.Date),.SDcols = patterns('_date')]
str(data)

# Cambiar el tipo de datos a las columnas numéricas
numeric_cols <- c("daily_rank","daily_movement","weekly_movement","popularity","duration_ms","danceability","energy","key","loudness","mode","speechiness","acousticness","instrumentalness","liveness","valence","tempo","time_signature")

data[,names(.SD) := lapply(.SD,as.numeric), .SDcols = numeric_cols]
str(data)

## Aplicar modelos con distintas variables

vars <- c("danceability","energy","loudness","valence")

# Queremos generar modelos para evaluar como es que diferentes variables afectan la popularidad de las canciones.


models = unlist(
  lapply(1:length(vars), combn, x = vars, simplify = FALSE),
  recursive = FALSE
)

test <- summary(lm(popularity ~ danceability, data = data[snapshot_date == max(snapshot_date),])) 

lms = lapply(models, function(rhs) {
  data[snapshot_date == max(snapshot_date),][, 
                                             .( call = paste("popularity ~ ",paste(rhs,collapse = " + ")),
                                                terms = c("Intercept",rhs),
                                                coefs = coef(lm(popularity ~ ., data = .SD)),
                                                pvals = summary(lm(popularity ~ ., data = .SD))$coefficients[,4],
                                                radj = summary(lm(popularity ~ ., data = .SD))$adj.r.squared), .SDcols = c("popularity",rhs)]
})

results <- do.call(rbind,lms)

results


## Operaciones sobre grupos.

song_freq <- data[country != "",.N, by = .(country,name)]

hist(song_freq$N)

# Que cancion tiene el mayor numero de registros por pais 
song_freq[,.SD[which.max(N)], by = country] %>% head()



## Uniones condicionales

Sales <- data.table(
  storeID = c(1, 1, 2, 2),
  sale_date = as.IDate(c("2023-01-15", "2023-03-10", "2023-04-01", "2023-02-15")),
  amount = c(500, 750, 1200, 600)
)

Targets <- data.table(
  storeID = c(1, 1, 2, 2),
  start_date = as.IDate(c("2023-01-01", "2023-04-01", "2023-01-01", "2023-04-01")),
  end_date = as.IDate(c("2023-03-31", "2023-06-30", "2023-03-31", "2023-06-30")),
  target = c(600, 800, 1000, 1200)
)

# Add start_date and end_date to Sales as the same value (to use for range-based join)
Sales[, c("start_date","end_date"):=.(sale_date,sale_date)]

# Join Sales and Targets based on storeID and date range, and assign target as team_performance
Sales[storeID %in% c(1, 2), 
      target := Targets[.SD, target, on = .(storeID, x.sale_date <= end_date, end_date >= start_date)]]

Sales

#Sales[Targets, target := x.target, on = .(storeID, sale_date >= start_date, sale_date <= end_date)]



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

