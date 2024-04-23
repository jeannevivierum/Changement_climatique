using CSV, Dates, DataFrames

df = CSV.read("data/data_drias/donnees/Bastia.txt",DataFrame, header = 1, comment="#", dateformat = "yyyymmdd", types=Dict(:Date => Date), normalizenames=true)

df_filtered = filter(row -> year(row.Date) >= 1970 && year(row.Date) <= 2006, df)

