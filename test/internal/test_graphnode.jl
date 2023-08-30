import PlantGraphs as V
using Test
include("types.jl")
import .GT

let
    # Test GraphNode construction
    n = V.GraphNode(GT.A())

    # Check that this returns the correct type
    @test n isa V.GraphNode
    @test !isimmutable(n)

    # Check deafult constructor
    @test ismissing(V.parent_id(n))
    @test isempty(V.children_id(n))

    # Add connections
    V.add_child!(n, 1)
    @test length(V.children_id(n)) == 1 && first(V.children_id(n)) == 1
    V.set_parent!(n, 2)
    @test V.parent_id(n) == 2

    # Create a copy of the node
    n2 = copy(n)

    # Remove connections
    V.remove_child!(n, 1)
    @test isempty(V.children_id(n))
    V.remove_parent!(n)
    @test ismissing(V.parent_id(n))

    # The resulting node should be root and leaf
    @test V.isleaf(n)
    @test V.isroot(n)

    # Retrieve data stored inside the node
    @test V.data(n) === GT.A()

    # Make sure that the copied node was independent
    @test V.haschildren(n2)
    @test V.has_parent(n2)
end
