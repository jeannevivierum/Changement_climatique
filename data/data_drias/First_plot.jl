using CSV, Dates, DataFrames, DataFramesMeta, Statistics

df = CSV.read("data/data_drias/donnees/Bastia.txt",DataFrame, header = 1, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

df_month = @chain df begin
    @subset(:Tmoy .!= 9) # remove missing 
    @transform(:MONTH = month.(:Date)) # add month column
    @by(:MONTH, :MONTHLY_MEAN = mean(:Tmoy), :MONTHLY_STD = std(:Tmoy)) # grouby MONTH + takes the mean/std in each category 
end

using StatsPlots
@df df_month plot(monthabbr.(1:12), :MONTHLY_MEAN, ribbon = :MONTHLY_STD, label = "Mean Temperature")
ylabel!("Temperature(°C)")