using CSV
using DataFrames
using Dates
using StatsPlots
using Statistics
using Temporal
using GLM

# Charger les données
df = CSV.read("data_tx/TX_STAID000032.txt", DataFrame, skipto = 22, header = 21, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true)

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

function moyenne_mobile(data::Vector{T}, window_size::Int) where T
    n = length(data)
    trend = similar(data, T)
    for i in 1:n
        start_idx = max(1, i - window_size ÷ 2)
        end_idx = min(n, i + window_size ÷ 2)
        trend[i] = mean(@view(data[start_idx:end_idx]))
    end
    return trend
end

# Calculer la tendance par moyenne mobile avec une fenêtre de taille 5000 (par exemple)
trend_values = moyenne_mobile(df_daily.DAILY_MEAN, 5000)

# Convertir les données en une série temporelle
ts = TimeArray(df_daily.DATE, df_daily.DAILY_MEAN)

# Tracer la série temporelle avec la tendance
plot(ts, label="Série temporelle", xlabel="Date", ylabel="Température (°C)", legend=:topleft)
plot!(df_daily.DATE, trend_values, label="Tendance (Moyenne mobile)", linewidth=2)
