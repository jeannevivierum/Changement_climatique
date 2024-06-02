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
    if "TX" in names(df)
        df_filtered = filter(row -> year(row.DATE) >= 1955 && year(row.DATE) <= 2005, df)
        df_daily = @chain df_filtered begin
            @subset(:Q_TX .!= 9) # Supprimer les valeurs manquantes
            @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
            @by(:DATE, :DAILY_MEAN = mean(:TX), :DAILY_STD = std(:TX))
            @transform(:YEAR = year.(:DATE)) # Ajouter une colonne pour l'année
            @by(:YEAR, :YEARLY_SUM = sum(:DAILY_MEAN))
        end
    else
        df = CSV.read(file_path, DataFrame, header = 60, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
        if !("Tmax" in names(df))
            df = CSV.read(file_path, DataFrame, header = 59, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
        end
        if "Tmax" in names(df)
            df_filtered = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df)
            df_daily = @chain df_filtered begin
                @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
                @by(:Date, :DAILY_MEAN = mean(:Tmax), :DAILY_STD = std(:Tmax))
                @transform(:YEAR = year.(:Date)) # Ajouter une colonne pour l'année
                @by(:YEAR, :YEARLY_SUM = sum(:DAILY_MEAN))
            end
        else
            error("Les colonnes 'TX' ou 'Tmax' ne sont pas présentes dans le fichier : $file_path")
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

data_folder = "data_station_extract_script/data_tx/"
data_folder_drias = "data_drias/Mod1_temp/"
data_folder_mod2 = "data_drias/Mod2_temp/"
corr_matrix_aladin = calculate_correlations(data_folder) - calculate_correlations(data_folder_drias)
corr_matrix_racmo = calculate_correlations(data_folder) - calculate_correlations(data_folder_mod2) 


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
savefig("matrice_temp_aladin")

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
savefig("matrice_temp_racmo")
