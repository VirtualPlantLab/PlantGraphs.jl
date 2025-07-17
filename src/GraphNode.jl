### This file DOES NOT contain public API ###

################################################################################
############################### Constructors ###################################
################################################################################

GraphNode(data::Node) = GraphNode(data, OC.OrderedSet{Int}(), missing, -1)

################################################################################
################################## Getters #####################################
################################################################################

"""
    data(n::GraphNode)

Returns the data stored in a graphnode. Users will generally not use this method
as they will normally deal with `Context` objects.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.
"""
data(n::GraphNode) = n.data

"""
    parent_id(n::GraphNode)

Returns the id of the parent node.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.
"""
parent_id(n::GraphNode) = n.parent_id

"""
    children_id(n::GraphNode)

Returns the ids of the children nodes.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.
"""
children_id(n::GraphNode) = n.children_id

"""
    self_id(n::GraphNode)

Returns the id of this node.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.
"""
self_id(n::GraphNode) = n.self_id

################################################################################
################################## Setters #####################################
################################################################################

# The methods taking Missing as input are needed to simply operations on root nodes

"""
    set_parent!(n::GraphNode, id)

Set the parent ID of a graph node.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node for which to set the parent.
- `id`: The ID of the parent node (or `missing` for root nodes).

## Returns
Nothing. The node is modified in place.
"""
set_parent!(n::GraphNode, id) = n.parent_id = id


"""
    remove_parent!(n::GraphNode)

Remove the parent ID from a graph node, setting it to `missing`.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node for which to remove the parent.

## Returns
Nothing. The node is modified in place.
"""
remove_parent!(n::GraphNode) = n.parent_id = missing


"""
    remove_child!(n::GraphNode, id)

Remove the id of a child from a graph node (this does not actually remove the child node from
the graph).

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node from which to remove the child.
- `id`: The ID of the child node to remove.

## Returns
Nothing. The node is modified in place.
"""
remove_child!(n::GraphNode, id) = delete!(n.children_id, id)


"""
    add_child!(n::GraphNode, id)

Add a child ID to a graph node.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node to which to add the child.
- `id`: The ID of the child node to add.

## Returns
Nothing. The node is modified in place.
"""
add_child!(n::GraphNode, id) = push!(n.children_id, id)



"""
    change_id!(n::GraphNode, id)

Set the self ID of a graph node.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node for which to set the self ID.
- `id::Int`: The new ID to assign to the node.

## Returns
Nothing. The node is modified in place.
"""
change_id!(n::GraphNode, id::Int) = n.self_id = id

################################################################################
################################## Queries #####################################
################################################################################

#=
 Check if GraphNode has a parent or a ancestor that fits a query with optional
 recursive search (with maximum depth)
=#



"""
    has_parent(n::GraphNode)

Check if a graph node has a parent.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node to check for a parent.

## Returns
`true` if the node has a parent (i.e., its parent ID is not `missing`), otherwise `false`.
"""
has_parent(n::GraphNode) = !ismissing(n.parent_id)



"""
    isroot(n::GraphNode)

Check if a graph node is a root node (i.e., has no parent).

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node to check.

## Returns
`true` if the node is a root node (has no parent), otherwise `false`.
"""
isroot(n::GraphNode) = !has_parent(n)



"""
    has_ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int; level::Int=1)

Check if a graph node has an ancestor that satisfies a given condition, with optional
    recursive search up to a maximum depth.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `node::GraphNode`: The node from which to start the ancestor search.
- `g::Graph`: The graph containing the node.
- `condition`: A function that takes a `Context` and returns `true` if the ancestor matches
the condition.
- `maxlevel::Int`: The maximum depth to search for ancestors.
- `level::Int=1`: (Optional) The current recursion level (default is 1).

## Returns
A tuple `(found::Bool, steps::Int)` where `found` is `true` if an ancestor matching the
condition is found, and `steps` is the number of steps taken in the search.
"""
function has_ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int, level::Int = 1)
    root_id(g) == self_id(node) && return false, level
    par = parent(node, g)
    if condition(Context(g, par))
        return true, level
    else
        if level < maxlevel
            check, steps = has_ancestor(par, g, condition, maxlevel, level + 1)
            check && return true, steps
        end
    end
    return false, level
end

#=
 Check if GraphNode has a child or a descendant that fits a condition with optional
 recursive search (with maximum depth)
=#


"""
    has_children(n::GraphNode)

Check if a graph node has any children.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node to check for children.

## Returns
`true` if the node has one or more children, otherwise `false`.
"""
has_children(n::GraphNode) = !isempty(n.children_id)



"""
    is_leaf(n::GraphNode)

Check if a graph node is a leaf node (i.e., has no children).

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node to check.

## Returns
`true` if the node is a leaf node (has no children), otherwise `false`.
"""
is_leaf(n::GraphNode) = !has_children(n)



