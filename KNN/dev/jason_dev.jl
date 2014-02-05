
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

# get the distance from the dataset to the point
function knn_distances{T}(D::Array{T, 2}, obs::Array{T,1})
	return vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, transpose(obs), D), 2)))
end

function knn_tally{T}(classes::Array{T,1})
	tallies = Dict{T, Int64}()
    for i = 1:length(classes)
    	class = classes[i]
        if !haskey(tallies, class)
        	tallies[class] = 0
       	end

       	tallies[class] += 1
    end

    winner = (classes[1], 0)
    for(class, value) = zip(keys(tallies), values(tallies))
    	if value > winner[2]
    		winner = (class, value)
    	end
   	end

   	return winner[1]
end

function knn{T,J}(k, D::Array{T, 2}, classes::Array{J,1}, test_points::Array{T, 2})
	(mx, mn) = knn_max_min(D)
	D = knn_normalize(D, mx, mn)
	test_points = knn_normalize(test_points, mx, mn)

	dims = size(test_points)
	ret = Array(J, dims[1], 1)
	for i = 1:dims[1]
		dist = knn_distances(D, vec(test_points[i,:]))
		indexes = sortperm(dist)
		selected_classes = classes[indexes[1:k]]
		ret[i] = knn_tally(selected_classes)
	end
	return ret
end


function knn_weighted{T,J}(D::Array{T, 2}, classes::Array{J,1}, test_points::Array{T, 2})
	dims = size(test_points)

	(mx, mn) = knn_max_min(D)
	D = knn_normalize(D, mx, mn)
	test_points = knn_normalize(test_points, mx, mn)

	k = size(test_points)[1]
	ret = Array(J, dims[1], 1)
	for i = 1:dims[1]
		dist = knn_distances(D, vec(test_points[i,:]))
		indexes = sortperm(dist)
		selected_classes = classes[indexes[1:k]]
		ret[i] = knn_tally(selected_classes)
	end
	return ret
end

function knn_weights{T}(D::Array{T, 2}, obs::Array{T,1})
	return 1 ./ knn_distances(D, obs) .^2
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
