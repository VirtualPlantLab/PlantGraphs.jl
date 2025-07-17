### This file contains public API ###

#=
 Generate unique IDs for Nodes in graphs to avoid ID clashes when merging graphs
 This should be done in a thread-safe manner.
 This is required because graphs are created on right hand side of rules and then
 appended to an existing graph
=#
let ID = Threads.Atomic{Int}(0)
    global generate_id
    global reset_id!
    global get_id!
    global set_id!

    @doc """
        generate_id()

    Generate a new unique ID for a node in a graph and update the ID counter.

    ## Returns
    The new unique ID (an atomic `Int`).
    """
    generate_id() = Threads.atomic_add!(ID, 1) + 1

    @doc """
        reset_id!()

    Reset the ID counter for generating unique IDs for nodes in graphs to zero.

    ## Returns
    The new value of the ID counter (an atomic `Int`).
    """
    function reset_id!()
        set_id!(0)
    end

    @doc """
        get_id!()

    Get the current value of the ID counter for generating unique IDs for nodes in graphs.

    ## Returns
    The current value of the ID counter (an atomic `Int`).
    """
    get_id!() = ID

    @doc """
        set_id!(id)

    Set the ID counter for generating unique IDs for nodes in graphs to any integer value
    `id`.

    ## Returns
    The new value of the ID counter (an atomic `Int`).
    """
    function set_id!(id)
        ID = Threads.Atomic{Int}(id)
    end


end

################################################################################
########################  StaticGraph constructors  ############################
################################################################################

#=
    Facilitate construction of static graphs without having to use the DSL
=#
"""
    StaticGraph()

Generate an empty `StaticGraph` object.

Users will generally not use this method as they will normally deal with `Graph` objects
rather than `StaticGraph` directly.

## Returns
An empty `StaticGraph` object with no nodes, nodetypes, and both root and insertion IDs set to -1.
"""
function StaticGraph()
    StaticGraph(OC.OrderedDict{Int, GraphNode}(),
        OC.OrderedDict{DataType, OC.OrderedSet{Int}}(),
        -1,
        -1)
end

"""
    StaticGraph(n::GraphNode)

Create a `StaticGraph` from a single `GraphNode`. This is useful for initializing a graph with a root node.

Users will generally not use this method as they will normally deal with `Graph` objects
rather than `StaticGraph` directly.

## Arguments
- `n::GraphNode`: The `GraphNode` to be used as the root of the graph.

## Returns
A `StaticGraph` object containing the node.
"""
function StaticGraph(n::GraphNode)
    ID = generate_id()
    change_id!(n, ID)
    nlocal = copy(n)
    g = StaticGraph(OC.OrderedDict{Int, GraphNode}(ID => nlocal),
        OC.OrderedDict(typeof(nlocal.data) => OC.OrderedSet{Int}(ID)),
        ID, ID)
    return g
end

"""
    StaticGraph(n::Node)

Create a `StaticGraph` from a single object that inherits from `Node`.

Users will generally not use this method as they will normally deal with `Graph` objects
rather than `StaticGraph` directly.

## Arguments
- `n::Node`: The object that inherits from `Node` to be used as the root of the graph.

## Returns
A `StaticGraph` object containing the node.
"""
StaticGraph(n::Node) = StaticGraph(GraphNode(n))
StaticGraph(s::StaticGraph) = s

################################################################################
################################ Properties ####################################
################################################################################

#=
Nodetypes
=#
"""
    nodetypes(g::StaticGraph)
    nodetypes(g::Graph)

Returns the nodetypes stored in a static graph. This is a dictionary mapping
each type of node stored in a graph to the ids of the nodes with that type.

## Arguments
- `g::StaticGraph` or `g::Graph`: The `StaticGraph` or `Graph` from which to retrieve the nodetypes.

## Returns
An `OrderedDict` mapping types to `OrderedSet{Int}` containing the ids of the nodes
of that type within the `Graph` or `StaticGraph`.
"""
nodetypes(g::StaticGraph) = g.nodetypes


"""
    has_nodetype(g::StaticGraph, T)

Check if a static graph contains nodes of a given type.

Users will generally not use this method as they will normally deal with `Graph` objects
rather than `StaticGraph` directly.

## Arguments
- `g::StaticGraph`: The static graph to check.
- `T`: The node type to check for (usually a `DataType`).

## Returns
`true` if the graph contains nodes of type `T`, otherwise `false`.
"""
has_nodetype(g::StaticGraph, T) = haskey(g.nodetypes, T)
function add_nodetype!(g::StaticGraph, T, ID)
    !has_nodetype(g, T) && (g.nodetypes[T] = OC.OrderedSet{Int}())
    push!(g.nodetypes[T], ID)
    return nothing
