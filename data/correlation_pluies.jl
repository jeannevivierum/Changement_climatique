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
using DataFrames: rename!

# Fonction principale pour charger, filtrer et calculer les moyennes journalières
function process_data(file_path)
    # Charger les données
    df = CSV.read(file_path, DataFrame, skipto = 21, header = 20, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true)
    if "RR" in names(df)
        df_filtered = filter(row -> year(row.DATE) >= 1955 && year(row.DATE) <= 2005, df)
        factor = 0.1
        df_daily = @chain df_filtered begin
            @subset(:Q_RR .!= 9) # Supprimer les valeurs manquantes
            @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
            @by(:DATE, :DAILY_MEAN = mean(:RR)*factor, :DAILY_STD = std(:RR)*factor)
            @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
            @by(:YEAR, :YEARLY_SUM = sum(:DAILY_MEAN))
        end
    else
        df = CSV.read(file_path, DataFrame, header = 48, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
        if !("mm" in names(df))
            df = CSV.read(file_path, DataFrame, header = 47, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
        end
        df_filtered = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df)
        df_daily = @chain df_filtered begin
            @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
            @by(:Date, :DAILY_MEAN = mean(:mm), :DAILY_STD = std(:mm))
            @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
            @by(:YEAR, :YEARLY_SUM = sum(:DAILY_MEAN))
        end
    end
    
    return df_daily
end

# Fonction pour calculer les matrices de corrélation à partir d'un dossier
function calculate_correlations(data_folder)
    files = readdir(data_folder)
    cumulative_data = Dict{String, DataFrame}()
    
    for file in files
        file_path = joinpath(data_folder, file)
        station_name = splitext(basename(file))[1]
        df_cumulative = process_data(file_path)
        rename!(df_cumulative, :YEARLY_SUM => Symbol("YEARLY_SUM_$station_name"))
        cumulative_data[station_name] = df_cumulative
    end
    
    # Fusionner les données pour aligner les années
    years = DataFrame(YEAR = 1955:2005)
    for (station, df) in cumulative_data
        years = outerjoin(years, df, on=:YEAR)
    end
    
    # Calculer les corrélations entre chaque paire de stations
    corr_matrix = cor(Matrix(select(years, Not(:YEAR))))
    
    return corr_matrix
end

# Exemple d'utilisation

data_folder = "data_station_extract_script/data_rr/"
data_folder_drias = "data_drias/Mod1_pluie/"
data_folder_mod2 = "data_drias/Mod2_pluie/"
corr_matrix_aladin = calculate_correlations(data_folder_drias)  
corr_matrix_racmo = calculate_correlations(data_folder_mod2) 
corr_matrix = calculate_correlations(data_folder)


function extract_upper_triangle(matrix)
    return [matrix[i, j] for i in 1:size(matrix, 1) for j in 1:size(matrix, 2) if i > j]
end

corr_matrix = extract_upper_triangle(corr_matrix)
corr_matrix_aladin = extract_upper_triangle(corr_matrix_aladin)
corr_matrix_racmo = extract_upper_triangle(corr_matrix_racmo)

scatter(
    corr_matrix,
    corr_matrix_aladin,
    xlims=(0, 1.1),
    ylims=(0, 1.1),
    label = "ALADIN",
    color =:orange
)
scatter!(
    corr_matrix,
    corr_matrix_racmo,
    label = "RACMO",
    color = :green
)
plot!(0:0.1:1, 0:0.1:1, label = false, color=:black)
savefig("pluies_corr.pdf")

# Tracer la matrice de corrélation
custom_palette = cgrad([:brown, :white, :purple], scale=false)
heatmap(
    corr_matrix_aladin,
    xticks=(1:length(station_names), collect(station_names)),
    yticks=(1:length(station_names), collect(station_names)),
    ylabel="Stations",
    xlabel=".",
    color=custom_palette,
    clim=(-2, 2),
    xrotation=80
)
savefig("matrice_pluie_aladin")
heatmap(
    corr_matrix_racmo,
    xticks=(1:length(station_names), collect(station_names)),
    yticks=(1:length(station_names), collect(station_names)),
    ylabel="Stations",
    xlabel=".",
    color=custom_palette,
    clim=(-2, 2),
    xrotation=80
)
savefig("matrice_pluie_racmo")

