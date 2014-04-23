import random
from neuron import Neuron

class Network:

    neurons = []
    initial_neuron_random_bound = 0.05

    def __init__(self, neuron_count_vec, weight_counts):
        self.neurons = []
        self._create_neurons(neuron_count_vec, weight_counts)


    def _create_neurons(self, neuron_count_vec, weight_counts):
        for i in range(0, len(neuron_count_vec)):
            self.neurons.append([])
            for j in range(0, neuron_count_vec[i]):
                weights = Network.get_initial_neuron_weights(weight_counts[i])
                weights.append(1)
                neuron = Neuron(i, j, weights)
                self.neurons[i].append(neuron)

    @staticmethod
    def get_initial_neuron_weights(neuron_count):
        weights = []
        for i in range(0, neuron_count):

            pos_neg = random.random()
            num = random.random() * Network.initial_neuron_random_bound

            if pos_neg > 0.5:
                pos_neg = 1
            else:
                pos_neg = -1

            num *= pos_neg

            weights.append(num)
        return weights

