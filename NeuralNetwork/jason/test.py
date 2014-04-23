from __future__ import division

import math
from unittest import TestCase

from network import Network
from neuron import Neuron

class TestNetwork(TestCase):

    def test_construction(self):
        network = Network([3, 5, 3], [8, 5, 3])

        # test the neuron counts
        self.assertEquals(3, len(network.neurons))
        self.assertEquals(3, len(network.neurons[0]))
        self.assertEquals(5, len(network.neurons[1]))
        self.assertEquals(3, len(network.neurons[2]))

        # test the neuron weight counts
        self.assertEquals(9, len(network.neurons[0][0].weights))
        self.assertEquals(6, len(network.neurons[1][0].weights))
        self.assertEquals(4, len(network.neurons[2][0].weights))

        # test the input counts
        self.assertEquals(9, len(network.neurons[0][0].inputs))
        self.assertEquals(6, len(network.neurons[1][0].inputs))
        self.assertEquals(4, len(network.neurons[2][0].inputs))

        # test input values
        self.assertEquals(1, network.neurons[0][0].inputs[0])
        for i in range(1, len(network.neurons[0][0].inputs)):
            self.assertEquals(0, network.neurons[0][0].inputs[i])

        # test the layer ids
        self.assertEquals(0, network.neurons[0][0].layer_id)
        self.assertEquals(1, network.neurons[1][0].layer_id)
        self.assertEquals(2, network.neurons[2][0].layer_id)

        # test the node ids
        self.assertEquals(1, network.neurons[0][1].node_id)
        self.assertEquals(4, network.neurons[1][4].node_id)
        self.assertEquals(2, network.neurons[2][2].node_id)

    def test_get_initial_neuron_weights(self):
        bound = Network.initial_neuron_random_bound
        weights = Network.get_initial_neuron_weights(4)
        for w in weights:
            self.assertEquals(True, (w >= -bound and w <= bound))


class TestNeuron(TestCase):

    def test_sigmoid(self):
        val = math.floor(Neuron.sigmoid(0.1) * 1000)/1000
        self.assertEquals(0.524, val)

    def test_make_output(self):
        neuron = Neuron(0, 0, [0.05, 0.05], [1, 1])
        val = neuron.make_output()
        val = math.floor(val * 1000)/1000
        self.assertEquals(0.524, val)

    def test_feed_forward(self):
        neuron = Neuron(0, 0, [0.05, 0.05], [1, 1])
        next_node1 = Neuron(0, 0, [0.05, 0.05], [0, 0])
        next_node2 = Neuron(0, 0, [0.05, 0.05], [0, 0])
        nodes = [next_node1, next_node2]
        neuron.feed_forward(nodes)

        self.assertEquals(0.524, round_to(nodes[0].inputs[0], 3))
        self.assertEquals(0, round_to(nodes[0].inputs[1], 3))
        self.assertEquals(0.524, round_to(nodes[1].inputs[0], 3))
        self.assertEquals(0, round_to(nodes[1].inputs[1], 3))






def round_to(value, decimal):
    return  math.floor(value * (10 ** decimal)) / (10 ** decimal)
