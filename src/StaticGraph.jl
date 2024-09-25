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
    """
    generate_id() = Threads.atomic_add!(ID, 1) + 1

    @doc """
        reset_id!()

    Reset the ID counter for generating unique IDs for nodes in graphs to zero.
    """
    function reset_id!()
        set_id!(0)
    end

    @doc """
        get_id!()

    Get the current value of the ID counter for generating unique IDs for nodes in graphs.
    """
    get_id!() = ID

    @doc """
        set_id!(id)

    Set the ID counter for generating unique IDs for nodes in graphs to any integer value
    `id`.
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
function StaticGraph()
    StaticGraph(OC.OrderedDict{Int, GraphNode}(),
        OC.OrderedDict{DataType, OC.OrderedSet{Int}}(),
        -1,
        -1)
end
function StaticGraph(n::GraphNode)
    ID = generate_id()
    change_id!(n, ID)
    nlocal = copy(n)
    g = StaticGraph(OC.OrderedDict{Int, GraphNode}(ID => nlocal),
        OC.OrderedDict(typeof(nlocal.data) => OC.OrderedSet{Int}(ID)),
        ID, ID)
    return g
end
StaticGraph(n::Node) = StaticGraph(GraphNode(n))
StaticGraph(s::StaticGraph) = s

################################################################################
################################ Properties ####################################
################################################################################

#=
Nodetypes
=#
nodetypes(g) = g.nodetypes
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

#=
Root
=#
root_id(g::StaticGraph) = g.root
update_root!(g::StaticGraph, ID) = g.root = ID
getroot(g::StaticGraph) = g[root_id(g)]

"""
    get_root(g::Graph)


Extract the root node of a graph.

You may also use `getroot` (for compatibility with AbstractTrees.jl).
"""
const get_root = getroot

#=
Insertion
=#
insertion_id(g::StaticGraph) = g.insertion
update_insertion!(g::StaticGraph, ID) = g.insertion = ID
insertion(g::StaticGraph) = g[insertion_id(g)]

#=
GraphNode
=#
nodes(g::StaticGraph) = g.nodes
has_node(g::StaticGraph, ID) = haskey(g.nodes, ID)
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
function Base.empty!(g::StaticGraph)
    empty!(g.nodes)
    empty!(g.nodetypes)
    return nothing
end
