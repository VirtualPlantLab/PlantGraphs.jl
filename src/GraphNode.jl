### This file DOES NOT contain public API ###

################################################################################
############################### Constructors ###################################
################################################################################

GraphNode(data::Node) = GraphNode(data, OrderedSet{Int}(), missing, -1)

################################################################################
################################## Getters #####################################
################################################################################

data(n::GraphNode) = n.data
parent_id(n::GraphNode) = n.parent_id
children_id(n::GraphNode) = n.children_id
self_id(n::GraphNode) = n.self_id

################################################################################
################################## Setters #####################################
################################################################################

# The methods taking Missing as input are needed to simply operations on root nodes

set_parent!(n::GraphNode, id) = n.parent_id = id
remove_parent!(n::GraphNode) = n.parent_id = missing
remove_child!(n::GraphNode, id) = delete!(n.children_id, id)
add_child!(n::GraphNode, id) = push!(n.children_id, id)
change_id!(n::GraphNode, id::Int) = n.self_id = id

################################################################################
################################## Queries #####################################
################################################################################

#=
 Check if GraphNode has a parent or a ancestor that fits a query with optional
 recursive search (with maximum depth)
=#
has_parent(n::GraphNode) = !ismissing(n.parent_id)
isroot(n::GraphNode) = !has_parent(n)

function has_ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int,
                      level::Int = 1)
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
haschildren(n::GraphNode) = !isempty(n.children_id)
isleaf(n::GraphNode) = !haschildren(n)

function hasdescendant(node::GraphNode, g::Graph, condition, maxlevel::Int,
                        level::Int = 1)
    for child in children(node, g)
        if condition(Context(g, child))
            return true, level
        else
            if level <= maxlevel
                if hasdescendant(child, g, condition, maxlevel, level + 1)[1]
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
function parent(n::GraphNode, g::Graph, nsteps::Int = 1)
    isroot(n) && (return missing)
    if (nsteps == 1)
        out = g[parent_id(n)]
    else
        out = ancestor(n, g, x -> false, nsteps)
    end
    return out
end

# This method is useful for pruning and other static graph operations
parent(n::GraphNode, g::StaticGraph) = g[parent_id(n)]

function ancestor(node::GraphNode, g::Graph, condition, maxlevel::Int,
                  level::Int = 1)
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
children(n::GraphNode, g::StaticGraph) = (g[id] for id in children_id(n))

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
copy(n::GraphNode) = GraphNode(n.data, copy(children_id(n)), parent_id(n), self_id(n))
