# Bayes Network test driver

require("BayesNet.jl")

data_raw = readcsv("forestFireData.csv")

# The dataset without classes
D = convert(Array{Int, 2}, data_raw[2:end, 1:end-1])
# The classes column
C = data_raw[2:end, end]
# The node names
nodes = data_raw[1, 1:end-1] |> vec
# Number of rows in the dataset
N = size(D, 1)

# First we come up with an ordering using shuffle, this determines how the rows
# will be permuted.
ordering = shuffle([1:length(C)::Int])

# Now order the data and class names in that way.
D = D[ordering, :]
C = C[ordering]

# Choose the number of test groups and figure out the size of each group.
K = 10
group_size = N / K

confusion = [0 0; 0 0]
for i = 1:K
    range_end = i * group_size
    range_start = range_end - (group_size - 1)
    test_indices = [range_start:range_end]
    train_indices = setdiff([1:N], test_indices)
    println(length(test_indices))

    # First do the training
    train_data = D[train_indices, :]
    train_classes = C[train_indices]
    order = [1:length(nodes)]

    # Shuffle the node order and run multiple times
    node_orders = map(permutations(order)) do x
        x
    end |> shuffle
    for i_order = 1:1
        order = node_orders[i_order]

        tree = k2(train_data, nodes, order)

        # Now the testing happens
        test_data = D[test_indices, :]
        test_classes = C[test_indices]
        correct = 0
        total = 0
        for i_test = 1:size(test_data, 1)
            inst = test_data[i_test, :] |> vec
            cls = classify(train_data, train_classes, tree, inst)
            true_cls = test_classes[i_test]
            if cls == true_cls
                correct += 1
            end
            total += 1
            confusion[true_cls + 1, cls + 1] += 1
        end
        # Record the accuracy for this test iteration
        println("Accuracy for group ", i - 1, " network ", i_order - 1, ": ", 1.0 * correct / total)
    end
end

println(confusion)
