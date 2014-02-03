function knn_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

function knn_normalize{T}(D::Array{T, 1}, mx::Array{T, 1}, mn::Array{T, 1})
    return (D - mn) ./ (mx - mn)
end

function knn_maxmin{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

function knn_dists{T}(train::Array{T, 2}, obs::Array{T, 1})
    tmx, tmn = knn_maxmin(train)
    normtrain = knn_normalize(train, tmx, tmn)
    normobs = knn_normalize(obs, tmx, tmn)
    return vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, transpose(normobs), normtrain), 2)))
end

function knn_weights{T}(dists::Array{T, 1})
    return 1 ./ dists .^ 2
end

function knn_tally{T, J}(votes::Array{T, 1}, classes::Array{J, 1})
    tallies = Dict{J, T}()
    for (c, v) = zip(classes, votes)
        if ! haskey(tallies, c)
            tallies[c] = 0
        end
        tallies[c] += v
    end
    winner = classes[1]
    winner_votes = votes[1]
    for (c, v) = zip(keys(tallies), values(tallies))
        if v >  winner_votes
            winner = c
            winner_votes = v
        end
    end
    return winner
end

function knn{T, J}(k::Int, train::Array{T, 2}, classes::Array{J, 1}, obs::Array{T, 1})
    dists = knn_dists(train, obs)
    nearest = sortperm(dists)[1:k]
    return knn_tally(ones(k), classes[nearest])
end

function knn{T, J}(train::Array{T, 2}, classes::Array{J, 1}, obs::Array{T, 1})
    dists = knn_dists(train, obs)
    weights = knn_weights(dists)
    return knn_tally(weights, classes)
end
