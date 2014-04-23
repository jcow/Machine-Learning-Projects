import math

class Neuron:

    layer_id = 0
    node_id = 0
    weights = []
    inputs = []
    output = 0

    def __init__(self, layer_id, node_id, weights, inputs):
        self.layer_id = layer_id
        self.node_id = node_id
        self.weights = weights
        self.inputs = inputs
        output = 0

    def feed_forward(self, next_layer_nodes):
        self.output = self.make_output()

        for node in next_layer_nodes:
            node.inputs[self.node_id] = self.output

    def make_output(self):
        tfunc = Neuron.sigmoid

        val = 0
        for i in range(0, len(self.weights)):
            val += self.weights[i] * self.inputs[i]

        return tfunc(val)

    @staticmethod
    def sigmoid(val):
        return 1 / (1 + math.exp(-val))