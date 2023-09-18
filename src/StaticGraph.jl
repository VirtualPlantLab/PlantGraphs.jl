### This file does not contain public API ###

#=
 Generate unique IDs for Nodes in graphs to avoid ID clashes when merging graphs
 This should be done in a thread-safe manner.
 This is required because graphs are created on right hand side of rules and then
 appended to an existing graph
=#
let ID = Threads.Atomic{Int}(0)
    global generate_id
    global reset_id!
    generate_id() = Threads.atomic_add!(ID, 1) + 1
    reset_id!() = ID = Threads.Atomic{Int}(0)
end

################################################################################
########################  StaticGraph constructors  ############################
################################################################################

#=
    Facilitate construction of static graphs without having to use the DSL
=#
function StaticGraph()
    StaticGraph(OrderedDict{Int, GraphNode}(),
        OrderedDict{DataType, OrderedSet{Int}}(),
        -1,
        -1)
end
function StaticGraph(n::GraphNode)
    ID = generate_id()
    change_id!(n, ID)
    nlocal = copy(n)
    g = StaticGraph(OrderedDict{Int, GraphNode}(ID => nlocal),
        OrderedDict(typeof(nlocal.data) => OrderedSet{Int}(ID)),
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
    !has_nodetype(g, T) && (g.nodetypes[T] = OrderedSet{Int}())
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
length(g::StaticGraph) = length(g.nodes)
remove_node!(g::StaticGraph, ID) = delete!(g.nodes, ID)

#=
  Extracting and adding a node to a graph
  When adding a node to a graph:
    Update the nodetypes list if the GraphNode introduces a new data type into the graph
    Copy the node rather than keeping a reference to it (the user data is not copied)
=#
getindex(g::StaticGraph, ID::Int) = g.nodes[ID]
function setindex!(g::StaticGraph, n::GraphNode{T}, ID) where {T}
    cn = copy(n)
    g.nodes[ID] = cn
    change_id!(cn, ID)
    add_nodetype!(g, T, ID)
    return nothing
end

# Empty a graph
function empty!(g::StaticGraph)
    empty!(g.nodes)
    empty!(g.nodetypes)
    return nothing
end
