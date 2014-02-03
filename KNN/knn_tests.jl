using Base.Test
require("knn.jl")

const eps = 0.01

const train = [1.5 3.5; 2.5 4.5; 5.5 7.5; 6.5 8.5]
const classes = ["a", "a", "b", "b"]
const obsa = [2.0, 4.0]
const obsb = [6.0, 8.0]

# function knn_maxmin{T}(D::Array{T, 2})
(mx, mn) = knn_maxmin(train)
@test_approx_eq mx [6.5, 8.5]
@test_approx_eq mn [1.5, 3.5]

# function knn_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
normtrain = knn_normalize(train, mx, mn)
@test_approx_eq_eps normtrain[1,1] 0.0 eps
@test_approx_eq_eps normtrain[1,2] 0.0 eps
@test_approx_eq_eps normtrain[2,1] 0.2 eps
@test_approx_eq_eps normtrain[2,2] 0.2 eps
@test_approx_eq_eps normtrain[3,1] 0.8 eps
@test_approx_eq_eps normtrain[3,2] 0.8 eps
@test_approx_eq_eps normtrain[4,1] 1.0 eps
@test_approx_eq_eps normtrain[4,2] 1.0 eps

# function knn_normalize{T}(D::Array{T, 1}, mx::Array{T, 1}, mn::Array{T, 1})
normobsa = knn_normalize(obsa, mx, mn)
normobsb = knn_normalize(obsb, mx, mn)
@test_approx_eq_eps normobsa [0.1, 0.1] eps
@test_approx_eq_eps normobsb [0.9, 0.9] eps

# function knn_dists{T}(train::Array{T, 2}, obs::Array{T, 1})
distsa = knn_dists(train, obsa)
@test_approx_eq_eps distsa [0.707, 0.707, 4.94, 6.36] eps
distsb = knn_dists(train, obsb)
@test_approx_eq_eps distsb [6.36, 4.94, 0.707, 0.707] eps

# function knn_weights{T}(dists::Array{T, 1})
dists = [1.0, 2.0]
wtdists = knn_weights(dists)
@test_approx_eq_eps wtdists [1.0, 0.25] eps

# function knn_tally{T, J}(votes::Array{T, 1}, classes::Array{J, 1})
votes = [0.5, 1.0, 0.25]
tallyclasses = ["a", "b", "a"]
winner = knn_tally(votes, tallyclasses)
@test winner == "b"

votes = [1, 1, 1]
tallyclasses = ["a", "b", "a"]
winner = knn_tally(votes, tallyclasses)
@test winner == "a"

# function knn{T, J}(k::Int, train::Array{T, 2}, classes::Array{J, 1}, obs::Array{T, 1})
classa = knn(2, train, classes, obsa)
@test classa == "a"
classb = knn(2, train, classes, obsb)
@test classb == "b"

# function knn{T, J}(train::Array{T, 2}, classes::Array{J, 1}, obs::Array{T, 1})
classa = knn(train, classes, obsa)
@test classa == "a"
classb = knn(train, classes, obsb)
@test classb == "b"
