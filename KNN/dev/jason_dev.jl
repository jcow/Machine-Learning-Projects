
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

# tally the votes for each guess
function knn_tally{T, J}(classes::Array{T,1}, weights::Array{J,1})
	tallies = Dict{T, J}()
    for i = 1:length(classes)
    	class = classes[i]
        if !haskey(tallies, class)
        	tallies[class] = 0.0
       	end

       	tallies[class] += weights[i]
    end

    winner = (classes[1], 0)
    for(class, value) = zip(keys(tallies), values(tallies))
    	if value > winner[2]
    		winner = (class, value)
    	end
   	end

   	return winner[1]
end

# get a weighted matrix
function knn_weights{T}(dists::Vector{T})
    return 1 ./ dists .^ 2
end

# main knn function
function knn{T,J}(k, D::Array{T, 2}, classes::Array{J,1}, test_points::Array{T, 2}, weighted = false)
	(mx, mn) = knn_max_min(D)
	D = knn_normalize(D, mx, mn)
	test_points = knn_normalize(test_points, mx, mn)

	weights = ones(T, size(classes)[1])

	dims = size(test_points)
	ret = Array(J, dims[1], 1)
	for i = 1:dims[1]
		observation = vec(test_points[i,:])
		dists = knn_distances(D, observation)
		indexes = sortperm(dists)
		selected_classes = classes[indexes[1:k]]

		if weighted == true
			weights = knn_weights(dists)
		end

		ret[i] = knn_tally(selected_classes, weights[indexes[1:k]])
	end

	return ret
end