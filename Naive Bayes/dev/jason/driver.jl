require("nb.jl")

#read the training csv file and break it into the data and classes
train_raw = readcsv("data/fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = convert(Array{ASCIIString, 1}, train_raw[1:end, end])

# read the test csv file and break it into the data and classes
test_raw = readcsv("data/testFruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = convert(Array{ASCIIString, 1}, test_raw[1:end, end])

println("BinSize\tAccuracy")
for bin=[1 5 10 15 20 25 30 40 50 75 100]
	bin_count = convert(Int64, bin)
	accuracy = nb(train_data, train_classes, test_data, test_classes, bin_count)
	println("$bin\t$accuracy")
end


