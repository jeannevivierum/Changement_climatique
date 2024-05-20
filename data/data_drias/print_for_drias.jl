# Define a station DataFrame with all station you want.

using DataFrames
cd(@__DIR__)
# Données fournies
data = [
    (48.5733, 7.7521, "Strasbourg"),
    (43.62, 1.38, "Toulouse-Blagnac"),
    (48.7436, 2.3928, "Orly"),
    (43.5986, 3.8969, "Montpellier"),
    (48.3899, -4.487, "Brest"),
    #(49.443, 1.102, "Rouen"),
    (49.1821,0.371,"Caen"), # ok
    (45.7796, 3.087, "Clermont-Ferrand"),
    (50.6319, 3.0575, "Lille"),
    #(45.7588, 4.8414, "Lyon"),
    (47.0836, 2.3955, "Bourges"), 
    (42.6974, 2.8948, "Perpignan"),
    (47.2187, -1.5536, "Nantes"),
    #(42.6999, 9.4495, "Bastia"),
    (41.9254,8.7363,"Ajaccio"), # ok
    #(48.6929, 6.1835, "Nancy"),
    (47.3229,5.0411,"Dijon"), # ok
    (44.8377, -0.5796, "Bordeaux"),
    #(43.2965, 5.3763, "Marseille")
    (43.4169,5.2145,"Marignane") # ok
]

# Création du DataFrame
station = DataFrame(LAT = Float64[], LON = Float64[], STANAME = String[])

# Remplissage du DataFrame
for d in data
    push!(station, d)
end

# Affichage du DataFrame
println(station)


# The following code will generate something in the right format to extract from DRIAS the closest grid point.
for i = 1:nrow(station)
    println(round(station[i, :LAT]; digits = 2), ";", round(station[i, :LON], digits = 2), ";", station[i, :STANAME])
end


# Copy paste your Output into Drias
# Example
# 42.54;9.49;BASTIA
# 43.44;5.22;MARIGNANE
# 43.62;1.38;TOULOUSE-BLAGNAC
# 44.57;6.5;EMBRUN
# 46.05;-1.41;PTE DE CHASSIRON
# 47.06;2.36;BOURGES
# 48.72;2.38;ORLY
# 49.63;6.2;LUXEMBOURG AIRPORT
# 49.73;-1.94;PTE DE LA HAGUE
# 50.57;3.1;LILLE-LESQUIN

id_to_station_STAID = Dict(
    :O4230 => 4 # Montpellier
    :03673 => 15 # Marseille
    :02361 => 10 # Perpignan
    :04205 => 2 # Toulouse-Blagnac
    :06617 => 14 # Bordeaux
    :02852 => 12 # Bastia
    :14274 => 1 # Strasbourg
    :159786 => 6 # Rouen
    :18092 => 8 # Lille
    :14368 => 3 # Orly
    :08512 => 7 # Clermont-Ferrand
    :14018 => 5 # Brest
    :08529 => 9 # Lyon
    :11471 => 11 # Nantes
    :14403 => 13 # Nancy
 )
# run(`ls -1 | sed 's/P//' | sed 's/_tasminAdjusttasmaxAdjusttasAdjustprtotAdjust_France_CNRM-CERFACS-CNRM-CM5_CNRM-ALADIN63_rcp8.5_METEO-FRANCE_ADAMONT-France_SAFRAN_day_20060101-21001231.txt//'`)
# run(`ls -1 | sed 's/P//' | sed 's/_tasminAdjusttasmaxAdjusttasAdjust_France_CNRM-CERFACS-CNRM-CM5_CNRM-ALADIN63_Historical_METEO-FRANCE_ADAMONT-France_SAFRAN_day_19510101-20051231.txt//'`)


# P02857_tasminAdjusttasmaxAdjusttasAdjust_France_CNRM-CERFACS-CNRM-CM5_CNRM-ALADIN63_Historical_METEO-FRANCE_ADAMONT-France_SAFRAN_day_19510101-20051231.txt


# CSV.read("donnees/P02361_tasminAdjusttasmaxAdjusttasAdjust_France_CNRM-CERFACS-CNRM-CM5_CNRM-ALADIN63_Historical_METEO-FRANCE_ADAMONT-France_SAFRAN_day_19510101-20051231.txt", DataFrame)

