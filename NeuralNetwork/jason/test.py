from unittest import TestCase

from network import Network

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

        # test the layer ids
        self.assertEquals(0, network.neurons[0][0].layer_id)
        self.assertEquals(1, network.neurons[1][0].layer_id)
        self.assertEquals(2, network.neurons[2][0].layer_id)

        # test the node ids
        self.assertEquals(1, network.neurons[0][1].node_id)
        self.assertEquals(4, network.neurons[1][4].node_id)
        self.assertEquals(2, network.neurons[2][2].node_id)