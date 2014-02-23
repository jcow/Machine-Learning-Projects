using Base.Test
require("decision_tree.jl")

const eps = 0.01
const predictors = readcsv("test_data/predictors.csv")
const target = vec(readcsv("test_data/target.csv"))


# test entropy
const entropy1 = dt_entropy(["yes"=>9, "no"=>5])
@test_approx_eq_eps entropy1 0.94 eps

const entropy2 = dt_entropy(["a"=>5, "b"=>5])
@test entropy2 == 1


# test the attribute entropy function
const attr_counts = dt_count_attr(vec(predictors[:,1]), target)
@test attr_counts["rainy"]["yes"] == 2
@test attr_counts["rainy"]["no"] == 3
@test attr_counts["sunny"]["yes"] == 3
@test attr_counts["sunny"]["no"] == 2
@test attr_counts["overcast"]["yes"] == 4
@test attr_counts["overcast"]["no"] == 0


# test the counts for entropy for a single class
const entropy_from_counts = dt_entropy_from_counts([
	"sunny"=>["yes"=>3, "no"=>2],
	"overcast"=>["yes"=>4, "no"=>0],
	"rainy"=>["yes"=>2, "no"=>3]
])
@test_approx_eq_eps entropy_from_counts 0.693 0.001
