# Define a station DataFrame with all station you want.
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

# id_to_station_STAID = Dict(
#     O2572 => 7
#     03958 => 3
#     04205 => 2
#     06258 => 6 
#     08898 => 9
#     10936 => 1
#     14368 => 10
#     15975 => 4
#     16331 => 8
#     17949 => 5
# )
# run(`ls -1 | sed 's/P//' | sed 's/_tasminAdjusttasmaxAdjusttasAdjustprtotAdjust_France_CNRM-CERFACS-CNRM-CM5_CNRM-ALADIN63_rcp8.5_METEO-FRANCE_ADAMONT-France_SAFRAN_day_20060101-21001231.txt//'`)