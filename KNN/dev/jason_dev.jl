using StatsBase

# returns the min and the max from a 2d array
function knn_max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

# normalize over the D by row with the min max of each row in mx mn
function normalize_data_test{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

function knn_dists{T}(D::Array{T,2}, obs::Array{T,1})
    return vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, obs, D), 2)))
end

todo - need to check for 0's
function knn_weighted{T}(D::Array{T,2}, obs::Array{T,1})
    return 1 ./ knn_dists(D, obs) .^ 2
end

function knn(k, train, classes, obs)
    nearest = sortperm(vec(sqrt(sum(broadcast((a, b) -> (a-b)^2, obs, train), 2))))[1:k]
    return mode(classes[nearest])
end

#fruit_data, fruit_headers = readdlm("fruit.csv", ',',  has_header=true)
#training_data = convert(Array{Float64, 2}, fruit_data[1:end, 1:end-1])
#classes = fruit_data[1:end, end]

# Classify each test instance and check against the given class
train_raw = readcsv("fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = train_raw[1:end, end]

test_raw = readcsv("testFruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = test_raw[1:end, end]

normalizeData(train_data)

verbose = false
println("k\taccuracy")
for k=[1 5 10 20 100]
    successes = 0
    failures = 0
    for i=1:size(test_data,1)
	guess = knn(k, train_data, train_classes, test_data[i, 1:end])
	actual = test_classes[i]
	if guess == actual
	    successes += 1
	    if verbose
		print("SUCCESS: ")
	    end
	else
	    failures += 1
	    if verbose
		print("FAILURE: ")
	    end
	end
	if verbose
	    println("Guess: $guess Actual: $actual")
	end
    end
    accuracy = successes / (successes + failures)
    println("$k\t$accuracy")
end
