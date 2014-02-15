function max_min{T}(D::Array{T, 2})
    mx = vec(mapslices(maximum, D, 1))
    mn = vec(mapslices(minimum, D, 1))
    return mx, mn
end

# normalize over the D by row with the min max of each column in mx mn
function zero_one_normalize{T}(D::Array{T, 2}, mx::Array{T, 1}, mn::Array{T, 1})
    return mapslices(x -> (x - mn) ./ (mx - mn), D, 2)
end

function map_to_bin(value, bin_count)
  println("***")
  println(value)
  println(bin_count)
  println("***")
    return ceil(value*(bin_count-1)+1)
end

function percentage_correct{T}(guesses::Array{T,1}, actual::Array{T,1})
  successes = 0
  failures = 0
  for i = 1:length(guesses)
        if guesses[i] == test_classes[i]
            successes += 1
        else
            failures += 1
        end
  end
  return successes / (successes + failures)
end

# read the training csv file and break it into the data and classes
train_raw = readcsv("data/fruit.csv")[2:end, 1:end]
train_data = convert(Array{Float64, 2}, train_raw[1:end, 1:end-1])
train_classes = train_raw[1:end, end]

(train_mx, train_mn) = max_min(train_data)
train_norm = zero_one_normalize(train_data, train_mx, train_mn)

# read the test csv file and break it into the data and classes
test_raw = readcsv("data/testFruit.csv")[2:end, 1:end]
test_data = convert(Array{Float64, 2}, test_raw[1:end, 1:end-1])
test_classes = convert(Array{ASCIIString, 1}, test_raw[1:end, end])

(test_mx, test_mn) = max_min(train_data)
test_norm = zero_one_normalize(test_data, test_mx, test_mn)



bin_count = convert(Int64, 20)
train_dims = size(train_norm)

#####
# Make the universe
#####
universe_totals = Dict{ASCIIString, Int64}()
universe_dimension_counts = zeros(Float64, train_dims[2], bin_count)
universe_counts = Dict{ASCIIString, Array{Float64,2}}()


for i = 1:train_dims[1]
	observation  = train_norm[i,:]
	class = train_classes[i]

  # make the bins
  if !haskey(universe_counts, class)
    universe_counts[class] = zeros(Float64, train_dims[2], bin_count)
  end

  # add to the universe totals
  if !haskey(universe_totals, class)
    universe_totals[class] = 0
  end


  #add to the bin counts
  for j = 1:length(observation)
    bin_index = map_to_bin(observation[j], bin_count)

    universe_counts[class][j, bin_index] += 1
    universe_dimension_counts[j, bin_index] += 1
  end

  # add to the bin number at the specific dimension
  universe_totals[class] += 1

end


function test_point{T,D,S}(
                  universe_counts::Dict{T,Array{D,2}}, 
                  universe_totals::Dict{T,S}, 
                  universe_dimension_counts::Array{D,2},
                  test_point::Array{D,1}, 
                  bin_count::S
  )

  estimates = Dict{T,D}()
  for (class, dims_n_bin) = zip(keys(universe_counts), values(universe_counts))
    estimates[class] = 1
    for i = 1:length(test_point)
      matching_bin_index = map_to_bin(test_point[i], bin_count)
      m_estimate = 1
      println(i)
      println(matching_bin_index)
      println("----")
      if matching_bin_index < 1 || matching_bin_index > bin_count
        m_estimate = 1
      else
        m_estimate = (
            (dims_n_bin[i,matching_bin_index] + 1)
            / (universe_dimension_counts[i, matching_bin_index] + universe_totals[class])
        )
      end
      estimates[class] *= m_estimate
    end
  end

  max_val = 0
  max_class = ""
  for (class, value) = zip(keys(estimates), values(estimates))
    if value > max_val
      max_val = value
      max_class = class
    end
  end

  return max_class
end

#####
# Do some testing against the universe
#####

#guess_class = test_point(universe_counts, universe_totals, universe_dimension_counts, vec(test_norm[1,:]), bin_count)

test_dims = size(test_norm)
guesses = Array(ASCIIString, test_dims[1])
for i = 1:test_dims[1]
  println("I = $i")
  guesses[i] = test_point(universe_counts, universe_totals, universe_dimension_counts, vec(test_norm[i,:]), bin_count)
end

println("accuracy")
println(percentage_correct(guesses, test_classes))

