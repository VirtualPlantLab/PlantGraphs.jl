import VPLGraph as V
using Test

let
# Test GraphNode construction
n = V.GraphNode(1)

# Check that this returns the correct type
@test n isa V.GraphNode
@test !isimmutable(n)

# Check deafult constructor
@test ismissing(V.parentID(n))
@test isempty(V.childrenID(n))

# Add connections
V.addChild!(n,1)
@test length(V.childrenID(n)) == 1 && first(V.childrenID(n)) == 1
V.setParent!(n,2)
@test V.parentID(n) == 2

# Create a copy of the node
n2 = copy(n)

# Remove connections
V.removeChild!(n,1)
@test isempty(V.childrenID(n))
V.removeParent!(n)
@test ismissing(V.parentID(n))

# The resulting node should be root and leaf
@test V.isLeaf(n)
@test V.isRoot(n)

# Retrieve data stored inside the node
@test V.data(n) === 1

# Make sure that the copied node was independent
@test V.hasChildren(n2)
@test V.hasParent(n2)

end
