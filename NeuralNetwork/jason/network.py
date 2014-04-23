from __future__ import division

import random
import math
from neuron import Neuron

class Network:

    neurons = []
    initial_neuron_random_bound = 0.05

    def __init__(self, neuron_count_vec, weight_counts):
        self.neurons = []
        self._create_neurons(neuron_count_vec, weight_counts)


    def feed_forward(self):
        neurons_length = len(self.neurons)
        for i in range(0, neurons_length):
            for neuron in self.neurons[i]:
                next_layer = []
                if i < neurons_length-1:
                    next_layer = self.neurons[i+1]

                neuron.feed_forward(next_layer)

    @staticmethod
    def set_inputs(input_index, output, neuron_layer):
        for i in neuron_layer:
            neuron_layer[i].inputs[input_index] = output

    @staticmethod
    def get_initial_neuron_weights(amount):
        weights = []
        for i in range(0, amount):

            pos_neg = random.random()
            num = random.random() * Network.initial_neuron_random_bound

            if pos_neg > 0.5:
                pos_neg = 1
            else:
                pos_neg = -1

            num *= pos_neg

            weights.append(num)
        return weights


    def _create_neurons(self, neuron_count_vec, weight_counts):
        for i in range(0, len(neuron_count_vec)):
            self.neurons.append([])
            for j in range(0, neuron_count_vec[i]):

                weights = Network.get_initial_neuron_weights(weight_counts[i]+1)

                inputs = [1]
                inputs.extend([0] * (len(weights)-1))

                neuron = Neuron(i, j, weights, inputs)
                self.neurons[i].append(neuron)


