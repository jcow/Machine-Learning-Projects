function cart_prod(sets...)
    result_size = length(sets)
    result_elems = reduce(*, 1, map(length, sets))
    result = zeros(result_elems, result_size)
    scale_factor = result_elems
    for j = 1:result_size
        set = sets[j]
        set_elems = length(set)
        scale_factor = div(scale_factor, set_elems)
        for i = 1:result_elems
            pos = div(i, scale_factor) % set_elems + 1 |> int
            result[i, j] = set[pos]
        end
    end
    return result
end

function find_insts(D::Matrix, attrs::Vector{Int}, values::Vector)
    return map(1:size(D, 1)) do i_inst
        vec(D[i_inst, attrs]) == values
    end
end

function logfac(v)
    map(1:v) do x
        log(x)
    end |> sum
end

# Variables
# ---------
# D - a data matrix, columns are attributes and rows are instantiations
# pi_i - a vector of column indices into the D matrix
# i - index of the attribute (column) in D currently being considered
# x_i - the actual column being considered

function g(D, i, pi_i)
    score = 0.0

    # Currently considered attribute values
    x_i = D[:, i]

    # All possible values of x_i
    V_i = unique(x_i)
    r_i = length(V_i)

    if length(pi_i) == 0
        # N_{ij} is the size of the entire training set
        N_ij = length(x_i)
        
        score += logfac(r_i - 1.0) - logfac(N_ij + r_i - 1.0)

        # Count training set instantiations that match each possible value of
        # x_i
        for v_c = V_i
            N_ijk = count(x -> x == v_c, x_i)
            score += logfac(N_ijk)
        end
    else
        # Get all possible parental instantiations and count how many there are
        phi_i = cart_prod([unique(D[:, k]) for k = pi_i]...) # FIXME
        q_i = size(phi_i, 1)

        for j = 1:q_i
            # All training records that match the current parental
            # instantiation
            S_v = find_insts(D, pi_i, vec(phi_i[j, :]))
            N_ij = sum(S_v)

            score += logfac(r_i - 1) - logfac(N_ij + r_i -1)

            # Count child instances in S_v
            for v_c = V_i
                N_ijk = count(x -> x == v_c, x_i[S_v])
                score += logfac(N_ijk)
            end
        end
    end

    return score
end

function argmax(f, args::Vector)
    vals = map(args) do x
        f(x)
    end
    return indmax(vals)
end

function pred(order::Vector, i::Int)
    return order[1:i-1]
end

function pred(order::Vector, i::Int, pi_i::Vector)
    return setdiff(pred(order, i), pi_i)
end

# Variables
# ---------
# order - a vector of integers that define the order in which to consider the
#         columns of D
# nodes - a vector of node names for the columns of D
# u - upper bound on the number of parents

function k2(D, nodes, order, u=2)
    parents = Dict{Int,Vector{Int}}()
    for i = order
        pi_i = []
        P_old = g(D, i, pi_i)
        ok = true
        while ok && length(pi_i) < u
            preds = pred(order, i, pi_i)
            if length(preds) == 0
                break
            end
            z = argmax(x -> g(D, i, [pi_i, x]), preds)
            P_new = g(D, i, [pi_i, preds[z]])
            if P_new > P_old
                P_old = P_new
                pi_i = [pi_i, preds[z]]
            else
                ok = false
            end
        end
        parents[i] = [pi_i, i]
    end
    return parents
end

# Variables
# ---------
# D - the dataset
# C - the classes
# tree - the structure returned by k2
# inst - the instance to be classified

function classify(D, C, tree, inst, m=-1, p=-1)
    N = size(D, 1)
    # Set up the m-estimator parameters
    if m == -1
        mval = N
    else
        mval = m
    end

    if p == -1
        pval = 1.0 / mval
    else
        pval = p
    end
    # Do the classification
    classes = unique(C)
    cls_scores = map(classes) do cls
        map(1:length(inst)) do i_node
            ns = tree[i_node]
            mc = count(x -> vec(D[x, ns]) == inst[ns] && C[x] == cls, 1:N)
            (mc + mval * p) / (N + mval)
        end |> prod
    end
    return classes[indmax(cls_scores)]
end












