# PlantGraphs release notes

We started keeping track of changes in the `NEWS.md` file after version 0.1.0.

# PlantGraphs 1.0.0 (2026-06-10)

No actual changes. We move to version 1.0.0 because:

- The tool is being used extensively by the community and it has become more stable.

- Julia treats any change as breaking change when < 1.0.0

# PlantGraphs 0.1.3 (2026-01-14)

* Update dependencies and ensure it works on Julia 1.12

# PlantGraphs 0.1.2 (2025-07-18)

* Bug fix in the definitions `traverse`

# PlantGraphs 0.1.1 (2025-07-17)

* Export methods to modify global ID counter (useful when you save the graph and want to
  restart simulation later on).

* Add `apply!` method to fill the nodes that result from a query in-place.

* Document every function and type in the package, including methods and functions not included
    in the public API.
