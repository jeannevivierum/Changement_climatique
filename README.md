# 2024_Projet_M1_SSD_Climat

## Le projet

On cherche à comparer les statistiques (mean, variance, correlation spatial/temporelle, modélisation, extrême, etc.) entre des données observées historiques (à des stations météo) VS des données issues de simulations (on prendra les points de maille les plus proches des stations concernées).
Le but étant de quantifier un peu comment ces modèles sont bons/mauvais. Idéalement, on comparera plusieurs modèles pour faire un classement par catégorie (autocorrelation, extrême, etc).

### Données

Quelques stations météo situées en France métropolitaine.

- Données historiques [European Climate Assessment & Dataset project](https://www.ecad.eu/dailydata/predefinedseries.php). L'idée est de d'inspecter un fichier station pour ne garder que des stations en France pour ne pas deziper toute l'archive. On regardera les variables `TX`, `TN`, `TG` et `RR`. Prenez la version `blend`.
- Données de simulation sur le site DRIAS. Voir le sous-dossier [`data_drias`](https://github.com/dmetivie/2023_Projet_M1_SSD_Climat/blob/ad128464008337fcdfa8a7e5f48f39e33785256e/data/data_drias). Il y a un petit script + un PowerPoint pour extraire des données.

### Modélisation

- On modélisera aussi les températures à l'aide de modèles auto-régressifs en se demandant quel modèle est le plus adapté (sélection de modèle).

- Il sera peut-être intéressant de voir comment si `TG`, `TN` et `TX` suivent les mêmes modèles ?

- (Bonus) On modélisera l'effet du changement climatique sur les températures et pourquoi pas, sur d'autres variables.
"Trend" ou tendance.

## Julia

Le langage de programmation sera Julia. L'encadrant vous guidera, si vous ne connaissez pas (c'est très proche de Python/R/Matlab).  

Pour l'installation voir utiliser Juliaup, j'explique sur [cette page](https://dmetivie.github.io/MyJuliaIntroDocs.jl/dev/talk/) comment faire.

## Pour commencer

### Package à installer pour Julia

Il y a plusieurs manière d'instaaller les packages mais pour commencer installer les packages suivants (copier ces lignes dans votre terminal Julia):

```julia
import Pkg
#install
Pkg.add(["StatsPlots", "BenchmarkTools", "DataFrames", "DataFramesMeta", "Printf", "CSV", "StatsBase"]) # notebook pkg, Plot pkg, timing pkg
```

### Data

Regarder en premier `TX`, pour choisir les stations. Le script [extract.jl](https://github.com/dmetivie/2023_Projet_M1_SSD_Climat/blob/ad128464008337fcdfa8a7e5f48f39e33785256e/data/data_station_extract_script/extract.jl) (à faire tourner dans le dossier approprié avec les bon `path` pour l'archive zip) devrait vous aider pour extraire le ficher `station.txt` et deziper les stations en France.

Une fois les fichiers météo dezipé, ouvrez les à l'aide de `DataFrames.jl` et `CSV`.
Ensuite commencer à les explorer.

## Tips

- Commenter votre code
- Éviter le code redondant, ex:

```julia
df[1, :TG] = 1
df[2, :TG] = 2
df[1, :TX] = 1
df[2, :TX] = 2
# écrivez plutot
for var in [:TG, :TX]
    df[:,var] = [1, 2]
end
```

- Définissez des variables
- Écrire du Markdown, avec formules pour définir un minimum les modèles et méthodes
- Faire des jolis plots

## Évaluation

Il vous faudra écrire un rapport en LaTeX. N'attendez pas la dernière minute.
Il faudra aussi faire une présentation orale (format libre).
