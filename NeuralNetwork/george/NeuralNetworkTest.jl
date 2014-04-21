require("NeuralNetwork.jl")

# -----------
# Test Neuron
# -----------

function test_neuron()
    n1 = Neuron([0.05, 0.05])
    nin = transpose([1])

    @assert output(n1, nin) - 0.525 < 0.001
end

test_neuron()

# --------------------
# Test neuron reweight
# --------------------

function test_neuron_reweight()
    n1 = Neuron([0.05, 0.05])
    nin = transpose([1])
    nerr = -2.01635e-5
    nnew = reweighted(n1, nin, nerr)

    @assert all(nnew.wts + 2.016356e-8 - 0.05 .< 0.001)
end

test_neuron_reweight()

# ----------
# Test layer
# ----------

function test_layer()
    n1 = Neuron([0.05, 0.05])
    n2 = Neuron([0.05, 0.05])
    lin = transpose([1])
    lout = output([n1, n2], lin)

    @assert all(abs(lout) - 0.525 .< 0.001)
    @assert length(lout) == 2
end

test_layer()

# ------------------------
# Test output layer errors
# ------------------------

function test_output_errors()
    n1 = Neuron([0.05, 0.05])
    n2 = Neuron([0.05, 0.05])
    lout = [0.518979 0.518979]
    ltar = [0 0]
    eout = layer_error(lout, ltar)

    @assert all(abs(eout) - 0.130 .< 0.001)
end

test_output_errors()

# ------------------------
# Test hidden layer errors
# ------------------------

function test_hidden_errors()
    n1 = Neuron([0.05, 0.05])
    n2 = Neuron([0.05, 0.05])
    lout = [0.519053 0.519053]
    nlay = [Neuron([0.05, 0.05]), Neuron([0.05, 0.05])]
    nerr = [-0.1295578 -0.1295578]
    ehid = layer_error(lout, nlay, nerr)

    @assert all(abs(ehid) - 0.003 .< 0.001)
end

test_hidden_errors()

# -------------------
# Test layer reweight
# -------------------

function test_layer_reweight()
    n1 = Neuron([0.05, 0.05])
    n2 = Neuron([0.05, 0.05])
    nin = transpose([1])
    nerr = [-8.149349e-5, -8.149349e-5]
    nnew = reweighted([n1, n2], nin, nerr)

    @assert all([all(nrn.wts + 4.074674e-6 - 0.05 .< 0.001) for nrn = nnew])
end

test_layer_reweight()







