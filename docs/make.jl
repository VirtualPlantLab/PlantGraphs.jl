using VPLGraphs
using Documenter
using DocumenterMarkdown

# DocMeta.setdocmeta!(VPLGraph, :DocTestSetup, :(using VPLGraphs); recursive=true)

makedocs(;
         modules = [VPLGraphs],
         format = Markdown(),
         authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
         repo = "https://github.com/VirtualPlantLab/VPLGraphs.jl/blob/{commit}{path}#{line}",
         sitename = "VPLGraphs.jl",
         # format=Documenter.HTML(;
         #     prettyurls=get(ENV, "CI", "false") == "true",
         #     edit_link="master",
         #     assets=String[],
         # ),
         pages = [
             "Home" => "index.md",
         ])
