# KNN test driver
require("knn.jl")

# read the training csv file and break it into the data and classes
train_raw = readcsv("data/fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = train_raw[1:end, end]

# read the test csv file and break it into the data and classes
test_raw = readcsv("data/testFruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = test_raw[1:end, end]
# Jason Cowan
# ML Spring 2014

# iterate over the specified k's and print out the results for the unweighted knn
println("Non-weighted")
println("k\taccuracy")
for kVal=[1 5 10 20 100 1000]
    successes = 0
    failures = 0

    # the guesses are a vector where each data point has been classified
    guesses = knn(kVal, train_data, train_classes, test_data)
    for i = 1:length(guesses)
        if guesses[i] == test_classes[i]
            successes += 1
        else
            failures += 1
        end
    end

    # print out the accuracy
    accuracy = successes / (successes + failures)
    println("$kVal\t$accuracy")
end


# iterate over the specified k's and print out the results for the unweighted knn
println("")
println("Weighted Accuracy")
println("k\taccuracy")
for kVal=[1 5 10 20 100 1000]
    successes = 0
    failures = 0

    # the guesses are a vector where each data point has been classified
    guesses = knn(kVal, train_data, train_classes, test_data, true)
    for i = 1:length(guesses)
        if guesses[i] == test_classes[i]
            successes += 1
        else
            failures += 1
        end
    end

    # print out the accuracy
    accuracy = successes / (successes + failures)
    println("$kVal\t$accuracy")
end

