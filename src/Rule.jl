### This file contains public API ###

################################################################################
################## Constructors and other rule methods  ########################
################################################################################

"""
    Rule(nodetype; lhs = x -> true, rhs = x -> nothing, captures = false)

Create a replacement rule for nodes of type `nodetype`.

## Arguments
- `nodetype`: Type of node to be matched.

## Keywords
- `lhs`: Function or function-like object that takes a `Context` object and returns whether the node should be replaced or not (with `true` or `false`).
- `rhs`: Function or function-like object that takes one or more `Context` objects and returns a replacement graph or `nothing`. If it takes several inputs, the first one will correspond to the node being replaced.
- `captures`: Either `false` or `true` to indicate whether the left-hand side of the rule is capturing nodes in the context of the replacement node to be used for the construction of the replace graph.

## Details
See VPL documentation for details on rule-based graph rewriting.

## Return
An object of type `Rule`.

## Examples
```jldoctest
julia> struct A <: Node end;

julia> struct B <: Node end;

julia> axiom = A() + B();

julia> rule = Rule(A, rhs = x -> A() + B());

julia> rules_graph = Graph(axiom = axiom, rules = rule);

julia> rewrite!(rules_graph);
```
"""
function Rule(nodetype::DataType; lhs = x -> true, rhs = x -> nothing,
    captures::Bool = false)
    r = Rule{nodetype, captures, typeof(lhs), typeof(rhs)}(lhs, rhs, Int[], Tuple[])
    return r
end

# Remove the matches and contexts stored in a rule
function Base.empty!(rule::Rule)
    empty!(rule.matched)
    empty!(rule.contexts)
    return nothing
end

# Helper functions for type propagation
nodetype(r::Rule{N, C, LHST, RHST}) where {N, C, LHST, RHST} = N
captures(r::Rule{N, C, LHST, RHST}) where {N, C, LHST, RHST} = C

# Method require to create tuple of rules from one rule (allows creating a Graph)
# while passing one rule rather than a tuple of rules
Base.Tuple(r::Rule) = (r,)

################################################################################
##############################  Show methods  ##################################
################################################################################

#=
  Print human-friendly description of a rule
=#
function Base.show(io::IO, rule::Rule{N, LHST, RHST}) where {N, LHST, RHST}
    if captures(rule)
        println(io, "Rule replacing nodes of type ", N, " with context capturing.")
    else
        println(io, "Rule replacing nodes of type ", N, " without context capturing.")
    end
    return nothing
end

################################################################################
#####################  Rule-based graph rewriting  #############################
################################################################################

#=
  Match a rule against a graph to identify if it will be replaced and
  capture nodes in the the context of the replaced node, if necessary.
  The function checks that no node is matched by more than one rule as that
  breaks the conceptual parallelism of graph rewriting.
=#
function match_rule!(rule::Rule, node::Context, assigned)
    if captures(rule)
        match, con = rule.lhs(node)
    else
        match = rule.lhs(node)
        con = ()
    end
    if match
        nid = id(node)
        nid in assigned &&
            Throw(ErrorException("GraphNode with id $nid was matched by more than one rule"))
        push!(rule.matched, nid)
        push!(assigned, nid)
        push!(rule.contexts, con)
    end
    return nothing
end

#=
    Match a rule against a graph to identify which nodes will be replaced.
=#
function match_rule!(g::Graph, rule::Rule, assigned::OC.OrderedSet{Int})
    # Reset the rule
    empty!(rule)
    N = nodetype(rule)
    # Extract candidates based on nodetype
    if has_nodetype(g.graph, N)
        candidates = g.graph.nodetypes[N]
        # Loop over the candidates and store those that match the lhs
        for id in candidates
            match_rule!(rule, Context(g, g[id]), assigned)
        end
    end
    return nothing
end

#=
  Match all the rules of a dynamic graph against its internal graph
  Rules is needed as argument of the function in order for @unroll to work
=#
@inline @unroll function match_rules!(g::Graph, rules)
    assigned = OC.OrderedSet{Int}()
    # For each rule, match the nodes that meet the conditions of the query
    @unroll for rule in rules
        match_rule!(g, rule, assigned)
    end
    return nothing
end

#=
  Execute a rule by replacing or pruning for every node previously matched.
  Nodes captured in the context of lhs are passed to the rhs
=#
@inbounds function execute!(g::Graph, rule::Rule)
    for i in 1:length(rule.matched)
        id = rule.matched[i]
        context = rule.contexts[i]
        rhs = rule.rhs(Context(g, g[id]), context...)
        replace!(static_graph(g), id, rhs)
    end
    return nothing
end

@unroll function rewrite!(g::Graph, rules)
    # Match nodes to rules and check for duplicates
    match_rules!(g, rules)
    # Execute the rules creating a new graph
    @unroll for rule in rules
        execute!(g, rule)
    end
    return nothing
end

"""
    rewrite!(g::Graph)

Apply the graph-rewriting rules stored in the graph.

## Arguments
- `g::Graph`: The graph to be rewritten. It will be modified in-place.

## Details
This function will match the left-hand sides of all the rules in a graph. If any
node is matched by more than one rule this will result in an error. The rules
are then applied in order to replaced the matched nodes with the result of
executing the right hand side of the rules. The rules are applied in the order
in which they are stored in the graph but the order in which the nodes are
processed is not defined. Since graph rewriting is semantically a parallel
process, the rules should not be rely on any particular order for their
functioning.

## Returns
This function returns `nothing`, but the graph passed as input will be modified
by the execution of the rules.

# Examples
```jldoctest
julia> struct A <: Node end;

julia> struct B <: Node end;

julia> axiom = A() + B();

julia> rule = Rule(A, rhs = x -> A() + B());

julia> g = Graph(axiom = axiom, rules = rule);

julia> rewrite!(g);
```
"""
rewrite!(g::Graph) = rewrite!(g, g.rules)
