using PlantGraphs
using Documenter
using DocumenterMarkdown

DocMeta.setdocmeta!(PlantGraphs, :DocTestSetup, :(using PlantGraphs); recursive=true)

makedocs(;
         modules = [PlantGraphs],
         format = Markdown(),
         authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
         repo = "https://github.com/VirtualPlantLab/PlantGraphs.jl/blob/{commit}{path}#{line}",
         sitename = "PlantGraphs.jl",
         # format=Documenter.HTML(;
         #     prettyurls=get(ENV, "CI", "false") == "true",
         #     edit_link="master",
         #     assets=String[],
         # ),
         pages = [
             "Home" => "index.md",
         ])
