#! For this code to run be careful with the path of the files (`comment.sh` and the ECA archive)

# load pakages (need to be installed with `Pkg.add` before)
using CSV, Printf, DataFrames

obs = "tx" # change for tx, tm, tg, rr, pp, etc.
OBS = uppercase(obs)
#! remove `wsl` command for bash (Linux or Mac) terminal. 
#! wsl must be installed on Windows. I don't know for MAC I guess it is the same as Linux

# extract the station file from the zip
run(`unzip ECA_blend_$(obs).zip stations.txt`)

# comment the first 17 lines 
run(`./comment.sh 1,17 'stations.txt'`)

# read the station.txt file and convert it as a DataFrame
station_all = CSV.read("stations.txt", DataFrame, comment="#", normalizenames=true, ignoreemptyrows=true)

# remove white space at the right of the name which is caused by imperfect CVS importation
station_all.STANAME = rstrip.(station_all.STANAME)

# Need some whitespace in CN too !
station_all.CN = rstrip.(station_all.CN)

# In the station find all STAID (ID of each station) the one located in FR or BE or LU
STAID_FR = station_all.STAID[findall(.|(station_all.CN .== "FR", station_all.CN .== "BE", station_all.CN .== "LU"))]

# names of files to extract
files_to_extract_STAID_FR = [string(OBS, "_", @sprintf("STAID%06.d.txt", i)) for i in STAID_FR]
#print(files_to_extract_STAID_FR)
# extract the all weather files selected
run(`unzip ECA_blend_$(obs).zip $files_to_extract_STAID_FR`)

# comments all extracted weather files
for i in files_to_extract_STAID_FR
   run(`./comment.sh 1,20 $i`) # for some reason sometimes it fails (in general toward the end of the loop) and returns
   # sed: couldn't close ./sedl43nmF: Erreur d'entrée/sortie
   # ERROR: LoadError: failed process: Process(`../comment 1,20 RR_STAID011249.txt`, ProcessExited(4)) [4]
end
# run(`for i in RR_\*\; do ../comment 1,20 \$i\; done`) # Does not work. Should do the same as abov