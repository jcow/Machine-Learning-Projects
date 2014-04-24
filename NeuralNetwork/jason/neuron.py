import math

class Neuron:

    layer_id = 0
    node_id = 0
    weights = []
    inputs = []
    output = 0
    delta_val = 0
    is_output_layer = False

    def __init__(self, layer_id, node_id, weights, inputs):
        self.layer_id = layer_id
        self.node_id = node_id
        self.weights = weights
        self.inputs = inputs
        self.output = 0
        self.delta_val = 0
        is_output_layer = False

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

    def set_output_layer_error(self, target_value):
        self.delta_val = self.output * (1 - self.output) * (target_value - self.output)

    def set_non_output_layer_error(self, next_layer_nodes):
        next_layer_sum = 0
        for node in next_layer_nodes:
            next_layer_sum += node.weights[self.node_id] * node.delta_val

        self.delta_val = self.output * (1 - self.output) * next_layer_sum

    def update_weights(self, learning_rate):
        for i in range(0, len(self.weights)):
            self.weights[i] = self.weights[i] + (learning_rate * self.delta_val * self.inputs[i])

    @staticmethod
    def sigmoid(val):
        return 1 / (1 + math.exp(-val))