using PlantGraphs
using Test
using Documenter
import Aqua

# Test examples on documentation (jldoctest blocks)
DocMeta.setdocmeta!(PlantGraphs, :DocTestSetup, :(using PlantGraphs); recursive = true)
PlantGraphs.reset_id!() # Make sure that output is reproducible
doctest(PlantGraphs)

# Aqua
@testset "Aqua" begin
    Aqua.test_all(PlantGraphs, ambiguities = false)
    Aqua.test_ambiguities([PlantGraphs])
end

# Internal tests
@testset "Graph node" begin
    include("internal/test_graphnode.jl")
end
@testset "Static graph" begin
    include("internal/test_staticgraph.jl")
end
@testset "Internals draw" begin
    include("internal/test_draw_graph.jl")
end

# Graph creation, queries and rewriting
@testset "API/DSL" begin
    include("api/test_DSL.jl")
end
@testset "API/Graph_1" begin
    include("api/test_graph_1.jl")
end
@testset "API/Graph_2" begin
    include("api/test_graph_2.jl")
end
@testset "API/Graph_3" begin
    include("api/test_graph_3.jl")
end
@testset "API/Graph_4" begin
    include("api/test_graph_4.jl")
end
@testset "API/Graph_5" begin
    include("api/test_graph_5.jl")
end
@testset "API/Graph_6" begin
    include("api/test_graph_6.jl")
end
@testset "API/Graph_parallel" begin
    include("api/test_graph_parallel.jl")
end
@testset "API/Draw" begin
    include("api/test_draw_graph.jl")
end
