# First define a type (think of it as a struct in C or sort of a class in OOPy
# languages. The type will hold all the information necessary for classifying
# based on the given training data. Eventually, it will could also hold a cache
# to speed up repeated classification as well.
type NBModel{V<:Number, C}
    # The first type parameter is the type of the data being classified. The
    # second is the type of the class names themselves (often a string, I
    # suppose).
    bins::Array{Int, 3}
    bin_widths::Vector{V}
    attrib_names::Vector{ASCIIString}
    attrib_mins::Vector{V}
    attrib_maxs::Vector{V}
    attrib_probs::Matrix{FloatingPoint}
    class_names::Vector{C}
    class_counts::Vector{Int}
    class_probs::Vector{FloatingPoint}
    train_values::Matrix{V}
    train_classes::Vector{C}
end

# This is a constructor function that builds an instance of the type defined
# above given the a matrix of training data, a list of classes, a list of
# attribute names (like "yellowness" or whatever) and a list specifying how
# many bins to create for each dimension. The @assert lines are macros that
# check that the dimensions all agree.
function NBModel{V, C}(data::Matrix{V}, class_data::Vector{C},
        attrib_names::Vector{ASCIIString}, nbins::Int)
    @assert size(data, 1) == length(class_data)
    @assert size(data, 2) == length(attrib_names)

    nclasses = length(unique(class_data))
    nattribs = length(attrib_names)
    nobs = size(data, 1)

    attrib_mins = [minimum(data[:, i]) for i = 1:length(attrib_names)]
    attrib_maxs = [maximum(data[:, i]) for i = 1:length(attrib_names)]
    attrib_probs = ones(FloatingPoint, nattribs, nbins) # Not ready until after loop

    class_names = sort(unique(class_data))
    class_counts = zeros(Int, nclasses) # Not ready until after loop
    class_probs = ones(FloatingPoint, nclasses) # Not ready until after loop

    bins = zeros(Int, nclasses, nattribs, nbins) # Not ready until after loop
    bin_widths = 1.0 .* (attrib_maxs - attrib_mins) ./ nbins

    # Fill bins and class_counts
    for obsi = 1:nobs
        clsi = findin(class_names, [class_data[obsi]]) |> first
        class_counts[clsi] += 1
        binis = max(1, (vec(data[obsi, :]) - attrib_mins) ./ bin_widths |> ceil |> int)
        @assert all(1 .<= binis .<= nbins)
        for attri = 1:nattribs
            bins[clsi, attri, binis[attri]] += 1
        end
    end

    # Fill attrib_probs
    for attri = 1:nattribs
        for bini = 1:nbins
            s = 0
            for clsi = 1:nclasses
                s += bins[clsi, attri, bini]
            end
            attrib_probs[attri, bini] = 1.0 * s / nobs
        end
    end

    # Fill class_probs
    for clsi = 1:nclasses
        class_probs[clsi] = 1.0 * class_counts[clsi] / sum(class_counts)
    end

    return NBModel(bins, bin_widths, attrib_names, attrib_mins, attrib_maxs,
            attrib_probs, class_names, class_counts, class_probs, data, class_data)
end

function nb_bininds{V<:Number, C}(model::NBModel{V, C}, inst::Vector{V})
    (inst - model.attrib_mins) ./ model.bin_widths |> ceil |> int
end

# Computes the score for a given instance and a given class. This is the
# function we argmax over.
function nb_score{V<:Number, C}(model::NBModel{V, C}, inst::Vector{V}, cls::C,
        m::Number, p::Number)
    ncls = size(model.bins, 1)
    nattr = size(model.bins, 2)
    nbin = size(model.bins, 3)

    clsi = findin(model.class_names, [cls]) |> first
    binis = nb_bininds(model, inst)

    attrib_scores = zeros(FloatingPoint, nattr)
    for (attri, bini) = enumerate(binis)
        if ! (1 <= bini <= nbin)
            n = 0
            n_c = 0
        else
            n = model.bins[clsi, attri, bini]
            n_c = [model.bins[i, attri, bini] for i = 1:ncls] |> sum
        end
        attrib_scores[attri] = (n + m * p) / (n_c + m)
    end

    return attrib_scores |> prod
end

# Classification function that accepts a model, a class, and (optionally)
# values for m and p to be used for the m-estimator. It maximizes over the
# possible classes and returns the class with the highest score.
function nb_classify{V<: Number, C}(model::NBModel{V, C}, inst::Vector{V},
        m::Number=-1, p::Number=-1)
    max_score = 0.0
    max_cls = model.class_names[1]

    if m == -1
        mval = size(model.train_values, 1) |> float
    else
        mval = m
    end

    if p == -1
        pval = 1.0 / mval
    else
        pval = p
    end

    for cls = model.class_names
        score = nb_score(model, inst, cls, mval, pval)
        if score > max_score
            max_score = score
            max_cls = cls
        end
    end
    return max_cls
end
