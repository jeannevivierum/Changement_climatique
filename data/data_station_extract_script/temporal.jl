using ARCHModels
using DataFrames
using Dates
using StatsPlots
using DataFramesMeta
using TimeSeries
using CSV

# Charger les données
csv_file = CSV.File("data_tx/TX_STAID000032.txt", skipto = 22, header = 21, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date))
df = DataFrame(csv_file)

# Filtrer les données entre 1970 et 2006
df_filtered = filter(row -> year(row.DATE) >= 1970 && year(row.DATE) <= 2006, df)

# Conversion factor to °C
factor = 0.1

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Q_TX .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
    @by(:DATE, :DAILY_MEAN = mean(:TX)*factor, :DAILY_STD = std(:TX)*factor) # Grouper par DATE et prendre la moyenne / écart type
end

# Créer une série temporelle à partir du DataFrame
ts = TimeArray(df_daily.DAILY_MEAN, df_daily.DATE)

# Décomposer la série temporelle
decomposition = ARCHModels.decompose(ts)

# Tracer les composantes de la décomposition
plot(decomposition)
