# Jason Cowan
# Spring 2014
# Naive Bayes
# Machine Learning

using Base.Test
require("nb.jl")

# test percentage_correct
function test_nb_percentage_correct()
	guesses = ["a", "b", "c", "c", "b"]
	actual = ["a", "c", "c", "c", "b"]
	percentage_correct = nb_percentage_correct(guesses, actual)
	@test_approx_eq percentage_correct 0.8
end

# test the mapping to bin
function test_nb_map_to_bin()
	bin1 = nb_map_to_bin(0.5, 10)
	bin2 = nb_map_to_bin(0.2, 100)
	bin3 = nb_map_to_bin(0.8, 1000)

	@test bin1 == 6
	@test bin2 == 21
	@test bin3 == 801
end

# test finding the max from a dictionary
function test_nb_find_max_from_dict()
	dict1 = {"a"=>1, "b"=>4, "c"=>2}
	vals1 = nb_find_max_from_dict(dict1)
	@test vals1[1] == "b"
	@test vals1[2] == 4
end



test_nb_percentage_correct()
test_nb_map_to_bin()
test_nb_find_max_from_dict()