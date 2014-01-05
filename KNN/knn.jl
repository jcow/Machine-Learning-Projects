function dist(point, data)
	d = zeros(FloatingPoint, length(data[1:end,1]))
	for i = 1:length(d)
		temp_d = 0
		for j = 1:length(data[i, 1:end])
			temp_d += (point[j]-data[i,j])^2
		end
		
		if temp_d != 0
			d[i] = sqrt(temp_d)
		end
		
	end
	
	return sortperm(d)
end

fruitCSV = readcsv("fruit.csv")
pointCSV = readcsv("testFruit.csv")
fruitData = fruitCSV[2:end, 1:end-1]
pointData = pointCSV[2:end, 1:end-1]
fruitClasses = fruitCSV[2:end, end]
pointClasses = pointCSV[2:end, end]

k = 10
accuracyCount = 0
for i = 1:length(pointData[1:end,1])
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



