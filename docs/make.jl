using PlantGraphs
using Documenter

makedocs(;
    doctest = false,
    modules = [PlantGraphs],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "master",
        assets = String[]),
    authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
    repo = "https://github.com/VirtualPlantLab/PlantGraphs.jl/blob/{commit}{path}#{line}",
    sitename = "PlantGraphs.jl",
    pages = [
        "Home" => "index.md",
    ])

deploydocs(;
    repo = "github.com/VirtualPlantLab/PlantGraphs.jl.git",
    devbranch = "master")
