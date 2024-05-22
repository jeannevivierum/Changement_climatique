
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


# Fonction pour lire et filtrer les données
function read_and_filter_data(filepath, date_column::Symbol, value_column::Symbol, header_row::Int, skip_rows::Int)
    df = CSV.read(filepath, DataFrame, header = header_row, skipto = skip_rows, comment = "#", dateformat = "yyyymmdd", types = Dict(date_column => Date), normalizenames = true)
    df_filtered = filter(row -> year(row[date_column]) >= 1955 && year(row[date_column]) <= 2005, df)
    return df_filtered
end

# Lire tous les fichiers dans un dossier et agréger les données
function aggregate_data_from_folder(folder_path::String, date_column::Date, value_column::Symbol, header_row::Int, skip_rows::Int)
    files = readdir(folder_path)
    all_data = DataFrame()
    
    for file in files
        filepath = joinpath(folder_path, file)
        df = read_and_filter_data(filepath, date_column, value_column, header_row, skip_rows)
        append!(all_data, df)
    end
    
    # Supprimer les valeurs manquantes
    all_data = filter(row -> row[value_column] != 9, all_data)
    
    # Calculer la moyenne et l'écart type pour chaque date
    
    if value_column == :TX
        aggregated_data = @chain all_data begin
            @subset(:Q_TX .!= 9) # Supprimer les valeurs manquantes 
            @transform(:MONTH = month.(:DATE)) # Ajouter une colonne pour l'année
            @by(:MONTH, :MONTHLY_MEAN = mean(:TX), :MONTHLY_STD = std(:TX)) # Grouper par date et calculer moyenne / écart type
        end
       
    else
        aggregated_data = @chain all_data begin
            @transform(:MONTH = month.(:Date)) # Ajouter une colonne pour l'année
            @by(:MONTH, :MONTHLY_MEAN = mean(:Tmax), :MONTHLY_STD = std(:Tmax)) # Grouper par date et calculer moyenne / écart type
        end
    end

    return aggregated_data
end

# Chemins des dossiers
data_station_folder_nord = "data_station_extract_script/data_tx_nord"
data_station_folder_sud = "data_station_extract_script/data_tx_sud"
data_drias_folder_nord = "data_drias/Mod1_temp_nord"
data_drias_folder_sud = "data_drias/Mod1_temp_sud"
data_mod2_folder_nord = "data_drias/Mod2_temp_nord"
data_mod2_folder_sud = "data_drias/Mod2_temp_sud"

# Agréger les données des dossiers
data_station_aggregated_nord = aggregate_data_from_folder(data_station_folder_nord, :DATE, :TX, 21, 22)
data_station_aggregated_sud = aggregate_data_from_folder(data_station_folder_sud, :DATE, :TX, 21, 22)
data_drias_aggregated_nord = aggregate_data_from_folder(data_drias_folder_nord, :Date, :Tmax, 60, 61)
data_drias_aggregated_sud = aggregate_data_from_folder(data_drias_folder_sud, :Date, :Tmax, 60, 61)
data_mod2_aggregated_nord = aggregate_data_from_folder(data_mod2_folder_nord, :Date, :Tmax, 59, 60)
data_mod2_aggregated_sud = aggregate_data_from_folder(data_mod2_folder_sud, :Date, :Tmax, 59, 60)

# Conversion factor to °C for data_station
factor = 0.1
data_station_aggregated_nord[!, :MONTHLY_MEAN] .= data_station_aggregated_nord[!, :MONTHLY_MEAN] 
data_station_aggregated_sud[!, :MONTHLY_MEAN] .= data_station_aggregated_sud[!, :MONTHLY_MEAN] 
data_station_aggregated_nord[!, :MONTHLY_STD] .= data_station_aggregated_nord[!, :MONTHLY_STD] 
data_station_aggregated_sud[!, :MONTHLY_STD] .= data_station_aggregated_sud[!, :MONTHLY_STD] 


df_month_nord = data_station_aggregated_nord 
df_month_sud = data_station_aggregated_sud  
df_month_drias_nord = data_drias_aggregated_nord
df_month_drias_sud = data_drias_aggregated_sud
df_month_mod2_nord = data_mod2_aggregated_nord
df_month_mod2_sud = data_mod2_aggregated_sud

# Convertir les données en séries temporelles
@df df_month_nord plot(monthabbr.(1:12), :MONTHLY_MEAN, color=:blue, label = "Données observées Nord", legend=:topleft, linewidth=2)
@df df_month_sud plot!(monthabbr.(1:12), :MONTHLY_MEAN, color=:darkblue , label = "Données observées Sud", linewidth=2)
@df df_month_drias_nord plot!(monthabbr.(1:12), :MONTHLY_MEAN, color=:orange, label = "Données ALADIN63 Nord", linewidth=2)
@df df_month_drias_sud plot!(monthabbr.(1:12), :MONTHLY_MEAN, color=:darkorange, label = "Données ALADIN63 Sud", linewidth=2)
@df df_month_mod2_nord plot!(monthabbr.(1:12), :MONTHLY_MEAN, color=:green, fillalpha =0.5,  label = "Données RACMO22E Nord", linewidth=2)
@df df_month_mod2_sud plot!(monthabbr.(1:12), :MONTHLY_MEAN, color=:darkgreen, fillalpha =0.5, label = "Données RACMO22E Sud", linewidth=2)
ylabel!("Temperature(°C)")
xlabel!("Mois")