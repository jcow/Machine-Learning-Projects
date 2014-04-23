class Neuron:

    layer_id = 0
    node_id = 0
    weights = []
    output = 0

    def __init__(self, layer_id, node_id, weights, output = 0):
        self.layer_id = layer_id
        self.node_id = node_id
        self.weights = weights
        self.output = output
