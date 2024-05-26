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

# Charger les données
df = CSV.read("data_station_extract_script/data_tx/MONTPELLIER.txt", DataFrame, skipto = 22, header = 21, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true)
df_drias = CSV.read("data_drias/Mod1_temp/Montpellier.txt",DataFrame, header = 60, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
df_mod2 = CSV.read("data_drias/Mod2_temp/Montpellier.txt",DataFrame, header = 59, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

# Filtrer les données entre 1951 et 2006
df_filtered = filter(row -> year(row.DATE) >= 1955 && year(row.DATE) <= 2005, df)
df_filtered_drias = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df_drias)
df_filtered_mod2 = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df_mod2)

factor = 0.1

# Calculer la moyenne et l'écart type pour chaque date
df_daily = @chain df_filtered begin
    @subset(:Q_TX .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
    @by(:DATE, :DAILY_MEAN = mean(:TX)*factor, :DAILY_STD = std(:TX)*factor) # Grouper par DATE et prendre la moyenne / écart type
end
# Calculer la moyenne et l'écart type pour chaque date
df_daily_drias = @chain df_filtered_drias begin
    @subset(:Tmax .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmax), :DAILY_STD = std(:Tmax)) # Grouper par DATE et prendre la moyenne / écart type
end

df_daily_mod2 = @chain df_filtered_mod2 begin
    @subset(:Tmax .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmax), :DAILY_STD = std(:Tmax)) # Grouper par DATE et prendre la moyenne / écart type
end

# Convertir les données en une série temporelle avec TimeSeries
my_ts = TimeArray(df_daily.DATE, df_daily.DAILY_MEAN)
my_ts_drias = TimeArray(df_daily_drias.Date, df_daily_drias.DAILY_MEAN)

# Extraire les valeurs numériques de la série temporelle
data_values = values(my_ts)
data_values_drias = values(my_ts_drias)

function moyenne_valeurs(df, start_date, end_date)
    subset = filter(row -> start_date <= row.DATE <= end_date, df)
    if nrow(subset) == 0
        return NaN  # Retourner NaN si aucune donnée n'est trouvée dans l'intervalle spécifié
    else
        return mean(subset.DAILY_MEAN)  # Utiliser la colonne DAILY_MEAN pour calculer la moyenne
    end
end

function moyenne_valeurs_drias(df, start_date, end_date)
    subset = filter(row -> start_date <= row.Date <= end_date, df)
    if nrow(subset) == 0
        return NaN  # Retourner NaN si aucune donnée n'est trouvée dans l'intervalle spécifié
    else
        return mean(subset.DAILY_MEAN)  # Utiliser la colonne DAILY_MEAN pour calculer la moyenne
    end
end

# Exemple d'utilisation :
start_date = Date(1995, 1, 1) 
end_date = Date(1995, 1, 15)
moyenne = moyenne_valeurs(df_daily, start_date, end_date)

function vagues_de_chaleur(df)

    moyennes_par_an = Float64[]  # Tableau pour stocker les moyennes par année
    
    for year in start_year:end_year
        moyennes_juin_aout = Float64[]  # Tableau pour stocker les moyennes de juin à août
        
        for day_offset in 0:15:75
            start_date = Date(year, 6, 1) + Day(day_offset)
            end_date = Date(year, 8, 31) - Day(75 - day_offset)
            
            push!(moyennes_juin_aout, moyenne_valeurs(df, start_date, end_date))
        end
        
        push!(moyennes_par_an, maximum(moyennes_juin_aout))
    end
    
    return moyennes_par_an
end

function vagues_de_chaleur_drias(df)
    start_year = 1955
    end_year = 2005
    moyennes_par_an = Float64[]  # Tableau pour stocker les moyennes par année
    
    for year in start_year:end_year
        moyennes_juin_aout = Float64[]  # Tableau pour stocker les moyennes de juin à août
        
        for day_offset in 0:15:75
            start_date = Date(year, 6, 1) + Day(day_offset)
            end_date = Date(year, 8, 31) - Day(75 - day_offset)
            
            push!(moyennes_juin_aout, moyenne_valeurs_drias(df, start_date, end_date))  # Utiliser moyenne_valeurs avec les données DRiAS
        end
        
        push!(moyennes_par_an, maximum(moyennes_juin_aout))
    end
    
    return moyennes_par_an
end

start_year = 1955
end_year = 2005

vagues = vagues_de_chaleur(df_daily)
vagues_drias = vagues_de_chaleur_drias(df_daily_drias)
vagues_mod2 = vagues_de_chaleur_drias(df_daily_mod2)
plot(start_year:end_year,vagues, label = "Données observées", xlab = "Temps (Années)", ylab = "Température (°C)", linestyle=:solid, marker=:circle, markersize=:2)
plot!(start_year:end_year,vagues_drias, label = "Données ALADIN63")
plot!(start_year:end_year,vagues_mod2, label = "Données RACMO22E")