using VPLGraph
using Documenter

DocMeta.setdocmeta!(VPLGraph, :DocTestSetup, :(using VPLGraph); recursive=true)

makedocs(;
    modules=[VPLGraph],
    authors="Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
    repo="https://github.com/AleMorales/VPLGraph.jl/blob/{commit}{path}#{line}",
    sitename="VPLGraph.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
