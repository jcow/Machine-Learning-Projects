using Base.Test
require("jason_dev.jl")

const eps = 0.01
const train = [1.5 1.5; 2.5 2.5; 4.5 4.5; 5.5 5.5]
const test_points = [2.0 2; 5 5]
const classes = ["a", "a", "b", "b"]


#----------------------
# Test Max Min
#----------------------
(mx, mn) = knn_max_min(train)
@test_approx_eq mx [5.5, 5.5]
@test_approx_eq mn [1.5, 1.5]

#----------------------
# Test Normalization
#----------------------
normalized_train = knn_normalize(train, mx, mn)
normalized_points = knn_normalize(test_points, mx, mn)
@test_approx_eq normalized_train [0 0; 0.25 0.25; 0.75 0.75; 1 1]
@test_approx_eq normalized_points [0.125 0.125; 0.875 0.875] # 1/8th and 7/8ths of the train

#----------------------
# Test Tallies
#----------------------
const tallies = knn_tally(["a", "a", "b", "b", "b"])
@test tallies == "b"

const tallies2 = knn_tally(["a", "b" ,"c", "b"])
@test tallies2 == "b"

const tallies3 = knn_tally(["a", "a", "b", "b"])
@test tallies3 == "b"

#----------------------
# Test KNN Dists
#----------------------
const random_test_dists = knn_distances([1 1; 3 3], vec([2 2]))
@test_approx_eq_eps random_test_dists [1.41,1.41] eps

const classified = knn(2, train, classes, test_points)
@test classified[1] == "a"
@test classified[2] == "b"

const classified2 = knn(3, [1 1; 2 2; 3 3], ["a", "b", "a"], [2 3])
@test classified2[1] == "a"

const classified3 = knn(1, [1 1; 2 2; 8 8;], ["a", "b", "c"], [2 3])
@test classified3[1] == "b"


#------------------
# Test Weights
#------------------
const found_weight = knn_weights([1.0 2; 2 2], vec([1.0 1]))
@test_approx_eq_eps found_weight [1, 0.49] eps

