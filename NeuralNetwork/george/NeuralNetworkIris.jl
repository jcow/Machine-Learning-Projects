# NeuralNetworkIris.jl
# George Lesica
# Testing neural network on the Iris dataset.

require("NeuralNetwork.jl")

(iris_data, iris_headers) = readcsv("iris.csv", has_header=true)
nobs = size(iris_data)[1]
nattrs = length(iris_headers) - 1

# Build the sets of attributes and classes. The classes are constructed as a
# matrix with each row representing the expected output from the neural
# network.
iris_attrs = iris_data[:,1:nattrs]
iris_cls = zeros(Int, nobs, 3)
for i = 1:nobs
    clsnum = iris_data[i,nattrs+1] |> int
    iris_cls[i,clsnum] = 1
end

# Test the code by training the neural network on the entire set of data, then
# testing it against the entire set of data. This should yield a pretty high
# (crazy) rate of accuracy.
net = Network([4,4,3], nattrs)
for j = 1:1000
    # Train for one epoch
    for i = 1:nobs
        net = train(net, iris_attrs[i,:], iris_cls[i,:])
    end
    # Evaluate accuracy
    if j % 10 == 0
        ncorrect = 0
        ntotal = 0
        for i = 1:nobs
            pred = classify(net, iris_attrs[i,:])
            if pred == indmax(iris_cls[i,:])
                ncorrect += 1
            end
            ntotal += 1
        end
        #println(j, ",", ntotal - ncorrect)
    end
end

# Run 10-fold cross-validation and print the average accuracy.
# Number of rows in the dataset
N = size(iris_attrs, 1)

# First we come up with an ordering using shuffle, this determines how the rows
# will be permuted.
ordering = shuffle([1:N::Int])

# Now order the data and class names in that way.
iris_attrs = iris_attrs[ordering,:]
iris_cls = iris_cls[ordering,:]
# Choose the number of test groups and figure out the size of each group.
K = 10
group_size = N / K

# Set the number of epochs to train (determined from the experiment above).
const EPOCH_COUNT = 1000

# Specify the various network types to run
nettypes = ([3,3,3], [4,4,3], [3,3,3,3], [4,12,3])

for nettype = nettypes
    # Record the overall win/loss record
    allcorrect = 0
    alltotal = 0
    confusion = zeros(3, 3)

    println("\nNetwork type: ", nettype)
    for i = 1:K

        range_end = i * group_size
        range_start = range_end - (group_size - 1)
        test_indices = [range_start:range_end]
        train_indices = setdiff([1:N], test_indices)

        train_attrs = iris_attrs[train_indices,:]
        train_cls = iris_cls[train_indices,:]

        test_attrs = iris_attrs[test_indices,:]
        test_cls = iris_cls[test_indices,:]

        # Train up the network
        net = Network(nettype, nattrs)
        for j = 1:EPOCH_COUNT
            for i = 1:group_size
                net = train(net, train_attrs[i,:], train_cls[i,:])
            end
        end

        # Test the trained network
        ncorrect = 0
        ntotal = 0
        for i = 1:group_size
            pred = classify(net, test_attrs[i,:])
            actual = indmax(test_cls[i,:])
            if pred == actual
                ncorrect += 1
            end
            ntotal += 1
            confusion[pred, actual] += 1
        end
        allcorrect += ncorrect
        alltotal += ntotal
        println("Correct: ", ncorrect / ntotal)
    end
    println("Avg correct: ", allcorrect / alltotal)
    println("Confusion matrix:\n", confusion)
end
