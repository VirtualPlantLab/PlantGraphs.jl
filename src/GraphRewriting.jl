### This file does not contain public API ###

#=
Remove a GraphNode from a graph. Update the insertion and root points if necessary.
Optionally, neighbouring nodes are also updated to ensure a consistent graph
=#

"""
    remove!(g::StaticGraph, ID)

Remove a node from a static graph by its ID. Updates the root and insertion points if
necessary. If the graph only contains one node, the graph is emptied.

## Arguments
- `g::StaticGraph`: The static graph from which to remove the node.
- `ID`: The ID of the node to remove.

## Returns
Nothing. The graph is modified in place.
"""
function remove!(g::StaticGraph, ID)
    node = g[ID]
    # Update root, insertion and, optionally, edges from neighbouring nodes
    if length(g) > 1
        # Remove the node from nodes and nodetypes
        remove_nodetype!(g, typeof(node.data), ID)
        remove_node!(g, ID)
        return nothing
    else
        empty!(g)
        return nothing
    end
end

#=
Remove a node from a graph and all of its descendants. The root or insertion point of the graph will be
updated if required. The edges from other nodes will always be updated. The
algorith actually starts from the leaf nodes and works its way back to the pruning
node.
=#

"""
    prune!(g::StaticGraph, ID)

Remove a node and all its descendants from a static graph. Updates the root or
insertion point if required, and always updates edges from other nodes. The algorithm starts
from the leaf nodes and works its way back to the pruning node.

## Arguments
- `g::StaticGraph`: The static graph from which to prune nodes.
- `ID`: The ID of the node to prune (and all its descendants).

## Returns
Nothing. The graph is modified in place.
"""
function prune!(g::StaticGraph, ID)
    node = g[ID]
    if length(g) == 1 || root_id(g) == ID
        empty!(g)
        return nothing
    elseif insertion_id(g) != ID
        for child_id in children_id(node)
            prune!(g, child_id)
        end
    end
    # Remove edges from parent
    remove_child!(parent(node, g), ID)
    # Remove the actual node
    remove!(g, ID)
    return nothing
end

#=
Replace a node in a graph by a new node.
=#

"""
    replace!(g::StaticGraph, ID, n::GraphNode)

Replace a node in a static graph by a new node. The new node inherits the parents and
children of the old node. The old node is removed and the new node is added with the same ID.

## Arguments
- `g::StaticGraph`: The static graph in which to perform the replacement.
- `ID`: The ID of the node to be replaced.
- `n::GraphNode`: The new node to insert in place of the old node.

## Returns
Nothing. The graph is modified in place.
"""
function replace!(g::StaticGraph, ID, n::GraphNode)
    old = g[ID]
    # Transfer parents from the old to the new node
    set_parent!(n, parent_id(old))
    # Transfer children from the old to the new node
    for child in children_id(old)
        add_child!(n, child)
    end
    # Remove the old node from the graph without updating edges
    remove!(g, ID)
    # Add the new node to the graph with the old ID
    g[ID] = n
    return nothing
end

#=
Replace a node in a graph by a whole new subgraph
The root node of gn inherits the ID and parents of the old node.
The insertion node of gn inherits the children of the old node.
The insertion node of gn will change if the replaced node was the insertion point
=#

"""
    replace!(g::StaticGraph, ID::Int, gn::StaticGraph)

Replace a node in a static graph by a whole new subgraph. The root node of the subgraph
inherits the ID and parents of the old node. The insertion node of the subgraph inherits the
children of the old node. The insertion node of the subgraph will change if the replaced
node was the insertion point.

## Arguments
- `g::StaticGraph`: The static graph in which to perform the replacement.
- `ID`: The ID of the node to be replaced.
- `gn::StaticGraph`: The subgraph to insert in place of the old node.

## Returns
Nothing. The graph is modified in place.
"""
function replace!(g::StaticGraph, ID::Int, gn::StaticGraph)

    # Extract node to be replaced and delete it from graph
    old = g[ID]
    remove!(g, ID)

    # Add all the nodes of subgraph to the graph
    for (key, val) in nodes(gn)
        g[key] = val
    end

    # Transfer parents of the old node to the root node of subgraph
    rootID = root_id(gn)
    if root_id(g) != ID
        pID = parent_id(old)
        set_parent!(g[rootID], pID)
        add_child!(g[pID], rootID)
        remove_child!(g[pID], ID)
    else
        update_root!(g, rootID)
    end

    # Transfer children of the old node to the insertion node of subgraph and update the children
    insID = insertion_id(gn)
    for child_id in children_id(old)
        add_child!(g[insID], child_id)
        set_parent!(g[child_id], insID)
    end

    # Change insertion point if the insertion point is being replaced
    insertion_id(g) == ID && update_insertion!(g, insID)

    return nothing
end

#=
Replace and append nodetypes into a graph by wrapping it inside a node.
=#
replace!(g::StaticGraph, ID, n::Node) = replace!(g, ID, GraphNode(n))

# Empty replacement means pruning
replace!(G::StaticGraph, ID, n::Nothing) = prune!(G, ID)
