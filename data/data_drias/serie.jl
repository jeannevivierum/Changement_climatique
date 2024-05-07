using CSV
using DataFrames
using DataFramesMeta
using Dates
using Statistics
using TimeSeries: TimeArray # Importer uniquement TimeArray à partir de TimeSeries
using Plots

# Charger les données
df = CSV.read("donnees/Orly.txt", DataFrame, header=1, comment="#", dateformat="yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données pour la période spécifiée
df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Tmoy .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmoy), :DAILY_STD = std(:Tmoy)) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN) # Changer le nom de la variable ts


plot(my_ts)




