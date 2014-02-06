# returns the min and the max of each column of a 2D array
function knn_max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

# normalize over the D by row with the min max of each column in mx mn
function knn_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

# get the distance between each value in D from obs
function knn_distances{T}(D::Array{T, 2}, obs::Array{T,1})
	return vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, transpose(obs), D), 2)))
end

# tally the votes for each guess
function knn_tally{T, J}(classes::Array{T,1}, weights::Array{J,1})

	# use the dict to count each classes vote
	tallies = Dict{T, J}()
    for i = 1:length(classes)
    	class = classes[i]
        if !haskey(tallies, class)
        	tallies[class] = 0.0
       	end

       	# add to the tallies the vote's weight
       	tallies[class] += weights[i]
    end

    # default the winner to the first value
    winner = (classes[1], 0)

    # iterate over the dictionary to find highest voted class
    for(class, value) = zip(keys(tallies), values(tallies))
    	if value > winner[2]
    		winner = (class, value)
    	end
   	end

   	return winner[1]
end

# get a weighted matrix by doing 1/distances^2
function knn_weights{T}(dists::Vector{T})
    return 1 ./ dists .^ 2
end

# main knn function
# this function can be called either by a standard knn vote or
# by a 1/dist^2 vote
# @param k - the amount of k's you want to count
# @param D - the array of data
# @param classes - the array of classes
# @param test_points - the array of test points to be classified
# @param weighted - whether or not to run the weighted knn
function knn{T,J}(k, D::Array{T, 2}, classes::Array{J,1}, test_points::Array{T, 2}, weighted = false)
	# get the max min of the data
	(mx, mn) = knn_max_min(D) 

	# normalize the data 
	D = knn_normalize(D, mx, mn)

	# normalize the test points
	test_points = knn_normalize(test_points, mx, mn)

	# set weights to 1 by default
	weights = ones(T, size(classes)[1])

	# set the dimensions of the test points so iteration can be done
	dims = size(test_points)

	# populate a blank array to set results to
	ret = Array(J, dims[1], 1)

	# iterate over the test points
	for i = 1:dims[1]
		# find the dists to a point
		observation = vec(test_points[i,:])
		dists = knn_distances(D, observation)

		# get the sorted indexes
		indexes = sortperm(dists)

		# set the classes based on the indexes
		selected_classes = classes[indexes[1:k]]

		# if weighted, reset the weights
		if weighted == true
			weights = knn_weights(dists)
		end

		# set the classified item to the return array
		ret[i] = knn_tally(selected_classes, weights[indexes[1:k]])
	end

	# return it
	return ret
end