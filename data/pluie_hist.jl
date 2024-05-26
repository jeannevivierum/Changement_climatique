using CSV
using DataFrames
using DataFramesMeta
using Dates
using StatsPlots
using Statistics
using Temporal
using GLM
using TimeSeries: TimeArray 
using StatsBase
using Forecast
using LinearAlgebra
using DataFrames: rename!

# Charger les données
df = CSV.read("data_station_extract_script/data_rr/ORLY.txt", DataFrame, skipto = 21, header = 20, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true)
df_drias = CSV.read("data_drias/Mod1_pluie/orly.txt",DataFrame, header = 48, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
df_mod2 = CSV.read("data_drias/Mod2_pluie/orly.txt",DataFrame, header = 47, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données entre 1951 et 2006
df_filtered = filter(row -> year(row.DATE) >= 1955 && year(row.DATE) <= 2005, df)
df_filtered_drias = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df_drias)
df_filtered_mod2 = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df_mod2)

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Q_RR .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
    @by(:DATE, :DAILY_MEAN = mean(:RR)*factor, :DAILY_STD = std(:RR)*factor) # Grouper par DATE et prendre la moyenne / écart type
end
# Calculer la moyenne et l'écart type pour chaque date
df_daily_drias = @chain df_filtered_drias begin
    @subset(:mm .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:mm), :DAILY_STD = std(:mm)) # Grouper par DATE et prendre la moyenne / écart type
end

df_daily_mod2 = @chain df_filtered_mod2 begin
    @subset(:mm .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:mm), :DAILY_STD = std(:mm)) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.DATE, df_daily.DAILY_MEAN)
my_ts_drias = TimeArray(df_daily_drias.Date, df_daily_drias.DAILY_MEAN)

# Extraire les valeurs numériques de la série temporelle
data_values = values(my_ts)
data_values_drias = values(my_ts_drias)



# Fonction pour calculer la somme cumulée des pluies par année
function somme_pluie(df)
    @chain df begin
        @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
        @by(:YEAR, :YEARLY_SUM = sum(:DAILY_MEAN)) # Grouper par YEAR et prendre la somme
    end
end

function somme_pluie_drias(df)
    @chain df begin
        @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
        @by(:YEAR, :YEARLY_SUM = sum(:DAILY_MEAN)) # Grouper par YEAR et prendre la somme
    end
end


df_pluies_1 = somme_pluie(df_daily)
df_pluies_2 = mean(df_pluies_1.YEARLY_SUM)
df_pluies = df_pluies_1.YEARLY_SUM .-df_pluies_2

df_pluies_drias_1 = somme_pluie_drias(df_daily_drias)
df_pluies_drias_2 = mean(df_pluies_drias_1.YEARLY_SUM)
df_pluies_drias = df_pluies_drias_1.YEARLY_SUM .-df_pluies_drias_2

df_pluies_mod2_1 = somme_pluie_drias(df_daily_mod2)
df_pluies_mod2_2 = mean(df_pluies_mod2_1.YEARLY_SUM)
df_pluies_mod2 = df_pluies_mod2_1.YEARLY_SUM .-df_pluies_mod2_2

pluies_diff_A = df_pluies_drias_1.YEARLY_SUM - df_pluies_1.YEARLY_SUM
pluies_diff_R = df_pluies_mod2_1.YEARLY_SUM - df_pluies_1.YEARLY_SUM 

bar(
    df_pluies_1.YEAR, df_pluies_1.YEARLY_SUM,
    label="Données observées",
    xlabel="Année",
    xlims = (1953,2007),
    ylabel="Somme des précipitations (mm/m2)",
    legend=:bottomright,
    alpha = 0.9)

bar!(df_pluies_drias_1.YEAR, 
df_pluies_drias_1.YEARLY_SUM, 
label="Données ALADIN63",
alpha = 0.7)

bar!(df_pluies_mod2_1.YEAR, 
df_pluies_mod2_1.YEARLY_SUM, 
label="Données RACMO22E",
alpha = 0.65)
#savefig("Pluies_obs.pdf")

bar(
    df_pluies_1.YEAR, pluies_diff_A,
    label="Avec ALADIN63",
    xlabel="Année",
    xlims = (1953,2007),
    ylabel="Différence des précipitations (mm/m2)",
    color=:darkorange,
    legend=:bottomright,
    alpha = 0.7)
    bar!(df_pluies_drias_1.YEAR, 
    pluies_diff_R, 
    color=:green,
    label="Avec RACMO22E",
    alpha = 0.5)
#savefig("Pluies_diff.pdf")








