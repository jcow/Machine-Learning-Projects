# Naive Bayes test driver

require("naivebayes.jl")

# Load the training data and break apart the CSV file into its component parts.
train_data = readcsv("data/fruit.csv")
train_values = convert(Matrix{Float64}, train_data[2:end, 1:end-1])
train_classes = convert(Vector{ASCIIString}, train_data[2:end, end])
train_attribs = convert(Vector{ASCIIString}, vec(train_data[1, 1:end-1]))

test_data = readcsv("data/testFruit.csv")
test_values = convert(Matrix{Float64}, test_data[2:end, 1:end-1])
test_classes = convert(Vector{ASCIIString}, test_data[2:end, end])

# Construct a model instance, splitting each dimension into 10 bins.
for nbins = [10, 20, 50, 100]
    nb = NBModel(train_values, train_classes, train_attribs, nbins)
    total = 0
    right = 0
    wrong = 0
    for i = 1:size(test_values, 1)
        inst = vec(test_values[i, :])
        cls = nb_classify(nb, inst)
        if cls == test_classes[i]
            right += 1
        else
            wrong += 1
        end
        total += 1
    end
    pct = 100.0 * right / total |> int
    println(pct, "% correct with ", nbins, " bins")
end
