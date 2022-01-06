# Libraries ----
library(sidrar)
library(tidyverse)

# Get data para o setores da indústria de transformação ----

        ## Dados de salário 
        data_salario = get_sidra(api = "/t/1841/n1/all/v/all/p/all/C12762/all")
        
        ## Dados de receitas
        data_receita = get_sidra(api = "/t/1845/n1/all/v/all/p/all/C12762/all")
        
        ## Dados de custos e despesas
        data_custos_1 = get_sidra(api = "/t/1847/n1/all/v/all/p/2007,2008,2009,2010,2011,2012/C12762/all")
        data_custos_2 = get_sidra(api = "/t/1847/n1/all/v/all/p/2013,2014,2015,2016,2017,2018,2019/C12762/all")

# Get data IPCA
        
        ## Dados de IPCA
        data_ipca = get_sidra(api = "/t/1737/n1/all/v/all/p/all")
        