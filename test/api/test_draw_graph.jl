using VPLGraph
using Test
using CairoMakie
include("types.jl")
import .GT
    

let
    # Test that drawing works (here we just check that the function runs without error for
    # different types of inputs)
    VPLGraph.node_label(n::GT.A, id) = "A"
    VPLGraph.node_label(n::GT.B, id) = "B"
    axiom = GT.A()
    fn = draw(axiom);
    rule1 = Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = Rule(GT.B, rhs = x -> GT.A())
    organism = Graph(axiom = axiom, rules = (rule1, rule2))
    fn = draw(organism);
    rewrite!(organism)
    fn = draw(organism);

    # Test resolution calculate_resolution
    default_res = calculate_resolution(width = 1024/300*2.54, height = 768/300*2.54, 
                              format = "raster", dpi = 300)
    @test default_res == (1024, 768)
    another_res = calculate_resolution(width = 800/300*2.54, height = 600/300*2.54, 
                                       format = "raster", dpi = 600)
    @test another_res == (1600, 1200)
    another_res = calculate_resolution(format = "vector")
    @test all(another_res .≈ (327.68, 245.76))
end