function knn_normalize{T}(D::Matrix{T}, mx::Vector{T}, mn::Vector{T})
    # Map over the rows and weight them based on the max and min values given.
    # Note that the actual function evaluation is vectorized.
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

function knn_normalize{T}(D::Vector{T}, mx::Vector{T}, mn::Vector{T})
    return (D - mn) ./ (mx - mn)
end

function knn_maxmin{T}(D::Matrix{T})
    # Map over the columns and find the max and min of each. Return the max and
    # min vectors as a tuple.
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

function knn_dists{T}(train::Matrix{T}, obs::Vector{T})
    # This is a bit dense (concise). Basically, map the squred difference
    # function, in a vectorized manner, down the training set, reusing the
    # instance vector each time. Then sum the distances in each dimension and
    # take the square root. Turn the result into a vector.
    return vec(sqrt(sum(broadcast((a, b) -> (a-b).^2, transpose(obs), train), 2)))
end

function knn_weights{T}(dists::Vector{T})
    return 1 ./ dists .^ 2
end

function knn_tally{T, J}(votes::Vector{T}, classes::Vector{J})
    # Create a running tally of the votes for each class, adding classes to the
    # dictionary as they are discovered.
    tallies = Dict{J, T}()
    for (c, v) = zip(classes, votes)
        if ! haskey(tallies, c)
            tallies[c] = 0
        end
        tallies[c] += v
    end
    # Iterate through the dictionary and find the class with the most votes.
    winner::J = classes[1]
    winner_votes::T = votes[1]
    for (c, v) = zip(keys(tallies), values(tallies))
        if v >  winner_votes
            winner = c
            winner_votes = v
        end
    end
    return winner
end

function knn{T, J}(k::Int, train::Matrix{T}, classes::Vector{J}, obs::Vector{T}, weighted=false)
    tmx, tmn = knn_maxmin(train)
    normtrain = knn_normalize(train, tmx, tmn)
    normobs = knn_normalize(obs, tmx, tmn)
    normdists = knn_dists(normtrain, normobs)
    nearest = sortperm(normdists)[1:k]
    if weighted
        normweights = knn_weights(normdists)
    else
        normweights = ones(length(normdists))
    end
    return knn_tally(normweights[nearest], classes[nearest])
end

function knn{T, J}(train::Matrix{T}, classes::Vector{J}, obs::Vector{T})
    return knn(size(train, 1), train, classes, obs, true)
end
