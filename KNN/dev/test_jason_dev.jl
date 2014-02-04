using Base.Test
require("jason_dev.jl")

const eps = 0.01
const train = [1.5 1.5; 2.5 2.5; 4.5 4.5; 5.5 5.5]
const test_points = [2.0 2; 5 5]
const classes = ["a", "a", "b", "b"]

# Test Max Min
(mx, mn) = knn_max_min(train)
@test_approx_eq mx [5.5, 5.5]
@test_approx_eq mn [1.5, 1.5]

# Test Normalization
normalized_train = knn_normalize(train, mx, mn)
normalized_points = knn_normalize(test_points, mx, mn)
@test_approx_eq normalized_train [0 0; 0.25 0.25; 0.75 0.75; 1 1]
@test_approx_eq normalized_points [0.125 0.125; 0.875 0.875] # 1/8th and 7/8ths of the train

# Test KNN Dists
train_dists = knn_distances(normalized_train, vec(normalized_points[1,:]))
println(train_dists)


