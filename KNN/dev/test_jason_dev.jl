using Base.Test
require("jason_dev.jl")

const eps = 0.01
const train = [1.5 1.5; 2.5 2.5; 4.5 4.5; 5.5 5.5]
const classes = ["a", "a", "b", "b"]

# Test Max Min
(mx, mn) = knn_max_min(train)
@test_approx_eq mx [5.5, 5.5]
@test_approx_eq mn [1.5, 1.5]

# Test Normalization
normalized_train = knn_normalize(train, mx, mn)
@test_approx_eq normalized_train [0 0; 0.25 0.25; 0.75 0.75; 1 1]
