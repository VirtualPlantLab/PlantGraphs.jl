### This file contains public API ###

################################################################################
################  Add/Append methods for graph construction  ###################
################################################################################

#=
Add a new node to the graph (an unique ID is automatically created).
=#
function add!(g::StaticGraph, N::GraphNode)
    ID = generate_id()
    g[ID] = N
    return ID
end

#=
Append a node to the node ID in a graph
=#
function append!(g::StaticGraph, ID, n::GraphNode)
    nID = add!(g, n)
    add_child!(g[ID], nID)
    set_parent!(g[nID], ID)
    return nID
end

#=
Append a graph to the node ID in a graph. The insertion point of the final graph
is the insertion point of the appended graph
=#
function append!(g::StaticGraph, ID, gn::StaticGraph)
    # Transfer nodes to the receiving graph
    for (key, val) in nodes(gn)
        g[key] = val
    end
    add_child!(g[ID], root_id(gn))
    set_parent!(g[root_id(gn)], ID)
    out = insertion_id(gn)
    return out
end

################################################################################
#######################  StaticGraph construction DSL  ###############################
################################################################################

function +(n1::GraphNode, n2::GraphNode)
    g = StaticGraph(n1)
    nID = append!(g, insertion_id(g), n2)
    update_insertion!(g, nID)
    return g
end

"""
    +(n1::Node, n2::Node)

Creates a graph with two nodes where `n1` is the root and `n2` is the insertion point.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(1) + B1(1)
           import GLMakie # or CairoMakie, WGLMakie, etc.
           draw(axiom)
       end
Figure()
```
"""
+(n1::Node, n2::Node) = GraphNode(n1) + GraphNode(n2)

function +(g::StaticGraph, n::GraphNode)
    nID = append!(g, insertion_id(g), n)
    update_insertion!(g, nID)
    return g
end

"""
    +(g::StaticGraph, n::Node)

Creates a graph as the result of appending the node `n` to the insertion point of graph `g`.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(1) + B1(1)
           axiom = axiom + A1(2)
           import GLMakie # or CairoMakie, WGLMakie, etc.
           draw(axiom)
       end
Figure()
```
"""
+(g::StaticGraph, n::Node) = g + GraphNode(n)

"""
    +(n::Node, g::StaticGraph)

Creates a graph as the result of appending the static graph `g` to the node `n`.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(1) + B1(1)
           axiom = A1(2) + axiom
           import GLMakie # or CairoMakie, WGLMakie, etc.
           draw(axiom)
       end
Figure()
```
"""
+(n::Node, g::StaticGraph) = GraphNode(n) + g
+(n::GraphNode, g::StaticGraph) = StaticGraph(n) + g

"""
    +(g1::StaticGraph, g2::StaticGraph)

Creates a graph as the result of appending `g2` to the insertion point of `g1`.
The insertion point of the final graph corresponds to the insertion point of `g2`.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom1 = A1(1) + B1(1)
           axiom2 = A1(2) + B1(2)
           axiom = axiom1 + axiom2
           import GLMakie # or CairoMakie, WGLMakie, etc.
           draw(axiom)
       end
Figure()
```
"""
function +(g1::StaticGraph, g2::StaticGraph)
    nID = append!(g1, insertion_id(g1), g2)
    update_insertion!(g1, insertion_id(g2))
    return g1
end

@unroll function +(g::StaticGraph, T::Tuple)
    ins = insertion_id(g)
    @unroll for el in T
        g += el
        update_insertion!(g, ins)
    end
    return g
end

+(n::GraphNode, T::Tuple) = StaticGraph(n) + T

"""
    +(g::StaticGraph, T::Tuple)
    +(n::Node, T::Tuple)

Creates a graph as the result of appending a tuple of graphs/nodes `T` to the
insertion point of the graph `g` or node `n`. Each graph/node in `L` becomes a
branch.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(1) + (B1(1) + A1(3), B1(4))
           import GLMakie # or CairoMakie, WGLMakie, etc.
           draw(axiom)
       end
Figure()
```
"""
+(n::Node, T::Tuple) = GraphNode(n) + T
