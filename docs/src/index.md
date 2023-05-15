```@meta
CurrentModule = VPLGraph
```

# VPLGraph

API documentation for [VPLGraph](https://github.com/VirtualPlantGraph/VPLGraph.jl).

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
Node
```

```@docs
Context
```

## Graph DSL

```@docs
+(n1::Node, n2::Node)
+(g::StaticGraph, n::Node)
+(n::Node, g::StaticGraph)
+(g1::StaticGraph, g2::StaticGraph)
+(n::Node, T::Tuple)
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
vars(g::Graph)
```

```@docs
rules(g::Graph)
```

```@docs
vars(c::Context)
```

```@docs
data(c::Context)
```

## Node relations

```@docs
hasParent(c::Context)
```

```@docs
isRoot(c::Context)
```

```@docs
hasAncestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
parent(c::Context; nsteps::Int)
```

```@docs
ancestor(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
hasChildren(c::Context)
```

```@docs
isLeaf(c::Context)
```

```@docs
hasDescendent(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
children(c::Context)
```

```@docs
descendent(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

# Traversal algorithms

```@docs
traverse(g::Graph; fun = () -> nothing)
```

```@docs
traverseDFS(g::Graph; fun = () -> nothing, ID = root(g))
```

```@docs
traverseBFS(g::Graph; fun = () -> nothing, ID = root(g))
```

## Graph visualization

```@docs
draw(g::Graph; force = false, inline = false, resolution = (1920, 1080),
    nlabels_textsize = 15, arrow_size = 15, node_size = 5)
draw(g::StaticGraph; force = false, inline = false, resolution = (1920, 1080),
              nlabels_textsize = 15, arrow_size = 15, node_size = 5)
node_label(n::Node, id)
```

```@docs
calculate_resolution(;width = 1024/300*2.54, height = 768/300*2.54, 
                              format = "png", dpi = 300)
```

