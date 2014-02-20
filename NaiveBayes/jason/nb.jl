# Jason Cowan
# Spring 2014
# Naive Bayes
# Machine Learning

# calculate the min and the max of the data
function nb_max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

# normalize over the D by row with the min max of each column in mx mn
function nb_zero_one_normalize{T}(D::Array{T, 2})
    mx,mn = nb_max_min(train_data)
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

# maps a value that's been normalized to a bin
function nb_map_to_bin(value, bin_count)
    return value * (bin_count - 1) + 1 |> ceil |> int 
end

# returns the percentage correct from guesses vs actual
function nb_percentage_correct{T}(guesses::Array{T,1}, actual::Array{T,1})
  guess_length = length(guesses)
  tf = [guesses[i] == actual[i] ? 1 : 0 for i = 1:guess_length] |> sum
  return  tf / guess_length
end

# find the maximum value from a string,number dictionary
function nb_find_max_from_dict{T,D}(estimates::Dict{T,D})
  mx = ("", 0)
  for (class, value) = zip(keys(estimates), values(estimates))
    if value > mx[2]
      mx = (class, value)
    end
  end
  return mx
end

# get the setup for the universe
function nb_make_universe{T,S,D}(data::Array{T,2}, classes::Array{S, 1}, bin_count::D)

  # set the dimensions
  data_dims = size(data)

  # the bin counts by Dict[class][dimension][bin]
  universe_counts = Dict{ASCIIString, Array{T,2}}()

  # the totals for in each dimension in each bin
  universe_dimension_counts = zeros(T, data_dims[2], bin_count)

  # the totals for each class
  universe_totals = Dict{ASCIIString, D}()

  # iterate over the rows and set the counts for everything
  for i = 1:data_dims[1]
    # set the observation and the class
    observation  = data[i,:]
    class = classes[i]

    # make the universe bin for a specic class, 2d array of zeros
    if !haskey(universe_counts, class)
      universe_counts[class] = zeros(Float64, data_dims[2], bin_count)
    end

    # set the universe total for a class to 0
    if !haskey(universe_totals, class)
      universe_totals[class] = 0
    end

    #add to the universe bin counts
    for j = 1:length(observation)
      bin_index = nb_map_to_bin(observation[j], bin_count)
      universe_counts[class][j, bin_index] += 1
      universe_dimension_counts[j, bin_index] += 1
    end

    # add to the bin number at the specific dimension
    universe_totals[class] += 1
  end

  return (universe_counts, universe_dimension_counts, universe_totals)
end

# m estimator
# n is the number of a specific class in a bin
# nc is the total number of items in the bin
# N is the total number of items for a specific class
function nb_m_estimate(n, nc, N)
    return (n + 1) / (nc + N)
end

# test a single test_point for classification
function test_point{T,D,S}(
                  universe_counts::Dict{T,Array{D,2}}, 
                  universe_totals::Dict{T,S}, 
                  universe_dimension_counts::Array{D,2},
                  test_point::Array{D,1}, 
                  bin_count::S
  )

  # estimates is the dictionary that will hold the class=>val to predict the class
  estimates = Dict{T,D}()

  # foreach class, do an m estimation
  for (class, dims_n_bin) = universe_counts

    estimates[class] = 1

    # iterate over each of the dimensions for a point
    for i = 1:length(test_point)

      # get the bin index in which the value falls into
      matching_bin_index = nb_map_to_bin(test_point[i], bin_count)
      
      # default estimate is 1/N
      m_estimate = nb_m_estimate(0, 0, universe_totals[class])

      # if not outside of the bounds of the training set find the m estimate
      if (1 <= matching_bin_index && matching_bin_index <= bin_count)
        m_estimate = nb_m_estimate(
                  dims_n_bin[i,matching_bin_index],
                  universe_dimension_counts[i, matching_bin_index],
                  universe_totals[class]
              )
      end

      # multiply the classes m estimate into the estimator
      estimates[class] *= m_estimate
      
    end
  end

  # find the maximum value and return the class associated with it
  max_val = nb_find_max_from_dict(estimates)
  return max_val[1]
end


# main naive bayes function
# train_data - 2d array of training data
# train_classes - 1d array of classes associated with the train_data
# test_data - 2d array of the test_data
function nb{T,S}(
  train_data::Array{T,2}, 
  train_classes::Array{S,1}, 
  test_data::Array{T,2}, 
  test_classes::Array{S,1}, 
  bin_count)

  # normalize the data for easy binning
  norm_train_data = nb_zero_one_normalize(train_data)
  norm_test_data = nb_zero_one_normalize(test_data)

  # get the counts needed for the universe
  (universe_counts, universe_dimension_counts, universe_totals) = nb_make_universe(norm_train_data, train_classes, bin_count)


  # loop through each test point and attempt to classify
  test_dims = size(norm_test_data)
  guesses = Array(ASCIIString, test_dims[1])
  for i = 1:test_dims[1]
    guesses[i] = test_point(universe_counts, universe_totals, universe_dimension_counts, vec(norm_test_data[i,:]), bin_count)
  end

  return nb_percentage_correct(guesses, test_classes)
end




