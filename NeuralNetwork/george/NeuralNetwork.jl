# NeuralNetwork.jl
# George Lesica

# ---------
# Constants
# ---------

# Randomly assigned initial weights will be in the range of +/- this value.
const RAND_WT_LIMIT = 0.05
const LEARN_RATE = 0.001

# ----------------
# Helper functions
# ----------------

function sigmoid(x)
    return 1.0 / (1.0 + e ^ (-x))
end

# -----------------
# Neuron definition
# -----------------

immutable Neuron
    wts::Vector
    tport::Function
    lrate::FloatingPoint
end

function Neuron(wts, tport)
    return Neuron(wts, tport, LEARN_RATE)
end

function Neuron(n_inputs::Int)
    # Use sigmoid for default transport function
    tport = sigmoid
    # Use random weights from -RAND_WT_LIMIT to RAND_WT_LIMIT and add one
    # weight for the bias
    wts = (rand(n_inputs + 1) - 0.5) .% RAND_WT_LIMIT

    return Neuron(wts, tport)
end

function Neuron(wts::Vector)
    # Use sigmoid for default transport function
    tport = sigmoid
    
    return Neuron(wts, tport)
end

# --------------
# Neuron methods
# --------------

# Compute the output for a single neuron
function output(neuron::Neuron, input::Matrix)
    # Check that the input is the right size for the neuron
    @assert size(input) == (1, length(neuron.wts) - 1)

    return [1 input] * neuron.wts |> first |> neuron.tport
end

function reweighted(neuron::Neuron, input::Matrix, error::FloatingPoint)
    # Check that the input sizes match up
    @assert size(input) == (1, length(neuron.wts) - 1)

    adjinput = [1 input]
    deltawts = map(1:length(neuron.wts)) do i
        neuron.lrate * error * adjinput[i]
    end

    return Neuron(neuron.wts + deltawts, neuron.tport, neuron.lrate)
end

# ------------
# Network type
# ------------

immutable NeuralNetwork
    layers::Dict{Int,Vector{Neuron}}
    dims::Vector{Int}
end

function NeuralNetwork(dims::Vector{Int}, n_inputs::Int)
    n_weights = n_inputs
    layers = Dict{Int,Vector{Neuron}}()
    for i = 1:length(dims)
        layers[i] = [Neuron(n_weights) for _ = 1:dims[i]]
        n_weights = dims[i]
    end
    return NeuralNetwork(layers, dims)
end

# ---------------
# Network methods
# ---------------

function output(net::NeuralNetwork, data::Matrix)
    # Quick and dirty check for dimension agreement
    @assert size(data) == (1, length(net.layers[1][1].wts) - 1)

    out = Dict{Int,Matrix}()
    nextdata = data
    for i_layer = 1:length(net.dims)
        nextout = output(net.layers[i_layer], nextdata)
        out[i_layer] = nextout
        nextdata = nextout
    end

    return out
end

# Compute errors for the entire network
function network_error(net::NeuralNetwork, outputs::Dict{Int,Matrix}, target::Matrix)
    errs = Dict{Int,Vector}()

    lasterr = layer_error(outputs[length(net.dims)], target)
    errs[length(net.dims)] = lasterr

    for i_layer = (length(net.dims) - 1):-1:1
        errs[i_layer] = layer_error(outputs[i_layer], net.layers[i_layer + 1], lasterr)
        lasterr = errs[i_layer]
    end

    return errs
end

# -------------
# Layer methods
# -------------

# Compute the outputs for an entire layer
function output(layer::Vector{Neuron}, input::Matrix)
    return map(layer) do neuron
        output(neuron, input)
    end |> transpose
end

# Compute errors for the output layer
function layer_error(output::Matrix, target::Matrix)
    # Check that the output and target sizes match
    @assert size(output) == size(target)

    return output .* (1 - output) .* (target - output) |> vec
end

# Compute errors for a hidden layer
function layer_error(output::Matrix, nextlayer::Vector{Neuron}, nexterrors::Vector)
    return map(1:length(output)) do i
        wts = [neuron.wts[i] for neuron = nextlayer] |> transpose
        output[i] * (1 - output[i]) * (wts * nexterrors |> first)
    end
end

# Return a layer of neurons that have been reweighted
function reweighted(layer::Vector{Neuron}, input::Matrix, errors::Vector)
    return map(1:length(layer)) do i
        reweighted(layer[i], input, errors[i])
    end
end




