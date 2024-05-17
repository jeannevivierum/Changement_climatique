# premiers pas package Forecast
using Forecast
stl_co2 = stl(co2(),365; robust=true, spm=true)
stl_co2.decomposition
using StatsPlots
# je préfère plotter moi même je n'aime pas trop les plots tout integrés du genre plot (stl co2)*
@df stl_co2.decomposition plot(:Timestamp, :Seasonal)


# Test arima


using Forecast
using Random

# Générer des données simulées pour un modèle AR(2)
Random.seed!(123)  # Pour la reproductibilité
n = 100
phi = [0.5, -0.25]  # Coefficients AR
sigma = 1.0  # Écart-type du bruit blanc
data = Vector{Float64}(undef, n)
data[1:2] = randn(2)  # Initialiser les deux premières valeurs

for i in 3:n
    data[i] = phi[1] * data[i-1] + phi[2] * data[i-2] + sigma * randn()
end

# Ajuster un modèle AR(2) aux données
p = 2  # Ordre du modèle AR
model = arfit(data, p)

# Afficher les coefficients estimés
println("Coefficients estimés du modèle AR: ", model.arparams)
