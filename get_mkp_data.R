# Libraries ----
library(sidrar)
library(tidyverse)

# Get data ----

## Dados de salário para o setores da indústria de transformação
data_salario = get_sidra(api = "/t/1841/n1/all/v/all/p/all/C12762/all")s