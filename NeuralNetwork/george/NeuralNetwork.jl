# Neural.jl
# George Lesica <george@lesica.com>

# ---------
# Constants
# ---------

const RAND_WT_LIMIT = 0.05
const LEARN_RATE = 0.05

# ----------------
# Helper functions
# ----------------

function sigmoid(x)
    1.0 ./ (1.0 + e .^ (-x))
end

# ----------
# Data types
# ----------

type Layer
    weights::Matrix
    outputs::Matrix
    inputs::Matrix
    errors::Matrix
end

function Layer(n_nodes::Int, n_weights::Int)
    weights = zeros(n_weights+1, n_nodes) + 0.05
    outputs = zeros(1, n_nodes)
    inputs = zeros(1, n_weights+1)
    errors = zeros(1, n_nodes)
    return Layer(weights, outputs, inputs, errors)
end

type Network
    layers::Vector{Layer}
end

function Network(layer_dims::Vector{Int}, input_dim::Int)
    dims = [input_dim, layer_dims]
    layers = map(2:length(dims)) do i
        Layer(dims[i], dims[i-1])
    end
    return Network(layers)
end

# ---------------
# Network methods
# ---------------

# Classifies one input
function classify(network::Network, inputs::Matrix)
    layers = network.layers
    nxinputs = inputs
    # Feed forward
    for i_layer = 1:length(layers)
        layers[i_layer] = feedforward(layers[i_layer], nxinputs)
        nxinputs = layers[i_layer].outputs
    end
    maxout = layers[end].outputs |> indmax
    return maxout
end

# Runs one training sample through network
function train(network::Network, inputs::Matrix, targets::Matrix)
    layers = network.layers
    nxinputs = inputs
    # Feed forward
    for i_layer = 1:length(layers)
        layers[i_layer] = feedforward(layers[i_layer], nxinputs)
        nxinputs = layers[i_layer].outputs
    end
    # Back propagate
    for i_layer = length(layers):-1:1
        if i_layer == length(layers)
            layers[i_layer] = backprop(layers[i_layer], targets)
        else
            layers[i_layer] = backprop(layers[i_layer], layers[i_layer+1])
        end
    end
    # Revise weights
    for i_layer = 1:length(layers)
        layers[i_layer] = reviseweights(layers[i_layer])
    end
    network.layers = layers
    return network
end

# -------------
# Layer methods
# -------------

# Produces a row vector of output values for neurons
function feedforward(layer::Layer, inputs::Matrix, transfer=sigmoid)
    weights = layer.weights
    outputs = [1 inputs] * weights |> transfer
    layer.outputs = outputs
    layer.inputs = [1 inputs]
    return layer
end

# Produces a row vector of errors for neurons in an output layer
function backprop(layer::Layer, targets::Matrix)
    outputs = layer.outputs
    errors = outputs .* (1 - outputs) .* (targets - outputs)
    layer.errors = errors
    return layer
end

# Produces a row vector of errors for neurons in a hidden layer
function backprop(layer::Layer, nextlayer::Layer)
    outputs = layer.outputs
    nxerrors = nextlayer.errors
    nxweights = nextlayer.weights
    errors = outputs .* (1 - outputs) .* sum(nxerrors * transpose(nxweights))
    layer.errors = errors
    return layer
end

# Produces a matrix of weight deltas
function reviseweights(layer::Layer, lrate::FloatingPoint=LEARN_RATE)
    errors = layer.errors
    inputs = layer.inputs
    weights = layer.weights
    deltas = transpose(inputs) * errors .* lrate
    layer.weights = weights + deltas
    return layer
end

# net = Network([2,2,2], 1)
# net = train(net, [1] |> transpose, [0 0])
# println(net)
