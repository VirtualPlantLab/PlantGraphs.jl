module VPLGraphs

# Public API of VPLGraph
export VPLGraphData, Node, Graph, Rule, Query, rewrite!, apply, data, rules, graph,
       static_graph, data, graph_data, parent,
       has_parent, has_ancestor, ancestor, is_root, has_children, has_descendant,
       children, descendant, is_leaf, traverse, traverse_dfs, traverse_bfs, draw,
       calculate_resolution, node_label

# API for VPL-style graphs
import VPLGraphAPI: VPLGraph, VPLStaticGraph, VPLGraphNode, VPLGraphData, VPLNodeData, data,
                    is_root, has_parent, has_ancestor, ancestor, is_leaf, has_children,
                    children, has_descendant, descendant, traverse

# Base functions that will be extended
import Base: copy, length, empty!, append!, +, getindex, setindex!, show, Tuple, parent

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