"""
    has_descendant(node::GraphNode, g::Graph, condition, maxlevel::Int; level::Int=1)

Check if a graph node has a descendant that satisfies a given condition, with optional
    recursive search up to a maximum depth.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `node::GraphNode`: The node from which to start the descendant search.
- `g::Graph`: The graph containing the node.
- `condition`: A function that takes a `Context` and returns `true` if the descendant
matches the condition.
- `maxlevel::Int`: The maximum depth to search for descendants.
- `level::Int=1`: (Optional) The current recursion level (default is 1).

## Returns
A tuple `(found::Bool, steps::Int)` where `found` is `true` if a descendant matching the
condition is found, and `steps` is the number of steps taken in the search.
"""
function has_descendant(node::GraphNode, g::Graph, condition, maxlevel::Int, level::Int = 1)
    for child in children(node, g)
        if condition(Context(g, child))
            return true, level
        else
            if level <= maxlevel
                if has_descendant(child, g, condition, maxlevel, level + 1)[1]
                    return true, level + 1
                end
            end
        end
    end
    return false, 0
end

################################################################################
################################## Retrieve ####################################
################################################################################

#=
 Retrieve the parent GraphNode or an ancestor that fits a query with optional
 recursive search (with maximum depth)
=#


"""
    parent(n::GraphNode, g::Graph, nsteps::Int=1)

Retrieve the parent or ancestor of a graph node in a graph, with optional recursion depth.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node for which to retrieve the parent or ancestor.
- `g::Graph`: The graph containing the node.
- `nsteps::Int=1`: (Optional) The number of steps to go up the ancestor chain (default is
1 for direct parent).

## Returns
The parent node if `nsteps == 1`, or the ancestor node `nsteps` away. Returns `missing` if
    the node is a root node.
"""
function Base.parent(n::GraphNode, g::Graph, nsteps::Int = 1)
    isroot(n) && (return missing)
    if (nsteps == 1)
        out = g[parent_id(n)]
    else
        out = ancestor(n, g, x -> false, nsteps)
    end
    return out
end

# This method is useful for pruning and other static graph operations


"""
    parent(n::GraphNode, g::StaticGraph)

Retrieve the parent node of a graph node from a static graph.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node for which to retrieve the parent.
- `g::StaticGraph`: The static graph containing the node.

## Returns
The parent node of `n` in the static graph, or `missing` if the node is a root node.
"""
Base.parent(n::GraphNode, g::StaticGraph) = g[parent_id(n)]


"""
    ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int; level::Int=1)

Retrieve the ancestor of a graph node that satisfies a given condition, with optional
    recursive search up to a maximum depth.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `node::GraphNode`: The node from which to start the ancestor search.
- `g::Graph`: The graph containing the node.
- `condition`: A function that takes a `Context` and returns `true` if the ancestor matches the condition.
- `maxlevel::Int`: The maximum depth to search for ancestors.
- `level::Int=1`: (Optional) The current recursion level (default is 1).

## Returns
The ancestor node that matches the condition, or `missing` if none is found or the node is a root node.
"""
function ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int, level::Int = 1)
    isroot(node) && (return missing)
    par = parent(node, g)
    if condition(Context(g, par))
        return par
    elseif level < maxlevel
        return ancestor(par, g, condition, maxlevel, level + 1)
    end
    return par # A neat trick to select an ancestor nsteps away (used by parent)
end

#=
 Retrieve the children GraphNode or a descendant that fits a condition with optional
 recursive search (with maximum depth)
=#


"""
    children(n::GraphNode, g::StaticGraph)

Return an iterator over the children nodes of a given graph node in a static graph.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `n::GraphNode`: The node for which to retrieve the children.
- `g::StaticGraph`: The static graph containing the node.

## Returns
An iterator over the `GraphNode` objects that are children of `n` in the static graph.
"""
children(n::GraphNode, g::StaticGraph) = (g[id] for id in children_id(n))


"""
    getdescendant(node::GraphNode, g::Graph, condition, maxlevel::Int; level::Int=1)

Retrieve the descendant of a graph node that satisfies a given condition, with optional
    recursive search up to a maximum depth.

Users will generally not use this method as they will normally deal with `Context` objects
rather than `GraphNode` directly.

## Arguments
- `node::GraphNode`: The node from which to start the descendant search.
- `g::Graph`: The graph containing the node.
- `condition`: A function that takes a `Context` and returns `true` if the descendant
matches the condition.
- `maxlevel::Int`: The maximum depth to search for descendants.
- `level::Int=1`: (Optional) The current recursion level (default is 1).

## Returns
The descendant node that matches the condition, or `missing` if none is found or the node is a leaf node.
"""
function getdescendant(node::GraphNode, g::Graph, condition, maxlevel::Int,
    level::Int = 1)
    for child in children(node, g)
        if condition(Context(g, child))
            return child
        elseif level <= maxlevel
            return getdescendant(child, g, condition, maxlevel, level + 1)
        end
    end
    return missing # This means we tested on a leaf node
end

################################################################################
#################################### Copy ######################################
################################################################################

#=
    copy(n::GraphNode)
Creates a new GraphNode with the same contents as `n`. A reference to the data is kept,
but children_id and parent_id are copied. This necessary for rules that reuse a node
on the right hand side
=#
Base.copy(n::GraphNode) = GraphNode(n.data, copy(children_id(n)), parent_id(n), self_id(n))
