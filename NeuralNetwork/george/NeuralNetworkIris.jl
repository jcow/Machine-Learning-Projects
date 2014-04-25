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
net = Network([3,4,3], nattrs)
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
        println(j, ",", ntotal - ncorrect)
    end
end
