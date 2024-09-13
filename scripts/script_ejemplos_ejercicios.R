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

# as.data.frame(DT)

# Asegurar que los datos existen

## Si no haz creado la carpeta de data en tu directorio de trabajo
# # Revisa si existe, si no crea la carpeta
# if (!file.exists("data")) {
#   dir.create("data")
# }

# # Descarga el archivo de datos en la carpeta de data
# download.file(url = "https://drive.google.com/file/d/1uMM71MMAaV19pxWNlDdchOZbXhcRIQbH/view?usp=sharing", destfile = "data/universal_top_spotify_songs2.csv")

# Leer archivo

data  <- fread("data/universal_top_spotify_songs.csv")

head(data)

# Escribir archivo

fwrite(data, "data/sub_100000_plantae_mexico_conCoords_specimen_2.csv", sep = ",")

# Opcional (escribir archivo comprimido)

# fwrite(data, "data/plantae_mexico_conCoords_specimen.csv.gz", sep = ",", compress = "auto")

##################################################
## Operaciones sobre las filas: filtros y orden ##
##################################################

# Filtros por índices

data[1:2] 

data[1:2,] 

# Filtros por condicion

data_quercus <- data[genus == "Quercus",,] 

dim(data_quercus)

data_quercus_viejos <- data[genus == "Quercus" & year <= 1950,]

dim(data_quercus_viejos)

# Nota: En el filtro solo mantiene los TRUE
all(!is.na(data_quercus_viejos$year))
all(!is.na(data_quercus$year))

# Ordenar filas 

ordered_data = data_quercus[order(stateProvince)]

unique(ordered_data$stateProvince)


## Ejercicio: 

# 1. Carga el archivo de registros de plantas utilizando la función fread que revisamos en el tema anterior
# 2. Utiliza un filtro para quedarte con las filas que pertenezcan a un género o especie que te guste
# 3. Ordena de manera descendente por año

# Pregunta:

# ¿De qué año son los registros más nuevos y más viejos de la especie que escogiste? (selecciona utilizando 
# rangos la primera y la última fila de la tabla)



##################################################
## Operaciones sobre las columnas: seleccion #####
##################################################

# Seleccionar por indice

data[,7:8,]

# Seleccionar por nombre

data[,species] 

# Seleccionar múltiples columnas

data[,list(family,genus,species)]

data[,.(family,genus,species)]

# Seleccionar multiples columnas guardadas en una variable

variables <- c("family","genus","species")

data[ , ..variables]

## Ejercicio:

# 1. Selecciona las columnas que contengan información 
# acerca de la ubicación geográfica de los registros.

# Renombrar columnas

data[, .(especie = species, genero = genus)]


##################################################
## Operaciones sobre las columnas: Modificacion ##
##################################################

#seleccionar múltiples características al mismo tiempo
data[family=="Araceae" & year==1997]
### Contar el número de coincidencias para los criterios usando .N
data[family=="Araceae" & year==1997, .N]

### Ejercicio

#Pregunta:
#¿Cuántos registros hay para el año 1983? (Utiliza .N)


# # Descarga el archivo de datos en la carpeta de data
# download.file(url = "https://raw.githubusercontent.com/R-Ladies-Morelia/CursosRladiesMorelia_RladiesQueretaro_2024/main/Hackaton2024/Taller_data.table/data/flights14.csv", destfile = "data/flights14.csv")

### Leer dataset flights

flights <- fread("data/flights14.csv")

#### Obtener la media
flights[, mean(dep_delay)]

#### Hacer filtros y posteriormente efectuar operaciones

flights[origin == "JFK" & month == 2L,
        .(mean_arr = mean(arr_delay))]

## Ejercicio

#Ahora es tu turno: Calcula el promedio de retraso de salida y entrada para 
#todos los vuelos que salieron del aeropuerto JFK en el mes de Junio. 
#Llama a tus nuevas columnas "mean_arr" y "mean_dep"

### Agregar nuevas columnas a flights
flights[, dif:=dep_delay - arr_delay]
flights

#### Calcular en una columna independiente

flights[, .(dif = dep_delay - arr_delay)]

##################################################
## Operaciones sobre las columnas: Agrupacion ####
##################################################
### Contar el numero de registro agrupoando por año
data[, .N,  by = year]

### Ejercicio

#Podrías identificar en qué año se tienen más registros? 
#No es necesario usar la nomeclatura de data.table. 

#### Estimar el mínimo, agrupando por familia

data[, min(year),by=family]

### Contar registros usando múltiples agrupaciones

plants[, .N,by=.(family, year)]

## Ejercicio
#En qué año y para qué familia hay más registros?

##################################################
## Cadenas de operaciones ########################
##################################################

# Ejemplo de cadenas de operaciones

# 1. Seleccionar los registros del género Quercus y filtrar aquellos que 
# no tienen información acerca de la especie o del año de colecta

data[genus == "Quercus" & !is.na(species) & species != "" & !is.na(year)]

# 2. Agrupar por especie y por año de colecta

