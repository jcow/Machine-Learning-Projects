
# returns the min and the max from a 2d array
function knn_max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

# normalize over the D by row with the min max of each row in mx mn
function knn_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

# function knn_dists{T}(D::Array{T,2}, obs::Array{T,1})
#     return vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, obs, D), 2)))
# end

# function knn_weighted{T}(D::Array{T,2}, obs::Array{T,1})
#     return 1 ./ knn_dists(D, obs) .^ 2
# end

# function knn(k, train, classes, obs)
#     nearest = sortperm(vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, obs, train), 2))))[1:k]
#     return mode(classes[nearest])
# end
