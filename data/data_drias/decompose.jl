# Fonction decompose
using TimeSeries: TimeArray # Importer uniquement TimeArray à partir de TimeSeries

function decompose(series::TimeArray{T}, freq::Int) where T
data_values = values(series)
n = length(data_values)
seasonal = similar(data_values)
trend = similar(data_values)
residual = similar(data_values)

# Calcul de la tendance
window_size = freq
trend .= [mean(data_values[i:i+window_size-1]) for i in 1:n-window_size+1]


# Calcul de la saisonnalité moyenne pour chaque période
seasonal_mean = [mean(residual[i:freq:n]) for i in 1:freq]
    
    # Soustraire la tendance de la série temporelle pour obtenir les résidus
    residual .= data_values .- trend
    
    # Calculer la saisonnalité moyenne pour chaque période
    seasonal_mean = [mean(residual[i:freq:n]) for i in 1:freq]
    
    # Répéter la saisonnalité moyenne pour ajuster la longueur de la série
    seasonal .= repeat(seasonal_mean, outer=(div(n, freq),))
    
    # Soustraire la saisonnalité de la série temporelle pour obtenir les résidus saisonniers
    residual_seasonal = residual .- seasonal
    
    return Dict("trend" => trend, "seasonal" => seasonal, "residual" => residual_seasonal)
end

# test de la fonction decompose

using CSV
using DataFrames
using Dates
using TimeSeries: TimeArray # Importer uniquement TimeArray à partir de TimeSeries

# Charger les données
df = CSV.read("data/data_drias/donnees/Orly.txt", DataFrame, header=1, comment="#", dateformat="yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données pour la période spécifiée
df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

# Calculer la moyenne pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Tmoy .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmoy), :DAILY_STD = std(:Tmoy)) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN) # Changer le nom de la variable ts

# Décomposer la série temporelle
result = decompose(my_ts, 12)

# Afficher les résultats
println("Tendance : ", result["trend"])
println("Saisonnalité : ", result["seasonal"])
println("Résidus : ", result["residual"])
