using PlantGraphs
using Test
include("types.jl")
import .GT

let

    # Create axiom
    axiom = GT.A()

    # Create replacement rules
    rule1 = Rule(GT.A, rhs = x -> GT.A() + GT.B())
    rule2 = Rule(GT.B, rhs = x -> GT.A())

    # Check the created rules
    @test rule1 isa Rule && rule2 isa Rule
    @test !PlantGraphs.captures(rule1) && !PlantGraphs.captures(rule2)

    # Initialize a dynamic graph
    algae = Graph(axiom = axiom, rules = (rule1, rule2))

    # Check the Graph at the axiom stage
    @test algae isa Graph
    @test data(algae) === nothing
    @test length(rules(algae)) == 2
    @test rules(algae)[1].lhs == rule1.lhs && rules(algae)[2].lhs == rule2.lhs
    @test rules(algae)[1].rhs == rule1.rhs && rules(algae)[2].rhs == rule2.rhs
    @test length(algae) == 1
    @test PlantGraphs.root_id(algae) == PlantGraphs.insertion_id(algae)
    @test length(PlantGraphs.nodetypes(algae)) == 1

    # Match the rules against the graph
    PlantGraphs.match_rules!(algae, algae.rules)
    # Execute the rules
    PlantGraphs.execute!(algae, algae.rules[1])

    # Check that rewrite did what was expected (node: only one rule is executed)
    @test length(algae) == 2
    @test length(PlantGraphs.nodetypes(algae)) == 2
    @test PlantGraphs.root_id(algae) != PlantGraphs.insertion_id(algae)
    @test PlantGraphs.getroot(algae).data isa GT.A
    @test PlantGraphs.insertion(algae).data isa GT.B

    # Execute the rules a second time (make sure both rules are executed)
    rewrite!(algae)

    # Check the growth of the graph and the right order of nodes
    @test length(algae) == 3
    @test PlantGraphs.getroot(algae).data isa GT.A
    @test PlantGraphs.insertion(algae).data isa GT.A
end
