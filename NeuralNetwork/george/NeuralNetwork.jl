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

    return output .* (1 - output) .* (target - output) |> transpose
end

# Compute errors for a hidden layer
function layer_error(output::Matrix, nextlayer::Vector{Neuron}, nexterrors::Matrix)
    return map(1:length(nexterrors)) do i
        wts = [neuron.wts[i] for neuron = nextlayer]
        output[i] * (1 - output[i]) * (nexterrors * wts |> first)
    end
end

# Return a layer of neurons that have been reweighted
function reweighted(layer::Vector{Neuron}, input::Matrix, errors::Vector)
    return map(1:length(layer)) do i
        reweighted(layer[i], input, errors[i])
    end
end