end
function remove_nodetype!(g::StaticGraph, T, ID)
    delete!(g.nodetypes[T], ID)
    return nothing
end

#= Root =#
"""
    root_id(g::StaticGraph)
    root_id(g::Graph)

Returns the ID of the root node in a `StaticGraph` or `Graph` object.

## Arguments
- `g::StaticGraph` or `g::Graph`: The `StaticGraph` or `Graph` from which to retrieve the root ID.

## Returns
The ID of the root node in the graph.
"""
root_id(g::StaticGraph) = g.root
update_root!(g::StaticGraph, ID) = g.root = ID

"""
    getroot(g::StaticGraph)
    getroot(g::Graph)
Returns the root node of a `Graph` or `StaticGraph` object.

## Returns
The `GraphNode` object that is the root of the graph.
"""
getroot(g::StaticGraph) = g[root_id(g)]

"""
    get_root(g::Graph)
    get_root(g::StaticGraph)


Extract the root node of a `Graph` or `StaticGraph` object.

You may also use `getroot` (for compatibility with AbstractTrees.jl).

## Returns
The `GraphNode` object that is the root of the graph.
"""
const get_root = getroot

#=
Insertion
=#
"""
    insertion_id(g::StaticGraph)
    insertion_id(g::Graph)

Returns the ID of the most recently inserted node in a `StaticGraph` or `Graph` object.

## Arguments
- `g::StaticGraph` or `g::Graph`: The static graph from which to retrieve the insertion ID.

## Returns
The ID of the most recently inserted node in the graph.
"""
insertion_id(g::StaticGraph) = g.insertion
update_insertion!(g::StaticGraph, ID) = g.insertion = ID


"""
    insertion(g::StaticGraph)
    insertion(g::Graph)

Returns the most recently inserted node in a `StaticGraph` or `Graph` object.

## Arguments
- `g::StaticGraph` or `g::Graph`: The static graph from which to retrieve the node.

## Returns
The `GraphNode` object that is the most recently inserted node in the graph.
"""
insertion(g::StaticGraph) = g[insertion_id(g)]

#=
GraphNode
=#
"""
    nodes(g::StaticGraph)
    nodes(g::Graph)

Returns the nodes stored in a `StaticGraph` or `Graph` object.

## Arguments
- `g::StaticGraph` or `g::Graph`: The static graph from which to retrieve the nodes.

## Returns
An `OrderedDict{Int, GraphNode}` containing all nodes in the graph, indexed by their IDs.
"""
nodes(g::StaticGraph) = g.nodes


"""
    has_node(g::StaticGraph, ID)

Check if a static graph contains a node with a given ID.

Users will generally not use this method as they will normally deal with `Graph` objects
rather than `StaticGraph` directly.

## Arguments
- `g::StaticGraph`: The static graph to check.
- `ID`: The node ID to check for.

## Returns
`true` if the graph contains a node with the given ID, otherwise `false`.
"""
has_node(g::StaticGraph, ID) = haskey(g.nodes, ID)


"""
    length(g::StaticGraph)
    length(g::Graph)

Returns the number of nodes stored in a `StaticGraph` or `Graph` object.

## Arguments
- `g::StaticGraph` or `g::Graph`: The static graph for which to count the nodes.

## Returns
An integer representing the number of nodes in the graph.
"""
Base.length(g::StaticGraph) = length(g.nodes)
remove_node!(g::StaticGraph, ID) = delete!(g.nodes, ID)

#=
  Extracting and adding a node to a graph
  When adding a node to a graph:
    Update the nodetypes list if the GraphNode introduces a new data type into the graph
    Copy the node rather than keeping a reference to it (the user data is not copied)
=#
Base.getindex(g::StaticGraph, ID::Int) = g.nodes[ID]
function Base.setindex!(g::StaticGraph, n::GraphNode{T}, ID) where {T}
    cn = copy(n)
    g.nodes[ID] = cn
    change_id!(cn, ID)
    add_nodetype!(g, T, ID)
    return nothing
end

# Empty a graph

"""
    empty!(g::StaticGraph)

Remove all nodes and nodetypes from a static graph, making it empty.

Users will generally not use this method as they will normally deal with `Graph` objects
rather than `StaticGraph` directly.

## Arguments
- `g::StaticGraph`: The static graph to empty.

## Returns
Nothing. The graph is modified in place and all nodes and nodetypes are removed.
"""
function Base.empty!(g::StaticGraph)
    empty!(g.nodes)
    empty!(g.nodetypes)
    return nothing
end
