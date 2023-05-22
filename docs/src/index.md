```@meta
CurrentModule = VPLGraph
```

# VPLGraph

API documentation for [VPLGraphs](https://github.com/VirtualPlantGraph/VPLGraphs.jl).

## Types

```@docs
Graph
```

```@docs
Rule
```

```@docs
Query
```

```@docs
VPLNodeData
```

```@docs
Context
```

## Graph DSL

```@docs
+(n1::VPLNodeData, n2::VPLNodeData)
+(g::StaticGraph, n::VPLNodeData)
+(n::VPLNodeData, g::StaticGraph)
+(g1::StaticGraph, g2::StaticGraph)
+(n::VPLNodeData, T::Tuple)
```

## Applying rules and queries

```@docs
apply(g::Graph, query::Query)
```

```@docs
rewrite!(g::Graph)
```

## Extracting information

```@docs
data(g::Graph)
```

```@docs
rules(g::Graph)
```

```@docs
data(c::Context)
```

```@docs
data(c::Context)
```

## VPLNodeData relations

```@docs
has_parent(c::Context)
```

```@docs
is_root(c::Context)
```

```@docs
has_ancestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
parent(c::Context; nsteps::Int)
```

```@docs
ancestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
has_children(c::Context)
```

```@docs
is_leaf(c::Context)
```

```@docs
has_descendant(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
children(c::Context)
```

```@docs
descendant(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

# Traversal algorithms

```@docs
traverse(g::Graph; fun = () -> nothing)
```

```@docs
traverse_dfs(g::Graph; fun = () -> nothing, ID = root(g))
```

```@docs
traverse_bfs(g::Graph; fun = () -> nothing, ID = root(g))
```

## Graph visualization

```@docs
draw(g::Graph; force = false, inline = false, resolution = (1920, 1080),
    nlabels_textsize = 15, arrow_size = 15, node_size = 5)
draw(g::StaticGraph; force = false, inline = false, resolution = (1920, 1080),
              nlabels_textsize = 15, arrow_size = 15, node_size = 5)
node_label(n::VPLNodeData, id)
```

```@docs
calculate_resolution(;width = 1024/300*2.54, height = 768/300*2.54,
                              format = "png", dpi = 300)
```
