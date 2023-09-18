### This file contains public API ###

################################################################################
###########################  Graph constructors  ###############################
################################################################################

"""
    Graph(;axiom, rules = nothing, data = nothing)

Create a dynamic graph from an axiom, one or more rules and, optionally,
graph-level variables.

## Arguments
- `axiom`: A single object inheriting from `Node` or a subgraph generated  with
the graph construction DSL. It should represent the initial state of the dynamic
graph.

## Keywords
- `rules`:  A single `Rule` object or a tuple of `Rule` objects (optional). It
should include all graph-rewriting rules of the graph.
- `data`: A single object of any user-defined type (optional). This will be the
graph-level variable accessible from any rule or query applied to the graph.
- `FT`: Floating-point precision to be used when generating the 3D geometry
associated to a graph.

## Details
All arguments are assigned by keyword. The axiom and rules are deep-copied when
creating the graph but the graph-level variables (if a copy is needed due to
mutability, the user needs to care of that).

## Returns
An object of type `Graph` representing a dynamic graph. Printing this object
results in a human-readable description of the type of data stored in the graph.

## Examples
```jldoctest
julia> let
           struct A0 <: Node end
           struct B0 <: Node end
           axiom = A0() + B0()
           no_rules_graph = Graph(axiom = axiom)
           rule = Rule(A0, rhs = x -> A0() + B0())
           rules_graph = Graph(axiom = axiom, rules = rule)
       end
Dynamic graph with 2 nodes of types A0,B0 and 1 rewriting rules.
```
"""
function Graph(; axiom::Union{StaticGraph, Node},
    rules::Union{Nothing, Tuple, Rule} = nothing,
    data = nothing)
    if rules isa Nothing
        out = Graph(StaticGraph(deepcopy(axiom)), (), deepcopy(data))
    else
        out = Graph(StaticGraph(deepcopy(axiom)), deepcopy(Tuple(rules)), deepcopy(data))
    end
    return out
end

################################################################################
##############################  Properties  ###############################
################################################################################

"""
    rules(g::Graph)

Returns a tuple with all the graph-rewriting rules stored in a dynamic graph

## Examples
```jldoctest
julia> struct A <: Node end


julia> struct B <: Node end


julia> axiom = A() + B();

julia> rule = Rule(A, rhs = x -> A() + B())
Rule replacing nodes of type A without context capturing.

julia> rules_graph = Graph(axiom = axiom, rules = rule)
Dynamic graph with 2 nodes of types A,B and 1 rewriting rules.

julia> rules(rules_graph)
(Rule replacing nodes of type A without context capturing.
,)
```
"""
rules(g::Graph) = g.rules

"""
  data(g::Graph)

Returns the graph-level variables.

## Example
```jldoctest
julia> struct A <: Node end


julia> axiom = A()
A()

julia> g = Graph(axiom = axiom, data = 2)
Dynamic graph with 1 nodes of types A and 0 rewriting rules.
Dynamic graph variables stored in struct of type Int64

julia> data(g)
2
```
"""
data(g::Graph) = g.data

#=
Returns the StaticGraph stored inside the Graph object (users are not supposed
to interact directly with the StaticGraph)
=#
static_graph(g::Graph) = g.graph

################################################################################
##############################  Show methods  ##################################
################################################################################

#=
  Print humand-friendly description of a Graph. Users will not call this one
  explictly, it is used by Julia to determine what happens when the object is
  printed.
=#
function show(io::IO, g::Graph)
    nrules = length(g.rules)
    nnodes = length(g.graph)
    nodetypes = collect(keys(g.graph.nodetypes))
    data = typeof(g.data)
    println(io, "Dynamic graph with ", nnodes, " nodes of types ", join(nodetypes, ','),
        " and ", nrules, " rewriting rules.")
    if data != Nothing
        println(io, "Dynamic graph variables stored in struct of type ", data)
    end
    return nothing
end

################################################################################
##############################  Forward methods  ###############################
################################################################################

# Forward several methods from StaticGraph to Graph
macro forwardgraph(method)
    esc(:($method(g::Graph) = $method(static_graph(g))))
end

@forwardgraph length
@forwardgraph nodetypes
@forwardgraph root_id
@forwardgraph getroot
@forwardgraph insertion_id
@forwardgraph insertion
@forwardgraph nodes
@forwardgraph empty!

getindex(g::Graph, ID::Int) = getindex(static_graph(g), ID)
children(n::GraphNode, g::Graph) = children(n, static_graph(g))
