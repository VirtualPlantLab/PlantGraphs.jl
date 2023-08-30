import PlantGraphs as V
using Test

include("types.jl")
import .GT
import Graphs

let
    ## Static graph
    n = [GT.bar(i) for i in 1:6]
    g = n[1] + n[2] + (n[3], n[4] + n[5]) + n[6]

    # DOT version of graph
    digraph, labels, n = Graphs.DiGraph(g)
    @test digraph isa Graphs.SimpleGraphs.SimpleDiGraph
    @test labels isa Vector{String}
    @test n isa Integer
    @test n == length(labels) == 6

    # Dynamic graph
    axiom = GT.A()
    rule1 = V.Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = V.Rule(GT.B, rhs = x -> GT.A())
    algae = V.Graph(axiom = axiom, rules = (rule1, rule2))
    V.rewrite!(algae)
    digraph, labels, n = Graphs.DiGraph(algae)
    @test digraph isa Graphs.SimpleGraphs.SimpleDiGraph
    @test labels isa Vector{String}
    @test n isa Integer
    @test n == length(labels)
end
