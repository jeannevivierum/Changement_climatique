using CSV
using DataFrames
using Statistics
using TimeSeries: TimeArray
using Plots
using StatsBase

# Charger les données
df = CSV.read("data/data_drias/donnees/Orly.txt", DataFrame, header=1, comment="#", dateformat="yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données pour la période spécifiée
df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

# Calculer la moyenne et l'écart type pour chaque date
df_monthly = @chain df_filtered begin
    @subset(:Tmoy .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date), :MONTH = month.(:Date)) # Ajouter des colonnes pour l'année et le mois
    @by(:YEAR, :MONTH, :MONTHLY_MEAN = mean(:Tmoy), :MONTHLY_STD = std(:Tmoy)) # Grouper par année et mois et prendre la moyenne / écart type
end


# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN) # Changer le nom de la variable ts

# Décomposer la série temporelle en tendance, saisonnalité et résidus
function decompose_series(series::TimeArray)
    y = values(series) # Extraire les valeurs de la série temporelle
    n = length(y)
    
    # Déterminer la composante de tendance avec une moyenne mobile sur 12 mois
    trend = [mean(y[i-11:i]) for i = 12:n]
    
    # Déterminer la composante saisonnière en soustrayant la tendance de la série originale
    seasonal = y[12:end] .- trend
    
    # Les résidus sont la série originale moins la somme de la tendance et de la saisonnalité
    residuals = y[12:end] .- (trend .+ seasonal)
    
    seasonal, trend, residuals
end



# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN) # Changer le nom de la variable ts

# Décomposer la série temporelle en tendance, saisonnalité et résidus
seasonal, trend, residuals = decompose_series(my_ts)

# Plot
plot(my_ts, label="Original")
plot(trend, label="Tendance")
plot!(seasonal, label="Saisonnalité")
plot!(residuals, label="Résidus")

# _____________________________________________________________________________________________
using CSV
using DataFrames
using Statistics
using TimeSeries: TimeArray
using Plots

# Charger les données
df = CSV.read("data/data_drias/donnees/Orly.txt", DataFrame, header=1, comment="#", dateformat="yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données pour la période spécifiée
df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Tmoy .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmoy)) # Grouper par DATE et prendre la moyenne
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.Date, df_daily.DAILY_MEAN) # Changer le nom de la variable ts

# Décomposer la série temporelle en tendance, saisonnalité et résidus
function decompose_series(series::TimeArray)
    y = values(series) # Extraire les valeurs de la série temporelle
    n = length(y)
    
    # Déterminer la composante de tendance avec une moyenne mobile sur 12 mois
    trend = [mean(y[max(1, i-11):i]) for i = 1:n]
    
    # Déterminer la composante saisonnière en soustrayant la tendance de la série originale
    seasonal = y .- trend
    
    # Les résidus sont la série originale moins la somme de la tendance et de la saisonnalité
    residuals = y .- (trend .+ seasonal)
    
    seasonal, trend, residuals
end

# Décomposer la série temporelle
seasonal, trend, residuals = decompose_series(my_ts)

# Plot
p1 = plot(collect(eachindex(my_ts)), values(my_ts), label="Original", xlabel="Date", ylabel="Value", title="Original Time Series")
p2 = plot(collect(eachindex(my_ts)), trend, label="Trend", xlabel="Date", ylabel="Value", title="Trend Component")
p3 = plot(collect(eachindex(my_ts)), seasonal, label="Seasonal", xlabel="Date", ylabel="Value", title="Seasonal Component")
p4 = plot(collect(eachindex(my_ts)), residuals, label="Residuals", xlabel="Date", ylabel="Value", title="Residuals Component")

plot(p1, p2, p3, p4, layout=(2, 2), legend=false)
