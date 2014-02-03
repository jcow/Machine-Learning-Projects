# KNN test driver

require("knn.jl")

fruit_data, fruit_headers = readdlm("fruit.csv", ',',  has_header=true)
training_data = convert(Array{Float64, 2}, fruit_data[1:end, 1:end-1])
classes = fruit_data[1:end, end]

# Classify each test instance and check against the given class
train_raw = readcsv("fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = train_raw[1:end, end]

test_raw = readcsv("fruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = test_raw[1:end, end]

println("k\taccuracy")
for k=[1 5 10 20 100]
    successes = 0
    failures = 0
    for i=1:100
        guess = knn(k, train_data, train_classes, vec(test_data[i, 1:end]))
        actual = test_classes[i]
        if guess == actual
            successes += 1
        else
            failures += 1
        end
    end
    accuracy = successes / (successes + failures)
    println("$k\t$accuracy")
end
