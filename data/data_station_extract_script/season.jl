using CSV
using DataFrames
using Dates
using StatsPlots
using Statistics
using Temporal
using GLM
using Forecast

# Charger les données
df = CSV.read("data_tx/LYON.txt", DataFrame, skipto = 22, header = 21, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true)

# Filtrer les données entre 1970 et 2006
df_filtered = filter(row -> year(row.DATE) >= 1951 && year(row.DATE) <= 2020, df)

# Conversion factor to °C
factor = 0.1

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Q_TX .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
    @by(:DATE, :DAILY_MEAN = mean(:TX)*factor, :DAILY_STD = std(:TX)*factor) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle
datats = TimeArray(df_daily.DATE, df_daily.DAILY_MEAN)

stl(datats,365; robust=true, spm=true)
