### This file contains public API ###

"""
    node_label(n::Node, id)

Function to construct a label for a node to be used by `draw()` when visualizing.
The user can specialize this method for user-defined data types to customize the
labels. By default, the type of data stored in the node and the unique ID of the
node are used as labels.
"""
function node_label(n::Node, id)
    node_class = split("$(typeof(n))", ".")[end]
    label = "$node_class-$(id)"
    return label
end

#=
Translate a static graph in a DiGraph to be used by GraphMakie. Nodes are
labelled, edges are not. The translation extracts the topological relationships
among nodes and the result of applying `node_label` to each node.
=#
function GR.DiGraph(g::StaticGraph)
    # Create a DiGraph structure
    n = length(g)
    dg = GR.DiGraph(n)
    # Connect ids in original graph to new ids but make sure the root
    # node is at the beginning
    ids = nodes(g) |> keys |> collect
    rid = root_id(g)
    posroot = findfirst(i -> i == rid, ids)
    ids = vcat(rid, ids[1:(posroot - 1)], ids[(posroot + 1):end])
    map_ids = Dict((ids[i], i) for i in 1:n)
    # Create label for each node (user can modify behavior)
    labels = [node_label(data(g[id]), id) for id in ids]
    # Update the digraph with information collected in the above
    for (key, val) in nodes(g)
        children = children_id(val)
        if length(children) > 0
            for child in children
                GR.add_edge!(dg, map_ids[key], map_ids[child])
            end
        end
    end
    # Return the DiGraph structure and the associated labels
    return dg, labels, n
end

# Forward the DiGraph method of StaticGraph onto Graph
GR.DiGraph(g::Graph) = GR.DiGraph(g.graph)

"""
    draw(g::StaticGraph; resolution = (1920, 1080), nlabels_textsize = 15, arrow_size = 15,
         node_size = 5)

Equivalent to the method `draw(g::Graph; kwargs...)` but  to visualize static
graphs (e.g., the axiom of a graph).
"""
function draw(g::StaticGraph; resolution = (1920, 1080),
              nlabels_textsize = 15, arrow_size = 15, node_size = 5)

    # Create the digraph
    dg, labels, n = GR.DiGraph(g)

    if n == 1
        println("The graph only has one node, so no visualization was made")
        return nothing
    end

    # Generate the visualization
    nlabels_align = [(:left, :bottom) for _ in 1:n]
    f, ax, p = GM.graphplot(dg,
                            layout = NL.Buchheim(),
                            nlabels = labels,
                            nlabels_distance = 5,
                            nlabels_textsize = nlabels_textsize,
                            nlabels_align = nlabels_align,
                            arrow_size = arrow_size,
                            node_size = node_size,
                            figure = (resolution = resolution,))

    # Make it look prettier
    GM.hidedecorations!(ax)
    GM.hidespines!(ax)
    #ax.aspect = GM.DataAspect()

    # Return the figure object (rely on the context to display it)
    return f
end

# Sometimes a StaticGraph is just a node...
function draw(n::Node; kwargs...)
    println("The graph only has one node, so no visualization was made")
    return nothing
end

"""
    draw(g::Graph; resolution = (1920, 1080), nlabels_textsize = 15, arrow_size = 15,
         node_size = 5)

Visualize a graph as network diagram.

## Arguments
- `g::Graph`: The graph to be visualized.

## Keywords
- `resolution = (1920, 1080)`: The resolution of the image to be rendered, in
pixels (online relevant for native and web backends). Default resolution is HD.
- `nlabels_textsize = 15`: Customize the size of the labels in the diagram.
- `arrow_size = 15`: Customize the size of the arrows representing edges in the
diagram.
- `node_size = 5`: Customize the size of the nodes in the diagram.

## Details

By default, nodes are labelled with the type of data stored and their unique ID.
See function `node_label()` to customize the label for different types of data.

See `save` from FileIO to export the network diagram as a raster or vector image
(depending on the backend). The function `calculate_resolution()` can be useful
to ensure a particular dpi of the exported image (assuming some physical size).

The graphics backend will interact with the environment where the Julia code is
being executed (i.e., terminal, IDE such as VS Code, interactive notebook such
as Jupyter or Pluto). These interactions are all controlled by the graphics
package Makie that VPL relies on. Some details on the expected behavior specific
to `draw()` can be found in the general VPL documentation.

## Returns
This function returns a Makie `Figure` object, while producing the visualization
as a side effect.

## Examples
```jldoctest
let
    struct A1 <: Node val::Int end
    struct B1 <: Node val::Int end
    axiom = A1(1) + (B1(1) + A1(3), B1(4))
    g = Graph(axiom = axiom)
    draw(g)
end
```
"""
function draw(g::Graph; resolution = (1920, 1080), nlabels_textsize = 15, arrow_size = 15,
              node_size = 5)
    out = draw(g.graph; resolution = resolution, nlabels_textsize = nlabels_textsize,
               arrow_size = arrow_size, node_size = node_size)
    return out
end

"""
    calculate_resolution(;width = 1024/300*2.54, height = 768/300*2.54,
                          format = "raster", dpi = 300)

Calculate the resolution required to achieve a specific `width` and `height`
(in cm) of the exported image, with a particular `dpi` (for raster formats).
"""
function calculate_resolution(; width = 1024 / 300 * 2.54, height = 768 / 300 * 2.54,
                              format = "raster", dpi = 300)
    if format == "raster"
        res_width = width / 2.54 * dpi
        res_height = height / 2.54 * dpi
        return res_width, res_height
    else
        res_width = width / 2.54 * 72 / 0.75
        res_height = height / 2.54 * 72 / 0.75
        return res_width, res_height
    end
end
