### This file does not contain public API ###

#=
Remove a GraphNode from a graph. Update the insertion and root points if necessary.
Optionally, neighbouring nodes are also updated to ensure a consistent graph
=#
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
