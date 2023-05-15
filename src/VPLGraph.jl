module VPLGraph

# Public API of VPLGraph
export Node, Graph, Rule, Query, rewrite!, apply, vars, rules, graph, data, 
       hasParent, hasAncestor, ancestor, isRoot, hasChildren, hasDescendent, 
       children, descendent, isLeaf, traverse, traverseDFS, traverseBFS, draw, 
       calculate_resolution, node_label


# Base functions that will be extended
import Base: copy, length, empty!, append!, +, getindex, setindex!, show, parent,
             Tuple

# To unroll the loop over rules or queries
import Unrolled: @unroll

# External libraries for drawing graphs
import Graphs as GR
import GraphMakie as GM
import NetworkLayout as NL

# Source code of VPLGraph
include("Types.jl")
include("GraphNode.jl")
include("Context.jl")
include("StaticGraph.jl")
include("GraphConstruction.jl")
include("GraphRewriting.jl")
include("Graph.jl")
include("Rule.jl")
include("Query.jl")
include("Algorithms.jl")
include("Draw.jl")

end
