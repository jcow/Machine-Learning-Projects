from __future__ import division
import sys

import random
import math
from neuron import Neuron

class Network:

    neurons = []
    learning_rate = 0.5

    initial_neuron_random_bound = 0.05

    def __init__(self, neuron_count_vec, weight_counts, learning_rate = 0.5):
        self.neurons = []
        self._create_neurons(neuron_count_vec, weight_counts)
        self.learning_rate = learning_rate

    def feed_forward(self):
        neurons_length = len(self.neurons)
        for i in range(0, neurons_length):
            for neuron in self.neurons[i]:
                next_layer = []
                if i < neurons_length-1:
                    next_layer = self.neurons[i+1]

                neuron.feed_forward(next_layer)

    def set_errors(self, target_vec):
        neuron_length = len(self.neurons)
        for i in range(neuron_length-1, -1, -1):
            for j in range(0, len(self.neurons[i])):
                if self.neurons[i][j].is_output_layer:
                    self.neurons[i][j].set_output_layer_error(target_vec[j])
                else:
                    self.neurons[i][j].set_non_output_layer_error(self.neurons[i+1])

    def update_weights(self):
        for i in range(0, len(self.neurons)):
            for neuron in self.neurons[i]:
                neuron.update_weights(self.learning_rate)

    @staticmethod
    def get_class_vec_from_output(neurons):
        m = (-1, -sys.float_info.max)
        counter = 0
        for neuron in neurons:
            if m[1] < neuron.output:
                m = (counter, neuron.output)
            counter += 1

        v = [0] * len(neurons)
        v[m[0]] = 1

        return v

    @staticmethod
    def set_inputs(input_index, input, neuron_layer):
        for neuron in neuron_layer:
            neuron.inputs[input_index] = input

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
        neuron_count_vec_length = len(neuron_count_vec)
        for i in range(0, neuron_count_vec_length):
            self.neurons.append([])
            for j in range(0, neuron_count_vec[i]):

                weights = Network.get_initial_neuron_weights(weight_counts[i]+1)

                inputs = [0] * (len(weights)-1)
                inputs.append(1)

                neuron = Neuron(i, j, weights, inputs)
                if i == neuron_count_vec_length-1:
                    neuron.is_output_layer = True

                self.neurons[i].append(neuron)


