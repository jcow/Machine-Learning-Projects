function nb_max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end


# normalize over the D by row with the min max of each column in mx mn
function nb_zero_one_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

function nb_map_to_bin(value, bin_count)
    return value * (bin_count - 1) + 1 |> ceil |> int 
end


function nb_percentage_correct{T}(guesses::Array{T,1}, actual::Array{T,1})
  successes = 0
  failures = 0
  for i = 1:length(guesses)
        if guesses[i] == actual[i]
            successes += 1
        else
            failures += 1
        end
  end
  return successes / (successes + failures)
end


function nb_find_max_from_dict{T,D}(estimates::Dict{T,D})
  mx = ("", 0)
  for (class, value) = zip(keys(estimates), values(estimates))
    if value > mx[2]
      mx = (class, value)
    end
  end
  return mx
end


function nb_make_universe{T,S,D}(data::Array{T,2}, classes::Array{S, 1}, bin_count::D)

  data_dims = size(data)

  universe_counts = Dict{ASCIIString, Array{T,2}}()
  universe_dimension_counts = zeros(T, data_dims[2], bin_count)
  universe_totals = Dict{ASCIIString, D}()

  for i = 1:data_dims[1]
    observation  = data[i,:]
    class = classes[i]

    # make the bins
    if !haskey(universe_counts, class)
      universe_counts[class] = zeros(Float64, data_dims[2], bin_count)
    end

    # add to the universe totals
    if !haskey(universe_totals, class)
      universe_totals[class] = 0
    end

    #add to the bin counts
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


function nb_m_estimate(n, nc, N)
    return (n + 1) / (nc + N)
end


function test_point{T,D,S}(
                  universe_counts::Dict{T,Array{D,2}}, 
                  universe_totals::Dict{T,S}, 
                  universe_dimension_counts::Array{D,2},
                  test_point::Array{D,1}, 
                  bin_count::S
  )

  estimates = Dict{T,D}()
  for (class, dims_n_bin) = universe_counts
    estimates[class] = 1
    for i = 1:length(test_point)
      matching_bin_index = nb_map_to_bin(test_point[i], bin_count)
      
      m_estimate = 1
      if (1 <= m_estimate && m_estimate <= matching_bin_index)
        m_estimate = nb_m_estimate(
                  dims_n_bin[i,matching_bin_index],
                  universe_dimension_counts[i, matching_bin_index],
                  universe_totals[class]
              )
      end

      estimates[class] *= m_estimate
      
    end
  end

  max_val = nb_find_max_from_dict(estimates)
  return max_val[1]
end


function nb{T,S}(
  train_data::Array{T,2}, 
  train_classes::Array{S,1}, 
  test_data::Array{T,2}, 
  test_classes::Array{S,1}, 
  bin_count)

  (universe_counts, universe_dimension_counts, universe_totals) = nb_make_universe(train_data, train_classes, bin_count)

  test_dims = size(test_data)

  guesses = Array(ASCIIString, test_dims[1])
  for i = 1:test_dims[1]
    guesses[i] = test_point(universe_counts, universe_totals, universe_dimension_counts, vec(test_data[i,:]), bin_count)
  end

  return nb_percentage_correct(guesses, test_classes)
end




