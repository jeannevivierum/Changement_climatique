# premiers pas package Forecast
using Forecast
stl_co2 = stl(co2(),365; robust=true, spm=true)
stl_co2.decomposition
using StatsPlots
# je préfère plotter moi même je n'aime pas trop les plots tout integrés du genre plot (stl co2)*
@df stl_co2.decomposition plot(:Timestamp, :Seasonal)
