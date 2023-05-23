using VPLGraphs
using Test
include("types.jl")
import .GT

let

    # Construction of StaticGraph from user-defined type that inherits from VPLNodeData
    n1 = [GT.bar(i) for i in 1:6]
    g1 = n1[1] + n1[2] + (n1[3], n1[4] + n1[5]) + n1[6]
    n2 = [VPLGraphs.GraphNode(GT.bar(i)) for i in 1:6]
    g2 = n2[1] + n2[2] + (n2[3], n2[4] + n2[5]) + n2[6]

    @test typeof(g1) == typeof(g2) == VPLGraphs.StaticGraph
    @test length(g1) == length(g2)
    @test VPLGraphs.rootNode(g1) |> VPLGraphs.data ==
          VPLGraphs.rootNode(g2) |> VPLGraphs.data
    @test VPLGraphs.insertion_node(g1) |> VPLGraphs.data ==
          VPLGraphs.insertion_node(g2) |> VPLGraphs.data

    n3 = [GT.bar(i) for i in 1:4]
    g3 = n1[1] + (n1[3] + n1[4], n1[2])
end
