# AUTOCORRELOGRAMME PARTIEL 

using StatsBase
using Plots
using CSV
using DataFrames
using DataFramesMeta
using Dates
using Statistics
using TimeSeries: TimeArray # Importer uniquement TimeArray à partir de TimeSeries

# Charger les données
df = CSV.read("data/data_drias/donnees/Orly.txt", DataFrame, header=1, comment="#", dateformat="yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données pour la période spécifiée
df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Tmoy .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmoy), :DAILY_STD = std(:Tmoy)) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN)

# Extraire les valeurs numériques de la série temporelle
data_values = values(my_ts)

# Calculer l'autocorrélogramme partiel avec un nombre maximal de décalages spécifié
maxlag = 50 # Définir le nombre maximal de décalages
lags = collect(0:maxlag) # Créer une plage de décalages
pacf_values = pacf(data_values, lags)

# Tracer l'autocorrélogramme partiel avec les points reliés à l'axe des abscisses
plot(0:maxlag, pacf_values, xlabel="Lag", ylabel="Partial Autocorrelation", title="autocorrélogramme partiel", markershape=:circle, line=:stem)
hline!([0], color=:black, linewidth=1.5)


# AUTOCORRELOGRAMME EMPIRIQUE

using StatsBase
using Plots
using CSV
using DataFrames
using DataFramesMeta
using Dates
using Statistics
using TimeSeries: TimeArray # Importer uniquement TimeArray à partir de TimeSeries

# Charger les données
df = CSV.read("data/data_drias/donnees/Orly.txt", DataFrame, header=1, comment="#", dateformat="yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données pour la période spécifiée
df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Tmoy .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmoy), :DAILY_STD = std(:Tmoy)) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN)

# Extraire les valeurs numériques de la série temporelle
data_values = values(my_ts)

# Calculer l'autocorrélogramme empirique avec un nombre maximal de décalages spécifié
maxlag = 20 # Définir le nombre maximal de décalages
lags = collect(0:maxlag) # Créer une plage de décalages
autocor_values = autocor(data_values, lags)

# Tracer l'autocorrélogramme empirique avec les points reliés à l'axe des abscisses et une droite d'équation nulle
plot(0:maxlag, autocor_values, xlabel="Lag", ylabel="Autocorrelation", title="autocorrélogramme empirique", markershape=:circle, line=:stem)
hline!([0], color=:black, linewidth=1.5)
