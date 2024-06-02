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

# Fonction principale pour charger et filtrer les données
function process_data(file_path)
    # Charger les données
    df = CSV.read(file_path, DataFrame, skipto = 21, header = 20, comment="#", dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true)
    if "TX" in names(df)
        df_filtered = filter(row -> year(row.DATE) >= 1955 && year(row.DATE) <= 2005 && row.Q_TX != 9, df)
        df_daily = @chain df_filtered begin
            @select(:DATE, :TX)
        end
    else
        df = CSV.read(file_path, DataFrame, header = 60, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
        if !("Tmax" in names(df))
            df = CSV.read(file_path, DataFrame, header = 59, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)
        end
        if "Tmax" in names(df)
            df_filtered = filter(row -> year(row.Date) >= 1955 && year(row.Date) <= 2005, df)
            df_daily = @chain df_filtered begin
                @select(:Date, :Tmax)
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
        rename!(df_cumulative, Symbol(names(df_cumulative)[2]) => Symbol("TEMP_$station_name"))
        cumulative_data[station_name] = df_cumulative
    end
    
    # Fusionner les données pour aligner les dates
    combined_df = reduce((df1, df2) -> outerjoin(df1, df2, on=names(df1)[1]), values(cumulative_data))
    
    # Remplacer les valeurs manquantes par la moyenne de la colonne
    for col in names(combined_df)[2:end]
        combined_df[!, col] = coalesce.(combined_df[!, col], mean(skipmissing(combined_df[!, col])))
    end
    
    # Calculer les corrélations entre chaque paire de stations
    corr_matrix = cor(Matrix(select(combined_df, Not(names(combined_df)[1]))))
    
    return corr_matrix
end

# Exemple d'utilisation

data_folder = "data_station_extract_script/data_tx/"
data_folder_drias = "data_drias/Mod1_temp/"
data_folder_mod2 = "data_drias/Mod2_temp/"
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
    color = :orange
)
scatter!(
    corr_matrix,
    corr_matrix_racmo,
    label = "RACMO",
    color = :green
)
plot!(0:0.1:1, 0:0.1:1, label = false, color=:black)
savefig("pisenli.pdf")