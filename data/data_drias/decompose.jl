# test de l'estimation des coefficients à l'aide du package Forecast

# premier test avec un ar(2) simulé aléatoirement
import Pkg
Pkg.add(url="https://github.com/yellowflash/Forecast.jl")
using Forecast
using Random

# Simuler un processus AR(2)
Random.seed!(123) # Pour la reproductibilité
n = 100 # Nombre d'observations
φ1, φ2 = 0.5, -0.3 # Coefficients AR(2)
ε = randn(n) # Erreurs aléatoires
y = zeros(n)

# Générer les données AR(2)
for t in 3:n
    y[t] = φ1 * y[t-1] + φ2 * y[t-2] + ε[t]
end

# Ajuster un modèle AR(2)
model = ar(y, 2)

# Afficher les résultats
println(model)


# maintenant, testons avec les données drias pour voir si tout fonctionne :
using Plots
using CSV
using DataFrames
using DataFramesMeta
using Dates
using StatsPlots
using Statistics
using Temporal
using TimeSeries: TimeArray 
using StatsBase


# je ne sais pas pourquoi je n'arrive plus à importer les données correctement...
#ça me refait le coup du truc qui marche pas jpp ok en fait si ca marche ouf
df_drias = CSV.read("data/data_drias/donnees/Orly.txt",DataFrame, header = 60, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date))
df_filtered_drias = filter(row -> year(row.Date) >= 1951 && year(row.Date) <= 2005, df_drias)

df_month_drias = @chain df_filtered_drias begin
    @subset(:Tmax .!= 9) # remove missing 
    @transform(:MONTH = month.(:Date)) # add month column
    @by(:MONTH, :MONTHLY_MEAN = mean(:Tmax), :MONTHLY_STD = std(:Tmax)) # grouby MONTH + takes the mean/std in each category 
end


df_daily_drias = @chain df_filtered_drias begin
    @subset(:Tmax .!= 9) # Supprimer les valeurs manquantes 
    @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
    @by(:Date, :DAILY_MEAN = mean(:Tmax), :DAILY_STD = std(:Tmax)) # Grouper par DATE et prendre la moyenne / écart type
end

stl_df_drias = stl(df_daily_drias,730; robust=true, spm=true)

stl_df_drias.decomposition


function retiresaisonnalite(data::Vector{T}) where T
    n = length(data)
    saisonnalite = stl_df_drias.decomposition.Seasonal
    tendance = stl_df_drias.decomposition.Trend
    
    for i in 1:n
        data[i] = data[i] - saisonnalite[i] - tendance[i]
    end
    
    return data
end

residus_drias = retiresaisonnalite(df_daily_drias.DAILY_MEAN)


# Tracer la série temporelle de la saisonnalité
plot!(df_daily_drias.Date, residus_drias, label="Résidus DRIAS", xlabel="Date", ylabel="Résidus (°C)")

# Ajuster un modèle AR(2) sur les résidus
model = ar(residus_drias, 2)

# Afficher les résultats
println(model)



### OOOOOKKKKKK ca a l'air de marcher, en plus c'est trop cool ca donne plein d'infos genre le R2, l'aic le bic et tout
# tout raconter à mario

