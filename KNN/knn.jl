# determine a one-dimensional array of indicies by their distance to the passed in point
function old_dist(point, data)
        # creates a matrix of floating point zeros of the data size
        d = zeros(FloatingPoint, size(data,1))

        # loop through the entire 0 matrix
	for i = 1:length(d)
                # loop through the columns of the data point and the
		temp_d = 0
		for j = 1:length(data[i, 1:end])
			temp_d += (point[j]-data[i,j])^2
		end
		
		if temp_d != 0
			d[i] = sqrt(temp_d)
		end
		
	end
	
        #return an array that's sorted by their indicies
	return sortperm(d)
end

# determine a one-dimensional array of indicies by their distance to the passed in point
function dist(point, data)
    summedSquares = sum(broadcast((c,d)->(c-d)^2, point, data),2)
    dists = sqrt(convert(Array{FloatingPoint,2}, summedSquares))
    println(typeof(dists))
    dists = reshape(dists,2)
    return sortperm(dists)
end

fruitCSV = readcsv("fruit.csv")
pointCSV = readcsv("testFruit.csv")
fruitData = fruitCSV[2:end, 1:end-1]
pointData = pointCSV[2:end, 1:end-1]
fruitClasses = fruitCSV[2:end, end]
pointClasses = pointCSV[2:end, end]

k = 10
accuracyCount = 0
# loop over the test data
for i = 1:size(pointData,1)
	indicies = dist(pointData[i,1:end], fruitData)
	
	maxClasses = Dict()
	for j = 1:k
		index = indicies[j]
		class = fruitClasses[index]
		
		if haskey(maxClasses, class) == false
			maxClasses[class] = 1
		else
			maxClasses[class] = maxClasses[class] + 1
		end
	end
	
	maxCount = -1
	maxClass = ""
	for j = keys(maxClasses)
		if maxClasses[j] > maxCount
			maxCount = maxClasses[j]
			maxClass = j
		end
	end
	
	if maxClass == pointClasses[i]
		accuracyCount = accuracyCount + 1
	end
end

accuracy = accuracyCount/length(pointData[1:end,1])
println("Hits: $accuracyCount")
println("Accuracy: $accuracy")



