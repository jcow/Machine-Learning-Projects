using Base.Test
require("nb.jl")

# test percentage_correct
function test_nb_percentage_correct()
	guesses = ["a", "b", "c", "c", "b"]
	actual = ["a", "c", "c", "c", "b"]
	percentage_correct = nb_percentage_correct(guesses, actual)
	@test_approx_eq percentage_correct 0.8
end

function test_nb_map_to_bin()
	bin1 = nb_map_to_bin(0.5, 10)
	bin2 = nb_map_to_bin(0.2, 100)
	bin3 = nb_map_to_bin(0.8, 1000)

	@test bin1 == 6
	@test bin2 == 21
	@test bin3 == 801
end


function test_nb_find_max_from_dict()
	dict1 = {"a"=>1, "b"=>4, "c"=>2}
	vals1 = nb_find_max_from_dict(dict1)
	@test vals1[1] == "b"
	@test vals1[2] == 4
end

function test_nb_make_universe()
	d = [1 2 3; 1 2 3; 4 5 6]
	mx,mn = nb_max_min(d)

	data = nb_zero_one_normalize(d, mx, mn)
	classes = ["a","a","b"]
	bin_size = 10

	universe_counts, universe_dimension_counts, universe_totals = nb_make_universe(data, classes, bin_size)
	# todo...
end




test_nb_percentage_correct()
test_nb_map_to_bin()
test_nb_find_max_from_dict()
test_nb_make_universe()