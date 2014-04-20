abstract Attribute

type General <: Attribute end

type Specific <: Attribute end

type Expression{T} <: Attribute
    values::Vector{T}
end

function iscompat(a::General, b::Expression) true end
function iscompat(a::Expression, b::General) true end
function iscompat(a::Specific, b::Expression) false end
function iscompat(a::Expression, b::Specific) false end
function iscompat{T}(a::Expression{T}, b::Expression{T})
    return ! (intersect(a.values, b.values) |> isempty)
end

function valueadded{T}(exp::Expression{T}, val::T)
    return Expression(union(exp.values, val))
end
function valueadded{T}(g::General, val::T)
    return Expression([val])
end
function valueadded{T}(s::Specific, val::T)
    return Expression([val])
end

type Hypothesis{T<:Attribute}
    exprs::Vector{T}
end

function hypothesis{T}(vs::Vector{T})
    exprs = [Expression([v]) for v = vs]
    return Hypothesis(exprs)
end

function general(n::Int)
    exprs = [General() for _ = 1:n]
    return Hypothesis(exprs)
end

function specific(n::Int)
    exprs = [Specific() for _ = 1:n]
    return Hypothesis(exprs)
end

type Candidate
    hypothesis::Hypothesis
    class::Bool
end

function candidate{T}(vs::Vector{T}, class::Bool)
    return Candidate(hypothesis(vs), class)
end

function isconsistent(a::Hypothesis, b::Hypothesis, class::Bool)
    return all((p) -> iscompat(p...), zip(a.exprs, b.exprs)) == class
end
function isconsistent(c::Candidate, h::Hypothesis)
    return isconsistent(h, c.hypothesis, c.class)
end

typealias HypothesisSet Vector{Hypothesis}

function onlyconsistent(hs::HypothesisSet, c::Candidate)
    map(identity, filter((h) -> isconsistent(c, h), hs))
end

# Candidate elimination algo

function candelim(cs::Vector{Candidate})
    n = length(cs[1].hypothesis.exprs)
    G = [general(n)]
    S = [specific(n)]

    for c = cs
        if c.class
            G = onlyconsistent(G, c)
        end
    end
end

# Testing

e1 = Expression([1])
e2 = Expression([1,2])
e3 = Expression([2,3])
eg = General()
es = Specific()

@assert iscompat(e1, e2)
@assert iscompat(e2, e3)
@assert ! iscompat(e1, e3)
@assert iscompat(e1, eg)
@assert ! iscompat(e1, es)

h1 = Hypothesis([e1, e2])
h2 = Hypothesis([e2, eg])
h3 = Hypothesis([e3, es])

@assert isconsistent(h1, h2, true)
@assert ! isconsistent(h1, h3, true)

c1 = Candidate(h1, true)
c2 = Candidate(h1, false)

@assert isconsistent(c1, h1)
@assert isconsistent(c1, h2)
@assert ! isconsistent(c1, h3)
@assert ! isconsistent(c2, h1)
@assert ! isconsistent(c2, h2)
@assert isconsistent(c2, h3)

c3 = candidate([1,1,2], true)
c4 = candidate([1,1,1], false)
G = general(3)
S = specific(3)

@assert isconsistent(c3, G)
@assert ! isconsistent(c4, G)
@assert ! isconsistent(c3, S)
@assert isconsistent(c4, S)

cs = [c3, c4]
candelim(cs)
