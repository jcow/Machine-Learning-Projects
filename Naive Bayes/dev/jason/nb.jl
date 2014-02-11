function max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

# normalize over the D by row with the min max of each column in mx mn
function zero_one_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end


# read the training csv file and break it into the data and classes
train_raw = readcsv("data/fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = train_raw[1:end, end]

(train_mx, train_mn) = max_min(train_data)
train_norm = zero_one_normalize(train_data, train_mx, train_mn)

# read the test csv file and break it into the data and classes
test_raw = readcsv("data/testFruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = test_raw[1:end, end]

(test_mx, test_mn) = max_min(train_data)
test_norm = zero_one_normalize(test_data, test_mx, test_mn)



bin_count = 100

universe = Dict()
train_dims = size(train_norm)
for i = 1:train_dims[1]
	observation  = train_norm[i]
	class = train_classes[i]

	# make the bins
    if !haskey(universe, class)
    	universe[class] = zeros(Float64, train_dims[2], bin_count)
   	end


   	#add to the correct bins
   	for j = 1:length(observation)
   		universe[class][j, ceil(observation[j]*(bin_count-1)+1)] += 1
   	end

end
for i = 1:4
	println(universe["lemon"][i][1])
	println(universe["lemon"][i][end])
end



