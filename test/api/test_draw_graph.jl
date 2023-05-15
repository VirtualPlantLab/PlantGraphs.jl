using VPLGraph
using Test

include("types.jl")
import .GT

let

    VPLGraph.node_label(n::GT.A, id) = "A"
    VPLGraph.node_label(n::GT.B, id) = "B"
    axiom = GT.A()
    rule1 = Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = Rule(GT.B, rhs = x -> GT.A())
    organism = Graph(axiom = axiom, rules = (rule1, rule2))
    rewrite!(organism)

    # Test that drawing works (here we just check that the function runs without error)
    fn = draw(organism);

end