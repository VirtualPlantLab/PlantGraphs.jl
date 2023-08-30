import PlantGraphs as V
using Test
include("types.jl")
import .GT

let
    ### Constructors and DSL

    # Empty StaticGraph constructor
    g1 = V.StaticGraph()
    @test V.root_id(g1) == V.insertion_id(g1) == -1
    @test length(g1) == 0
    @test length(g1.nodetypes) == 0

    # Single node StaticGraph constructor
    n1 = V.GraphNode(GT.A())
    g2 = V.StaticGraph(n1)
    @test V.root_id(g2) == V.insertion_id(g2) == collect(keys(g2.nodes))[1]
    @test length(g2) == 1
    @test length(g2.nodetypes) == 1
    @test V.has_nodetype(g2, GT.A)

    # DSL with GraphNodes
    n1 = V.GraphNode(GT.AV(1))
    n2 = V.GraphNode(GT.BV(2))
    n3 = V.GraphNode(GT.CV(3))
    g3 = n1 + n2 + n3
    @test V.root_id(g3) < V.insertion_id(g3)
    @test length(g3) == 3
    @test length(g3.nodetypes) == 3
    @test sum(i.data.val for i in V.nodes(g3) |> values |> collect) == 6
    @test isroot(V.getroot(g3))
    @test !isleaf(V.getroot(g3))
    @test isleaf(V.insertion(g3))
    @test !isroot(V.insertion(g3))
    @test sum(isleaf(node) for node in V.nodes(g3) |> values) == 1
    @test sum(isroot(node) for node in V.nodes(g3) |> values) == 1

    # DSL with GraphNodes with branches
    n = [V.GraphNode(GT.AV(i)) for i in 1:6]
    g4 = n[1] + n[2] + (n[3], n[4] + n[5]) + n[6]
    @test length(g4) == 6
    @test sum(isleaf(node) for node in V.nodes(g4) |> values) == 3
    @test sum(isroot(node) for node in V.nodes(g4) |> values) == 1
end
