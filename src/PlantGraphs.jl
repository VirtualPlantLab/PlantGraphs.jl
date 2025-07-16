module PlantGraphs

# Public API of PlantGraph
export Node, Context, Graph, Rule, Query, rewrite!, apply, data, rules, graph,
       static_graph, data, graph_data,
       has_parent, has_ancestor, ancestor, is_root, get_root, has_children, has_descendant,
       children, get_descendant, is_leaf, traverse, traverse_dfs, traverse_bfs, draw,
       calculate_resolution, node_label,
       generate_id, get_id!, reset_id!, set_id!

# API for VPL-style graphs (we export methods on these functions so we need to import names)
import AbstractTrees: isroot, getroot, children, getdescendant

# Import Base to define methods (see list in comment)
import Base #copy, length, empty!, append!, +, getindex, setindex!, show, Tuple, parent

# To unroll the loop over rules or queries (we must import the macro for it to work)
import Unrolled: @unroll

# Use ordered collections for reproducibility
import OrderedCollections as OC

# External libraries for drawing graphs
import Graphs as GR
import GraphMakie as GM
import NetworkLayout as NL

# Source code of PlantGraph
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
