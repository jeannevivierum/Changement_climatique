using Dates, DataFrames, DataFramesMeta, StatsBase


df = CSV.read("data_tx/TX_STAID000032.txt", DataFrame, skipto = 22, header = 21, comment="#",dateformat = "yyyymmdd", types=Dict(:DATE => Date), normalizenames=true, ignoreemptyrows=true)

factor = 0.1 # conversion factor to °C
df_month = @chain df begin
    @subset(:Q_TX .!= 9) # remove missing 
    @transform(:MONTH = month.(:DATE)) # add month column
    @by(:MONTH, :MONTHLY_MEAN = mean(:TX)*factor, :MONTHLY_STD = std(:TX)*factor) # grouby MONTH + takes the mean/std in each category 
end

using StatsPlots
@df df_month plot(monthabbr.(1:12), :MONTHLY_MEAN, ribbon = :MONTHLY_STD, label = "Mean Temperature")
ylabel!("Temperature(°C)")