# 3. Contar el número de registros de que se 
# realizó para cada especie en cada año

data[genus == "Quercus" & !is.na(species) & species != "" & !is.na(year), .(.N), by = .(year,species)]

# 4. Ordenar la columna de número de registros de mayor a menor


data[genus == "Quercus" & !is.na(species) & species != "" & !is.na(year), .(N = .N), by = .(year,species)][order(year,-N)]


##################################################
## Uniones entre tablas ##########################
##################################################


dt1 = data.table(id = seq(1,10), letter1 = LETTERS[sample(1:10, replace = T)])

dt2 = data.table(id = seq(6,15), letter2 = LETTERS[sample(1:10, replace = T)])

# Función merge

# inner join
merge(dt1,dt2,by = "id")

# left join
merge(dt1,dt2,by = "id", all.x = T)

# right join
merge(dt1,dt2,by = "id", all.y = T)

# full join
merge(dt1,dt2,by = "id", all = T)

# Sintaxis de data.table

# inner join
dt1[dt2, on = "id", nomatch=0]

# left join
dt1[dt2, on = "id"]

# right join
dt2[dt1, on = "id"]

##################################################
## Ejercicio final: Manhattan plot ###############
##################################################
### Antes de iniciar este ejercicio asegúrate de tener
### el archivo que puedes conseguir en este link:
### https://drive.google.com/file/d/16za7dS3DcMR_VKFJdszLU2kJUS9bB7Dr/view?usp=share_link
### Guarda este archivo en el folder data
### Cuánto tiempo se tarda en el leer este archivo usando read.table?
start.time <- Sys.time()
triglycerides <- read.table(gzfile("data/Triglycerides_INT.imputed.stats.gz"), header=T, stringsAsFactors = FALSE, sep = "\t")
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
head(triglycerides)
class(triglycerides)
dim(triglycerides)

#### Y usando data.table? 
start.time <- Sys.time()
triglycerides_2 <- fread(file = "/Users/mpalma/Downloads/full_cohort/Triglycerides_INT.imputed.stats.gz", header = T)
end.time <- Sys.time()
time.taken.2 <- end.time - start.time
time.taken.2

### Exploración de datos
head(triglycerides_2)
class(triglycerides_2)

### Haremos un ejercicio para obtener un Manhattan plot,
### comunment usado para presentar resultados de Genome
### Wide Assoction Studies (GWAS)
##### Selecciona sólo las columnas necesarias
triglycerides_2 <- triglycerides_2[, .(CHROM, GENPOS, ID, P)]
#### Renombrar columnas
triglycerides_2 <- triglycerides_2[,.(CHR = CHROM, BP=GENPOS , SNP=ID, P)]
#### Puedes explorar setnames para maneras alternativas de renombrar
#### .() hace referencia a una lista
### Agrupar por cromosoma y estimar la longitud
chr_len <- triglycerides_2[, .(chr_len = max(BP)), by = CHR]
#### Hacer la suma acumulada de la longitud de los cromosomas
chr_len[, tot := cumsum(as.numeric(chr_len)) - chr_len]
#### Añador esta informacio al data set original
cum_triglycerides <- merge(triglycerides_2, chr_len[, .(CHR, tot)], by = "CHR")
#### Añadir la posicion acumulada a cada variante/SNP (Single Nucleotide Polymorphism)
cum_triglycerides <- cum_triglycerides[order(CHR, BP)]
cum_triglycerides[, BPcum := BP + tot]
### Ahora a hacer nuestro gráfico
### Para el eje de las x
### Estimar la posición central para cada cromosoma de 
### acuerdo a las posiciones de cada cromosoma
axisdf <- cum_triglycerides[, .(center = (max(BPcum) + min(BPcum)) / 2), by = CHR]

Manhattan_plot <- ggplot(cum_triglycerides, aes(x=BPcum, y=-log10(P))) +
  
  # Graficar los puntos y azul y gris intercalado por cromosoma
  geom_point( aes(color=as.factor(CHR)), alpha=0.8, size=0.5) +
  scale_color_manual(values = rep(c("grey", "skyblue"), 22 )) +
  
  # Personalizar ejes
  scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +
  scale_y_continuous(expand = c(0, 0), labels=scales::number_format(accuracy = 0.1) , limits=c(25,0), trans = "reverse")  +  # remove space between plot area and x axis
  
  #### Añadir líneas de significancia
  geom_hline(yintercept=-log10(1e-5), color = "black", linetype="dotted", linewidth=0.3) +
  geom_hline(yintercept=-log10(5e-8), color = "black", linetype="dashed", linewidth=0.3) +
  
  #### Añadir título
  
  ggtitle("Triglycerides")+
  
  # Detalles de tema:
  theme_bw() +
  theme( 
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x =   element_blank(),
    axis.title.x = element_blank()
  )


#### Guarda tu grafico
### Esto puede tomar algún tiempo 

ggsave("data/Manhattan_example.png", plot = Manhattan_plot)



