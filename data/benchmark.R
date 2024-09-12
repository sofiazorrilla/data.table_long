## Script para poner a prueba la velocidad de lectura de fread vs read.csv

library(rbenchmark)
library(data.table)

test = benchmark("r base" = {
            read.csv("plantae_mexico_conCoords_specimen.csv")
          },
          "data.table" = {
            fread("plantae_mexico_conCoords_specimen.csv")
          },
          replications = 10,
          columns = c("test", "replications", "elapsed",
                      "relative", "user.self", "sys.self"))

write.csv(test, "benchmark_results.csv")