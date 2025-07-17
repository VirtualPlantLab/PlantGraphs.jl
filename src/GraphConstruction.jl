### This file contains public API ###

################################################################################
################  Add/Append methods for graph construction  ###################
################################################################################


"""
    add!(g::StaticGraph, N::GraphNode)

Add a new node to a static graph, automatically generating a unique ID for the node.

## Arguments
- `g::StaticGraph`: The static graph to which the node will be added.
- `N::GraphNode`: The node to add to the graph.

## Returns
The unique ID assigned to the newly added node.
"""
function add!(g::StaticGraph, N::GraphNode)
    ID = generate_id()
    g[ID] = N
    return ID
end


"""
    append!(g::StaticGraph, ID, n::GraphNode)

Append a node to a specified node in a static graph.

## Arguments
- `g::StaticGraph`: The static graph to which the node will be appended.
- `ID`: The ID of the node to which the new node will be appended as a child.
- `n::GraphNode`: The node to append to the graph.

## Returns
The unique ID assigned to the newly appended node.
"""
function Base.append!(g::StaticGraph, ID, n::GraphNode)
    nID = add!(g, n)
    add_child!(g[ID], nID)
    set_parent!(g[nID], ID)
    return nID
end


"""
    append!(g::StaticGraph, ID, gn::StaticGraph)

Append a static graph to a specified node in another static graph. The insertion point of 
the final graph is the insertion point of the appended graph.

## Arguments
- `g::StaticGraph`: The static graph to which the other graph will be appended.
- `ID`: The ID of the node to which the root of the appended graph will be added as a child.
- `gn::StaticGraph`: The static graph to append.

## Returns
The ID of the insertion point of the appended graph.
"""
function Base.append!(g::StaticGraph, ID, gn::StaticGraph)
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


"""
    +(n1::GraphNode, n2::GraphNode)

Create a static graph with two nodes, where `n1` is the root and `n2` is appended as a 
child at the insertion point.

## Arguments
- `n1::GraphNode`: The node to use as the root of the graph.
- `n2::GraphNode`: The node to append to the root node.

## Returns
A `StaticGraph` object with `n1` as the root and `n2` as the insertion point.
"""
function Base.:+(n1::GraphNode, n2::GraphNode)
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
julia> struct A1 <: Node val::Int end;

julia> struct B1 <: Node val::Int end;

julia> axiom = A1(1) + B1(1);

julia> import CairoMakie; # or GLMakie, WGLMakie, etc.

julia> draw(axiom);
```
"""
Base.:+(n1::Node, n2::Node) = GraphNode(n1) + GraphNode(n2)

function Base.:+(g::StaticGraph, n::GraphNode)
    nID = append!(g, insertion_id(g), n)
    update_insertion!(g, nID)
    return g
end

"""
    +(g::StaticGraph, n::Node)

Creates a graph as the result of appending the node `n` to the insertion point of graph `g`.

## Examples
```jldoctest
julia> struct A1 <: Node val::Int end;

julia> struct B1 <: Node val::Int end;

julia> axiom = A1(1) + B1(1);

julia> axiom = axiom + A1(2);

julia> import CairoMakie; # or GLMakie, WGLMakie, etc.

julia> draw(axiom);
```
"""
Base.:+(g::StaticGraph, n::Node) = g + GraphNode(n)

"""
    +(n::Node, g::StaticGraph)

Creates a graph as the result of appending the static graph `g` to the node `n`.

## Examples
```jldoctest
julia> struct A1 <: Node val::Int end;

julia> struct B1 <: Node val::Int end;

julia> axiom = A1(1) + B1(1);

julia> axiom = A1(2) + axiom;

julia> import CairoMakie; # or GLMakie, WGLMakie, etc.

julia> draw(axiom);
```
"""
Base.:+(n::Node, g::StaticGraph) = GraphNode(n) + g
Base.:+(n::GraphNode, g::StaticGraph) = StaticGraph(n) + g

"""
    +(g1::StaticGraph, g2::StaticGraph)

Creates a graph as the result of appending `g2` to the insertion point of `g1`.
The insertion point of the final graph corresponds to the insertion point of `g2`.

## Examples
```jldoctest
julia> struct A1 <: Node val::Int end;

julia> struct B1 <: Node val::Int end;

julia> axiom1 = A1(1) + B1(1);

julia> axiom2 = A1(2) + B1(2);

julia> axiom = axiom1 + axiom2;

julia> import CairoMakie; # or GLMakie, WGLMakie, etc.

julia> draw(axiom);
```
"""
function Base.:+(g1::StaticGraph, g2::StaticGraph)
    nID = append!(g1, insertion_id(g1), g2)
    update_insertion!(g1, insertion_id(g2))
    return g1
end


"""
    +(g::StaticGraph, T::Tuple)

Creates a graph as the result of appending a tuple of graphs or nodes `T` to the insertion point of the static graph `g`. Each element in the tuple becomes a branch.

## Arguments
- `g::StaticGraph`: The static graph to which the tuple will be appended.
- `T::Tuple`: A tuple of graphs or nodes to append as branches.

## Returns
The modified `StaticGraph` with all elements of the tuple appended as branches.
"""
@unroll function Base.:+(g::StaticGraph, T::Tuple)
    ins = insertion_id(g)
    @unroll for el in T
        g += el
        update_insertion!(g, ins)
    end
    return g
end



"""
    +(n::GraphNode, T::Tuple)

Creates a static graph as the result of appending a tuple of graphs or nodes `T` to the insertion point of the graph rooted at `n`. Each element in the tuple becomes a branch.

## Arguments
- `n::GraphNode`: The node to use as the root of the graph.
- `T::Tuple`: A tuple of graphs or nodes to append as branches.

## Returns
A `StaticGraph` with `n` as the root and all elements of the tuple appended as branches.
"""
Base.:+(n::GraphNode, T::Tuple) = StaticGraph(n) + T

"""
    +(g::StaticGraph, T::Tuple)
    +(n::Node, T::Tuple)

Creates a graph as the result of appending a tuple of graphs/nodes `T` to the
insertion point of the graph `g` or node `n`. Each graph/node in `L` becomes a
branch.

## Examples
```jldoctest
julia> struct A1 <: Node val::Int end;

julia> struct B1 <: Node val::Int end;

julia> axiom = A1(1) + (B1(1) + A1(3), B1(4));

julia> import CairoMakie; # or GLMakie, WGLMakie, etc.

julia> draw(axiom);
```
"""
Base.:+(n::Node, T::Tuple) = GraphNode(n) + T
