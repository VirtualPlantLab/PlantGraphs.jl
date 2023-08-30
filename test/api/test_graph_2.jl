using PlantGraphs
using Test
include("types.jl")
import .GT

let

    # Cell transfer top to bottom
    function transfer(context)
        if has_parent(context)
            return (true, (parent(context),))
        else
            return (false, ())
        end
    end

    rule = Rule(GT.Cell{Int}, lhs = transfer,
                rhs = (context, father) -> GT.Cell(data(father).state), captures = true)
    @test PlantGraphs.captures(rule)

    axiom = GT.Cell(1) + GT.Cell(0) + GT.Cell(0)
    pop = Graph(axiom = axiom, rules = rule)

    getStates(pop) = [data(n).state for n in values(PlantGraphs.nodes(pop))]
    @test sum(getStates(pop)) == 1
    rewrite!(pop)
    @test sum(getStates(pop)) == 2
    rewrite!(pop)
    @test getStates(pop) == [1, 1, 1]

    # Cell transfer bottom to top
    function transferUp(context)
        if haschildren(context)
            child = first(children(context))
            return (true, (child,))
        else
            return (false, ())
        end
    end

    ruleUp = Rule(GT.Cell{Int}, lhs = transferUp,
                  rhs = (context, child) -> GT.Cell(data(child).state), captures = true)

    axiomUp = GT.Cell(0) + GT.Cell(0) + GT.Cell(1)
    pop = Graph(axiom = axiomUp, rules = ruleUp)

    @test sum(getStates(pop)) == 1
    rewrite!(pop)
    @test sum(getStates(pop)) == 2
    rewrite!(pop)
    @test getStates(pop) == [1, 1, 1]
end
