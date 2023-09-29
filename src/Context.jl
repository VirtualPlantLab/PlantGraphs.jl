### This file contains public API ###

################################################################################
################################## Getters #####################################
################################################################################

# Return the node stored in the context (a GraphNode)
node(c::Context) = c.node

"""
    data(c::Context)

Returns the data stored in a node. Intended to be used within a rule or query.
"""
data(c::Context) = data(node(c))

# Return the Graph stored inside the Context object
graph(c::Context) = c.graph

"""
    graph_data(c::Context)

Returns the graph-level variables. Intended to be used within a rule or query.
"""
graph_data(c::Context) = data(graph(c))

# This is needed to traverse graphs within rules
id(c::Context) = self_id(node(c))

################################################################################
################################## Queries #####################################
################################################################################

"""
    has_parent(c::Context)

Check if a node has a parent and return `true` or `false`. Intended to be used
within a rule or query.
"""
has_parent(c::Context) = has_parent(node(c))

isroot(c::Context) = !has_parent(c)

"""
    is_root(c::Context)


Check if a node is the root of the graph (i.e., has no parent) and return `true` or
`false`. Intended to be used within a rule or query.

`isroot` is an alias for `is_root` for compatibility with AbstractTrees.jl
"""
const is_root = isroot

"""
    has_ancestor(c::Context; condition = x -> true, max_level::Int = typemax(Int))

Check if a node has an ancestor that matches the condition. Intended to be used within
a rule or query.

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.

## Keywords
- `condition`: An user-defined function that takes a `Context` object as input
and returns `true` or `false`.
- `max_level::Int`: Maximum number of steps that the algorithm may take when
traversing the graph.

## Details
This function traverses the graph from the node associated to `c` towards the
root of the graph until a node is found for which `condition` returns `true`. If
no node meets the condition, then it will return `false`. The defaults values
for this function are such that the algorithm always returns `true`
after one step (unless it is applied to the root node) in which case it is
equivalent to calling `has_parent` on the node.

The number of levels that the algorithm is allowed to traverse is capped by
`max_level` (mostly to avoid excessive computation, though the user may want to
specify a meaningful limit based on the topology of the graphs being used).

The function `condition` should take an object of type `Context` as input and
return `true` or `false`.

## Returns
Return a tuple with two values a `Bool` and an `Int`, the boolean indicating
whether the node has an ancestor meeting the condition, the integer indicating
the number of levels in the graph separating the node an its ancestor.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(2) + (B1(1) + A1(3), B1(4))
           g = Graph(axiom = axiom)
               function qfun(n)
               has_ancestor(n, condition = x -> data(x).val == 1)[1]
           end
           Q1 = Query(A1, condition = qfun)
           R1 = apply(g, Q1)
               Q2 = Query(B1, condition = qfun)
           R2 = apply(g, Q2)
           (R1,R2)
       end
(A1[A1(3)], B1[])
```
"""
function has_ancestor(c::Context; condition = x -> true, max_level::Int = typemax(Int))
    out = has_ancestor(node(c), graph(c), condition, max_level, 1)
    return out
end

"""
    has_children(c::Context)

Check if a node has at least one child and return `true` or `false`. Intended to be used
within a rule or query.
"""
has_children(c::Context) = has_children(node(c))

"""
    is_leaf(c::Context)

Check if a node is a leaf in the graph (i.e., has no children) and return `true` or
`false`. Intended to be used within a rule or query.
"""
is_leaf(c::Context) = !has_children(c)

"""
    has_descendant(c::Context; condition = x -> true, max_level::Int = typemax(Int))

Check if a node has a descendant that matches the optional condition. Intended to be used
within a rule or query.

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.

## Keywords
- `condition`: An user-defined function that takes a `Context` object as input
and returns `true` or `false`.
- `max_level::Int`: Maximum number of steps that the algorithm may take when
traversing the graph.

## Details
This function traverses the graph from the node associated to `c` towards the
leaves of the graph until a node is found for which `condition` returns `true`.
If no node meets the condition, then it will return `false`. The defaults values
for this function are such that the algorithm always returns `true`
after one step (unless it is applied to a leaf node) in which case it is
equivalent to calling `has_children` on the node.

The number of levels that the algorithm is allowed to traverse is capped by
`max_level` (mostly to avoid excessive computation, though the user may want to
specify a meaningful limit based on the topology of the graphs being used).

The function `condition` should take an object of type `Context` as input and
return `true` or `false`.

## Returns
Return a tuple with two values a `Bool` and an `Int`, the boolean indicating
whether the node has an ancestor meeting the condition, the integer indicating
the number of levels in the graph separating the node an its ancestor.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(2) + (B1(1) + A1(3), B1(4))
           g = Graph(axiom = axiom)
               function qfun(n)
               has_descendant(n, condition = x -> data(x).val == 1)[1]
           end
           Q1 = Query(A1, condition = qfun)
           R1 = apply(g, Q1)
           Q2 = Query(B1, condition = qfun)
           R2 = apply(g, Q2)
           (R1,R2)
       end
(A1[A1(2)], B1[])
```
"""
function has_descendant(c::Context; condition = x -> true, max_level::Int = typemax(Int))
    out = has_descendant(node(c), graph(c), condition, max_level, 1)
    return out
