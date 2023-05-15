import VPLGraph as V
using Test

let
    ### Constructors and DSL

    # Empty StaticGraph constructor
    g1 = V.StaticGraph()
    @test V.root(g1) == V.insertion(g1) == -1
    @test length(g1) == 0
    @test length(g1.nodetypes) == 0

    # Single node StaticGraph constructor
    n1 = V.GraphNode(1)
    g2 = V.StaticGraph(n1)
    @test V.root(g2) == V.insertion(g2) == collect(keys(g2.nodes))[1]
    @test length(g2) == 1
    @test length(g2.nodetypes) == 1
    @test V.has_nodetype(g2, Int)

    # DSL with GraphNodes
    n1 = V.GraphNode(1)
    n2 = V.GraphNode(2)
    n3 = V.GraphNode(3)
    g3 = n1 + n2 + n3
    @test V.root(g3) < V.insertion(g3)
    @test length(g3) == 3
    @test length(g3.nodetypes) == 1
    @test sum(i.data for i in V.nodes(g3) |> values |> collect) == 6
    @test V.nodetypes(g3)[Int] |> values |> collect |> sort ==
          V.nodes(g3) |> keys |> collect |> sort
    @test is_root(g3[V.root(g3)])
    @test !is_leaf(g3[V.root(g3)])
    @test is_leaf(g3[V.insertion(g3)])
    @test !is_root(g3[V.insertion(g3)])
    @test sum(is_leaf(node) for node in V.nodes(g3) |> values) == 1
    @test sum(is_root(node) for node in V.nodes(g3) |> values) == 1

    # DSL with GraphNodes with branches
    n = [V.GraphNode(i) for i in 1:6]
    g4 = n[1] + n[2] + (n[3], n[4] + n[5]) + n[6]
    @test length(g4) == 6
    @test sum(is_leaf(node) for node in V.nodes(g4) |> values) == 3
    @test sum(is_root(node) for node in V.nodes(g4) |> values) == 1
end
