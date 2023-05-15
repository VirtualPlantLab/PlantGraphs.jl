using VPLGraph
using Documenter
using DocumenterMarkdown

# DocMeta.setdocmeta!(VPLGraph, :DocTestSetup, :(using VPLGraph); recursive=true)

makedocs(;
         modules = [VPLGraph],
         format = Markdown(),
         authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
         repo = "https://github.com/VirtualPlantLab/VPLGraph.jl/blob/{commit}{path}#{line}",
         sitename = "VPLGraph.jl",
         # format=Documenter.HTML(;
         #     prettyurls=get(ENV, "CI", "false") == "true",
         #     edit_link="master",
         #     assets=String[],
         # ),
         pages = [
             "Home" => "index.md",
         ])