end

################################################################################
################################## Retrieve ####################################
################################################################################

"""
    parent(c::Context; nsteps::Int)

Returns the parent of a node that is `nsteps` away towards the root of the graph.
Intended to be used within a rule or query.

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.

## Keywords
- `nsteps`: Number of steps to traverse the graph towards the root node.

## Details
If `has_parent()` returns `false` for the same node or the algorithm has reached
the root node but `nsteps` have not been reached, then `parent()` will return
`missing`, otherwise it returns the `Context` associated to the matching node.

## Return
Return a `Context` object or `missing`.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(2) + (B1(1) + A1(3), B1(4))
           g = Graph(axiom = axiom)
               function qfun(n)
               np = parent(n, nsteps = 2)
               !ismissing(np) && data(np).val == 2
           end
           Q1 = Query(A1, condition = qfun)
           R1 = apply(g, Q1)
           Q2 = Query(B1, condition = qfun)
           R2 = apply(g, Q2)
           (R1,R2)
       end
(A1[A1(3)], B1[])
```
"""
function parent(c::Context; nsteps::Int = 1)
    parent_node = parent(node(c), graph(c), nsteps)
    ismissing(parent_node) && return missing
    out = Context(graph(c), parent_node)
    return out
end

"""
    ancestor(c::Context; condition = x -> true, max_level::Int = typemax(Int))

Returns the first ancestor of a node that matches the `condition`. Intended to be
used within a rule or query.

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.

## Keywords
- `condition`: An user-defined function that takes a `Context` object as input
and returns `true` or `false`.
- `max_level::Int`: Maximum number of steps that the algorithm may take when
traversing the graph.

## Details
If `has_ancestor()` returns `false` for the same node and `condition`, `ancestor()`
will return `missing`, otherwise it returns the `Context` associated to the
matching node

## Returns
Return a `Context` object or `missing`.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(1) + (B1(1) + A1(3), B1(4))
           g = Graph(axiom = axiom)
               function qfun(n)
               na = ancestor(n, condition = x -> (data(x).val == 1))
               if !ismissing(na)
                   data(na) isa B1
               else
                   false
               end
           end
           Q1 = Query(A1, condition = qfun)
           R1 = apply(g, Q1)
           Q2 = Query(B1, condition = qfun)
           R2 = apply(g, Q2)
           (R1,R2)
       end
(A1[A1(3)], B1[])
```
"""
function ancestor(c::Context; condition = x -> true, max_level::Int = typemax(Int))
    anc = ancestor(node(c), graph(c), condition, max_level, 1)
    ismissing(anc) && return missing
    out = Context(graph(c), anc)
    return out
end

"""
    children(c::Context)

Returns all the children of a node as `Context` objects.
"""
function children(c::Context)
    out = Tuple(Context(graph(c), child) for child in children(node(c), graph(c)))
    return out
end

function getdescendant(c::Context; condition = x -> true, max_level::Int = typemax(Int))
    desc = getdescendant(node(c), graph(c), condition, max_level, 1)
    ismissing(desc) && return missing
    out = Context(graph(c), desc)
    return out
end

"""
    get_descendant(c::Context; condition = x -> true, max_level::Int = typemax(Int))

Returns the first descendant of a node that matches the `condition`. Intended to
be used within a rule or query.

`getdescendant` is an alias for `get_descendant` for compatibility with AbstractTrees.jl

## Arguments
- `c::Context`: Context associated to a node in a dynamic graph.

## Keywords
- `condition`: An user-defined function that takes a `Context` object as input
and returns `true` or `false`.
- `max_level::Int`: Maximum number of steps that the algorithm may take when
traversing the graph.

## Details
If `has_descendant()` returns `false` for the same node and `condition`,
`get_descendant()` will return `missing`, otherwise it returns the `Context`
associated to the matching node.

## Return
Return a `Context` object or `missing`.

## Examples
```jldoctest
julia> let
           struct A1 <: Node val::Int end
           struct B1 <: Node val::Int end
           axiom = A1(1) + (B1(1) + A1(3), B1(4))
           g = Graph(axiom = axiom)
               function qfun(n)
               na = get_descendant(n, condition = x -> (data(x).val == 1))
               if !ismissing(na)
                   data(na) isa B1
               else
                   false
               end
           end
           Q1 = Query(A1, condition = qfun)
           R1 = apply(g, Q1)
           Q2 = Query(B1, condition = qfun)
           R2 = apply(g, Q2)
           (R1,R2)
       end
(A1[A1(1)], B1[])
```
"""
const get_descendant = getdescendant
