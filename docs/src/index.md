```@meta
CurrentModule = PlantGraph
```

# PlantGraph

API documentation for [PlantGraphs](https://github.com/VirtualPlantGraph/PlantGraphs.jl).

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

## Node relations

```@docs
has_parent(c::Context)
```

```@docs
isroot(c::Context)
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
haschildren(c::Context)
```

```@docs
isleaf(c::Context)
```

```@docs
hasdescendant(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

```@docs
children(c::Context)
```

```@docs
getdescendant(c::Context; condition = x -> true, maxlevel::Int = typemax(Int))
```

# Traversal algorithms

```@docs
traverse(g::Graph; fun = () -> nothing)
```

```@docs
traversedfs(g::Graph; fun = () -> nothing, ID = root_id(g))
```

```@docs
traversebfs(g::Graph; fun = () -> nothing, ID = root_id(g))
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
