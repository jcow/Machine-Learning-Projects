
type Attr
    vals
    data
end

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

function cart_prod(attrs::Attr...)
    vals_list = [a.vals for a = attrs]
    return cart_prod(vals_list...)
end

function find_insts(attrs::Vector{Attr}, values::Vector)
    @assert length(attrs) == length(values)
    n = length(attrs)
    final = trues(n)
    for i = 1:n
        final = final & (attrs[i].data .== values[i])
    end
    return final
end

function g(i, pi_i)
    score = 1

    # All possible values of x_i
    V_i = unique(x_i)
    r_i = length(V_i)

    if length(pi_i) == 0
        # N_{ij} is the size of the entire training set and S_v is the entire
        # training set
        N_ij = length(x_i)
        S_v = D
        
        score *= factorial(r_i - 1) / factorial(N_ij + r_i - 1)

        # Count training set instantiations that match each possible value of
        # x_i
        for v_c = V_i
            N_ijk = count(x -> x == v_c, x_i)
            score *= factorial(N_ijk)
        end
    else
        # Get all possible parental instantiations and count how many there are
        phi_i = cart_prod(pi_i...)
        q_i = size(phi_i, 1)

        for j = 1:q_i
            # All training records that match the current parental
            # instantiation
            S_v = find_insts(pi_i, vec(phi_i[i, :]))
            # ^
            # TODO: maybe just use matrices instead of vector of Attr objects? pass
            # in a column index (or vector of column indices in case of pi_i)
            # instead of the actual Attr objects, so everything just references
            # the dataset D, which would be a matrix
            N_ij = length(S_v)

            score *= factorial(r_i - 1) / factorial(N_ij + r_i - 1)

            # Count child crap
            for v_c = V_i
                # TODO
            end
        end
    end
end








