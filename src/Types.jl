### This file contains public API ###

"""
    Node

Abstract type from which every node in a graph should inherit. This allows using
the graph construction DSL.

This type is mutable.

## Example
```jldoctest
julia> struct bar <: Node
           x::Int
       end;

julia> b1 = bar(1);

julia> b2 = bar(2);

julia> b1 + b2;
```
"""
abstract type Node end


"""
    GraphNode

Data structure that wraps the contents of a node and includes references to the
ids of the parent and children node and the node itself. Users do not build `GraphNode`
objects directly, this is always handled by VPL when creating or modifying a graph.

This type is mutable. All fields can be accessed through methods with the same name as the
field.

## Fields
- `data`: Data stored in the node, which should inherit from `Node` (i.e., the object the
            user creates).
- `children_id::OrderedSet{Int}`: Ids of the children nodes.
- `parent_id::Union{Int, Missing}`: Id of the parent node. If the node is a root node, this is `missing`.
- `self_id::Int`: Id of this node.
"""
mutable struct GraphNode{T <: Node}
    data::T
    children_id::OC.OrderedSet{Int}
    parent_id::Union{Int, Missing}
    self_id::Int
end


"""
    StaticGraph

Data structure that stores the nodes in a graph and their relationships. Each node is
assigned a unique id which corresponds to the key in a Dictionary. Each node is of type
`GraphNode`, which contains the data stored in the node, as well as references to its
parent and children nodes. A `StaticGraph` is combined with a set of rules and data to
form a `Graph` object, which is the main data structure used in VPL. Users will generally
not interact with `StaticGraph` objects directly, as they are created by VPL through the
graph construction DSL.

This type is mutable. The fields can be accessed through methods with the same name as the
field except for `root` where `getroot()` or `get_root()` should be used.

## Fields
- `nodes::OrderedDict{Int, GraphNode}`: Dictionary mapping node ids to `GraphNode` objects.
- `nodetypes::OrderedDict{DataType, OrderedSet{Int}}`: Dictionary mapping node types to sets of node ids.
- `root::Int`: Id of the root node in the graph.
- `insertion::Int`: Id of the last node added to the graph.
"""

mutable struct StaticGraph
    nodes::OC.OrderedDict{Int, GraphNode}
    nodetypes::OC.OrderedDict{DataType, OC.OrderedSet{Int}}
    root::Int
    insertion::Int
end

# Docstring is included in the constructor in Graph.jl
#=
  Data structure to store a graph plus rules to rewrite it and graph-level variables
  All rules are stored in a dictionary which keys are the unique identifiers of the rules
  The field data contains a struct with variables that are accesible in queries and production rules
=#
mutable struct Graph{D, S <: Tuple}
    graph::StaticGraph
    rules::S
    data::D
end

# Docstring is included in the constructor in Rule.jl
#=
  Data structure to store a node replacement rule for graph rewriting.
  N is the type of node to be replaced
=#
mutable struct Rule{N, C, LHST, RHST}
    lhs::LHST
    rhs::RHST
    matched::Vector{Int}
    contexts::Vector{Tuple}
end

# Docstring is included in the constructor in Query.jl
#=
  Data structure to store a graph query
=#
struct Query{N, Q}
    query::Q
end

"""
    Context

Data structure than links a node to the rest of the graph.

## Fields
- `graph`: Dynamic graph that contains the node.
- `node`: Node inside the graph.

## Details
A `Context` object wraps references to a node and its associated graph. The
purpose of this structure is to be able to test relationships among nodes within
a graph (from with a query or rule), as well as access the data stored in a node
(with `data()`) or the graph (with `graph_data()`).

Users do not build `Context` objects directly but they are provided by VPL as
inputs to the user-defined functions inside rules and queries.
"""
mutable struct Context{N <: GraphNode, G <: Graph}
    graph::G
    node::N
end
