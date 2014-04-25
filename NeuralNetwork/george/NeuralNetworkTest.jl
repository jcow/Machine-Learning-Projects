require("NeuralNetwork.jl")

net = Network([2,2,2], 1)
net = train(net, [1] |> transpose, [0 0])
println(net)
