using Statistics

function deseasonalize(df::DataFrame, seasonality::Int)
    dates = df.Date
    data = df.DAILY_MEAN
    n = length(data)
    deseasonalized_data = similar(data)

    for i in 1:n
        # Calculer l'indice de la saison correspondante
        season_index = mod(i - 1, seasonality) + 1
        
        # Calculer la moyenne de la saison correspondante
        seasonal_mean = mean(data[i:seasonality:n])
        
        # Soustraire la moyenne saisonnière de la valeur actuelle
        deseasonalized_data[i] = data[i] - seasonal_mean
    end

    return dates, deseasonalized_data
end

# Appliquer la désaisonnalisation au DataFrame original
timestamps, deseasonalized_data = deseasonalize(df_daily, 12)

# Afficher la série temporelle désaisonnalisée
plot(timestamps, deseasonalized_data)


#--------------------------------------------------------------------------------------

using Statistics

function stl_seasonal_decompose(data::Vector{T}, seasonality::Int) where T
    n = length(data)
    seasonal = zeros(T, n)
    trend = zeros(T, n)
    residuals = zeros(T, n)

    # Ajuster la tendance locale pour chaque saison
    for i in 1:seasonality:n
        season_data = data[i:min(i+seasonality-1, n)]
        season_trend = trend_local(season_data)
        trend[i:min(i+seasonality-1, n)] .= season_trend
    end

    # Soustraire la tendance de chaque saison pour obtenir la composante saisonnière
    seasonal = data .- trend

    # Faire une moyenne des composantes saisonnières pour chaque période
    seasonal_means = [mean(seasonal[j:seasonality:n]) for j in 1:seasonality]

    # Soustraire la moyenne saisonnière de chaque période
    for i in 1:n
        seasonal[i] -= seasonal_means[mod(i - 1, seasonality) + 1]
    end

    # Calculer les résidus
    residuals = data - seasonal - trend

    return seasonal, trend, residuals
end

# Fonction pour ajuster une tendance locale avec une moyenne mobile
function trend_local(data::Vector{T}; window_size::Int=5) where T
    return [mean(data[max(1, i - (window_size-1) ÷ 2):min(end, i + (window_size-1) ÷ 2)]) for i in eachindex(data)]
end

# Appliquer la décomposition saisonnière à vos données météorologiques
seasonal_component, trend_component, random_component = stl_seasonal_decompose(df_daily.DAILY_MEAN, 12)

# Afficher la composante saisonnière
plot(df_daily.Date, seasonal_component, xlabel="Date", ylabel="Composante saisonnière", label="Seasonal Component")


#_____________________________________________________________________________________
function stl_monthly_seasonal_decompose(data::Vector{T}, years::Vector{Int}, months::Vector{Int}, min_year::Int) where T
    n = length(data)
    seasonal = zeros(T, n)
    trend = zeros(T, n)
    residuals = zeros(T, n)

    # Calculer les moyennes par mois
    monthly_means = [mean(data[(years .== y) .& (months .== m)]) for y in unique(years), m in 1:12]

    # Ajuster la tendance locale pour chaque mois
    for m in 1:12
        month_data = [monthly_means[i, m] for i in 1:size(monthly_means, 1)]
        month_trend = trend_local(month_data)
        println(size(month_trend))  # Ajout de la ligne de débogage
        for i in 1:n
            if months[i] == m
                trend[i] = month_trend[month_year_index(years[i], m, min_year)]
            end
        end
    end

    # Soustraire la tendance de chaque mois pour obtenir la composante saisonnière
    seasonal = data .- trend

    # Faire une moyenne des composantes saisonnières pour chaque mois
    seasonal_means = [mean(seasonal[months .== m]) for m in 1:12]

    # Soustraire la moyenne saisonnière de chaque mois
    for i in 1:n
        seasonal[i] -= seasonal_means[months[i]]
    end

    # Calculer les résidus
    residuals = data - seasonal - trend

    return seasonal, trend, residuals
end
