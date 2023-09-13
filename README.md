# PlantGraphs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](http://virtualplantlab.com/)
[![CI](https://github.com/VirtualPlantLab/PlantGraphs.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/VirtualPlantLab/PlantGraphs.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/VirtualPlantLab/PlantGraphs.jl/branch/master/graph/badge.svg?token=LCZHPERHUN)](https://codecov.io/gh/VirtualPlantLab/PlantGraphs.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![ColPrac](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

The goal of PlantGraphs.jl is to provide a framework for building dynamic graphs for
functional-structural plant models. This package is a component of the Virtual Plant Lab and
end users should focus on the [VPL.jl](https://github.com/VirtualPlantLab/VPL.jl) instead.

# 1. Instalation

You can install the latest stable version of PlantGraphs.jl with the Julia package manager:

```julia
] add PlantGraphs
```

Or the development version directly from here:

```julia
import Pkg
Pkg.add(url="https://github.com/VirtualPlantLab/PlantGraphs.jl", rev = "master")
```

# 2. Usage

Graphs from PlantGraphs.jl implement methods for most functions in the AbstractTrees.jl
package (full compatibility is a work in progress), plus additional methods specific for
functional-structural plant models. The following example shows how to create a simple
graph, run a dynamic simulation and visualize the graph (check documentation for more
details and examples):

```julia
using PlantGraphs

module algae
    import PlantGraphs: Node
    struct A <: Node end
    struct B <: Node end
end
import .algae

axiom = algae.A()
rule1 = Rule(algae.A, rhs = x -> algae.A() + algae.B())
rule2 = Rule(algae.B, rhs = x -> algae.A())
organism = Graph(axiom = axiom, rules = (rule1, rule2))
import CairoMakie
draw(organism)

rewrite!(organism)
draw(organism)
```
