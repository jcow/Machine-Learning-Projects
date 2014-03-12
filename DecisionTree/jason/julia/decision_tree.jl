# sums the values in a dictionary
function dt_sum_from_dict{T,J}(d::Dict{T,J})
	sum = 0
	for (k,v) = d
		sum += v
	end

	return sum
end

# gets the entropy for a single dictionary of counts
function dt_entropy{T, J}(counts::Dict{T,J})
	entropy = 0
	sum_of_dict = dt_sum_from_dict(counts)
	for (k,v) = counts
		entropy += (v == 0)?0:(-(v/sum_of_dict)*log2(v/sum_of_dict))
	end
	return entropy
end

# gets the entropy from the counts generated by dt_count_attr
function dt_entropy_from_counts(counts)
	entropy = 0
	total_count = 0
	for (k,v) = counts
		total_count += dt_sum_from_dict(v)
	end

	for (k1, v1) = counts
		count = dt_sum_from_dict(v1)
		entropy += (count / total_count) * dt_entropy(v1)
	end
	return entropy
end

function dt_count_attr{T}(attr::Array{T,1})
	counts = Dict()
	for i = 1:length(attr)
		if !haskey(counts, attr[i])
			counts[attr[i]] = 0
		end

		counts[attr[i]] += 1
	end

	return counts
end

# gets and returns a dict(dict(int)) of the counts for each preditor and target
function dt_count_attr{T}(predictor_attribute::Array{T,1}, target::Array{T,1})
	predict_attrs = Dict()
	for i = unique(predictor_attribute)
		predict_attrs[i] = Dict()
		for j = unique(target)
			predict_attrs[i][j] = 0
		end
	end

	for i = 1:length(target)
		predict_attrs[predictor_attribute[i]][target[i]] += 1
	end
	return predict_attrs
end

# information gain for a specific attribute
function gain{T}(predictor_attribute::Array{T,1}, target::Array{T,1})
	attribute_counts = dt_count_attr(predictor_attribute, target)
	target_counts = dt_count_attr(target)
	return dt_entropy(target_counts) - dt_entropy_from_counts(attribute_counts)
end