### This file contains public API ###

################################################################################
############################  StaticGraph traversal  ###########################
################################################################################

"""
    traverse(g::Graph; fun = () -> nothing)

Iterates over all the nodes in the graph and execute for the function `fun` on
each node

## Arguments
- `g::Graph`: The graph object that will be traversed.

## Keywords
- `fun`: A function or function-like object defined by the user that will be
applied to each node.

## Details
This traveral happens in the order in which the nodes are stored in the graph.
This order is arbitrary and may vary across executions of the code (it does not
correspond to the order in which nodes are created). For algorithms that require
a particular traveral order of the graph, see `traverse_dfs` and `traverse_bfs`.

This function does not store any results generated by `fun`. Hence, if the user
wants to keep track of such results, they should be stored indirectly (e.g., via
a global variable or internally by creating a functor).

The function or function-like object provided by the user should take only one
argument that corresponds to applying `data()` to each node in the graph. Several
methods of such function may be defined for different types of nodes in the
graph. Since the function will use the data stored in the nodes, relations among
nodes may not be used as input. For algorithms where relations among nodes are
important, the user should be using queries instead (see `Query` and general VPL
documentation).

## Returns
This function returns nothing but `fun` may have side-effects.

## Examples
```jldoctest
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    struct Foo
        vals::Vector{Int}
    end
    function (f::Foo)(x)
        push!(f.vals, x.val)
    end
    f = Foo(Int[])
    axiom = A1(2) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    traverse(g, fun = f)
    f.vals
end
```
"""
function traverse(g::Graph; fun = () -> nothing, order = "any", ID = root(g))
    traverse(static_graph(g), fun = fun, order = order, ID = ID)
end
function traverse(g::StaticGraph; fun = () -> nothing, order = "any", ID = root(g))
    if order == "any"
    for val in values(nodes(g))
        fun(data(val))
        end
    elseif order == "dfs"
        traverse_dfs(g::Graph; fun = fun, ID = ID)
    elseif order == "bfs"
        traverse_bfs(g::Graph; fun = fun, ID = ID)
    end
    return nothing
end

"""
    traverse_dfs(g::Graph; fun = () -> nothing, ID = root(g))

Iterates over all the nodes in the graph (depth-first order, starting at a any
node) and execute for the function `fun` on each node

## Arguments
- `g::Graph`: The graph object that will be traversed.

## Keywords
- `fun`: A function or function-like object defined by the user that will be
applied to each node.
- `ID`: The ID of the node where the traveral should start. This argument is
assigned by keyword and is, by default, the root of the graph.

## Details
This traveral happens in a depth-first order. That is, all nodes in a branch of
the graph are visited until reach a leaf node, then moving to the next branch.
Hence, this algorithm should always generate the same result when applied to the
same graph (assuming the user-defined function is not stochastic). For a version
of this function that us breadth-first order see `traverse_bfs`.

This function does not store any results generated by `fun`. Hence, if the user
wants to keep track of such results, they should be stored indirectly (e.g., via
a global variable or internally by creating a functor).

The function or function-like object provided by the user should take only one
argument that corresponds to applying `data()` to each node in the graph. Several
methods of such function may be defined for different types of nodes in the
graph. Since the function will use the data stored in the nodes, relations among
nodes may not be used as input. For algorithms where relations among nodes are
important, the user should be using queries instead (see `Query` and general VPL
documentation).

## Returns
This function returns nothing but `fun` may have side-effects.

## Examples
```jldoctest
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    struct Foo
        vals::Vector{Int}
    end
    function (f::Foo)(x)
        push!(f.vals, x.val)
    end
    f = Foo(Int[])
    axiom = A1(2) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    traverse_dfs(g, fun = f)
    f.vals
end
```
"""
traverse_dfs(g::Graph; fun = () -> nothing, ID = root(g)) = traverse_dfs(static_graph(g), fun, ID)

function traverse_dfs(g::StaticGraph, fun, ID)
    # Use LIFO stack to keep track of nodes in traversal
    node_stack = Int[]
    push!(node_stack, ID)
    # Iterate over all nodes in the graph
    while (length(node_stack) > 0)
        # Always execute f on the last node added
        ID = pop!(node_stack)
        fun(data(g[ID]))
        # Add the children to the stack (if any)
        for child_id in children_id(g[ID])
            push!(node_stack, child_id)
        end
    end
    return nothing
end

"""
    traverse_bfs(g::Graph; fun = () -> nothing, ID = root(g))

Iterates over all the nodes in the graph (breadth-first order, starting at a any
node) and execute for the function `fun` on each node

## Arguments
- `g::Graph`: The graph object that will be traversed.

## Keywords
- `fun`: A function or function-like object defined by the user that will be
applied to each node.
- `ID`: The ID of the node where the traveral should start. This argument is, by default,
the root of the graph.

## Details
This traveral happens in a breadth-first order. That is, all nodes at a given
depth of the the graph are visited first, then moving on to the next level.
Hence, this algorithm should always generate the same result when applied to the
same graph (assuming the user-defined function is not stochastic). For a version
of this function that us depth-first order see `traverse_dfs`.

This function does not store any results generated by `fun`. Hence, if the user
wants to keep track of such results, they should be stored indirectly (e.g., via
a global variable or internally by creating a functor).

The function or function-like object provided by the user should take only one
argument that corresponds to applying `data()` to each node in the graph. Several
methods of such function may be defined for different types of nodes in the
graph. Since the function will use the data stored in the nodes, relations among
nodes may not be used as input. For algorithms where relations among nodes are
important, the user should be using queries instead (see `Query` and general VPL
documentation).

## Returns
This function returns nothing but `fun` may have side-effects.

## Examples
```jldoctest
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    struct Foo
        vals::Vector{Int}
    end
    function (f::Foo)(x)
        push!(f.vals, x.val)
    end
    f = Foo(Int[])
    axiom = A1(2) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    traverse_bfs(g, fun = f)
    f.vals
end
```
"""
traverse_bfs(g::Graph; fun = () -> nothing, ID = root(g)) = traverse_bfs(static_graph(g), fun, ID)

function traverse_bfs(g::StaticGraph, fun, ID)
    # Use LIFO stack to keep track of nodes in traversal
    node_stack = Int[]
    prepend!(node_stack, ID)
    # Iterate over all nodes in the graph
    while (length(node_stack) > 0)
        # Always execute f on the last node added
        ID = pop!(node_stack)
        fun(data(g[ID]))
        # Add the children to the stack (if any)
        for child_id in children_id(g[ID])
            prepend!(node_stack, child_id)
        end
    end
    return nothing
end
