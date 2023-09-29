```@meta
CurrentModule = PlantGraphs
```

# Graphs

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
graph_data(c::Context)
```

## Node relations

```@docs
has_parent(c::Context)
```

```@docs
is_root
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
get_root
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
get_descendant
```

# Traversal algorithms

```@docs
traverse(g::Graph; fun = () -> nothing)
```

```@docs
traverse_dfs(g::Graph; fun = () -> nothing, ID = root_id(g))
```

```@docs
traverse_bfs(g::Graph; fun = () -> nothing, ID = root_id(g))
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
