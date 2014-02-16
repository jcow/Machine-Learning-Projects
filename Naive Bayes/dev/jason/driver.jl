require("nb.jl")

#read the training csv file and break it into the data and classes
train_raw = readcsv("data/fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = convert(Array{ASCIIString, 1}, train_raw[1:end, end])

(train_mx, train_mn) = nb_max_min(train_data)
train_norm = nb_zero_one_normalize(train_data, train_mx, train_mn)

# read the test csv file and break it into the data and classes
test_raw = readcsv("data/testFruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = convert(Array{ASCIIString, 1}, test_raw[1:end, end])

(test_mx, test_mn) = nb_max_min(train_data)
test_norm = nb_zero_one_normalize(test_data, test_mx, test_mn)



#guess_class = test_point(universe_counts, universe_totals, universe_dimension_counts, vec(test_norm[1,:]), bin_count)

println("accuracy")
for k=[1 5 10 15 20 25 30 40 50 75 100]
	bin_count = convert(Int64, k)
	accuracy = nb(train_norm, train_classes, test_norm, test_classes, bin_count)
	println("$k\t$accuracy")
end


