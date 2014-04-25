from __future__ import division

import math
from unittest import TestCase

from network import Network
from neuron import Neuron
from t_vec_maker import t_vec_maker
from KFold import KFold

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
        self.assertEquals(1, network.neurons[0][0].inputs[len(network.neurons[0][0].inputs)-1])
        for i in range(1, len(network.neurons[0][0].inputs)-1):
            self.assertEquals(0, network.neurons[0][0].inputs[i])

        # test the layer ids
        self.assertEquals(0, network.neurons[0][0].layer_id)
        self.assertEquals(1, network.neurons[1][0].layer_id)
        self.assertEquals(2, network.neurons[2][0].layer_id)

        # test the node ids
        self.assertEquals(1, network.neurons[0][1].node_id)
        self.assertEquals(4, network.neurons[1][4].node_id)
        self.assertEquals(2, network.neurons[2][2].node_id)

        # test last layer for for output layer truthy
        self.assertEquals(True, network.neurons[2][0].is_output_layer)
        self.assertEquals(True, network.neurons[2][1].is_output_layer)
        self.assertEquals(True, network.neurons[2][2].is_output_layer)
        self.assertEquals(False, network.neurons[1][2].is_output_layer)
        self.assertEquals(False, network.neurons[0][2].is_output_layer)

    def test_get_initial_neuron_weights(self):
        bound = Network.initial_neuron_random_bound
        weights = Network.get_initial_neuron_weights(4)
        for w in weights:
            self.assertEquals(True, (w >= -bound and w <= bound))

    def test_feed_forward_small_network(self):
        network = get_small_example()
        network.feed_forward()

        self.assertEquals(0.5249, round_to(network.neurons[0][0].output, 4))
        self.assertEquals(0.519, round_to(network.neurons[1][0].output, 3))
        self.assertEquals(0.5189, round_to(network.neurons[2][0].output, 4))

    def test_feed_forward_large_network(self):
        network = get_large_example()
        network.feed_forward()

        self.assertEquals(0.5249, round_to(network.neurons[0][0].output, 4))
        self.assertEquals(0.5249, round_to(network.neurons[0][1].output, 4))

        self.assertEquals(0.5256, round_to(network.neurons[1][0].output, 4))
        self.assertEquals(0.5256, round_to(network.neurons[1][1].output, 4))

        self.assertEquals(0.5256, round_to(network.neurons[2][0].output, 4))
        self.assertEquals(0.5256, round_to(network.neurons[2][1].output, 4))

    def test_set_errors_small_example(self):
        network = get_small_example()
        network.feed_forward()
        network.set_errors([0])

        self.assertEquals(-0.12955, round_to(network.neurons[2][0].delta_val, 5))
        self.assertEquals(-0.00161, round_to(network.neurons[1][0].delta_val, 5))
        self.assertEquals(-0.000020163, round_to(network.neurons[0][0].delta_val, 9))

    def test_set_errors_large_example(self):
        network = get_large_example()
        network.feed_forward()
        network.set_errors([0, 0])

        self.assertEquals(-0.13105, round_to(network.neurons[2][0].delta_val, 5))
        self.assertEquals(-0.13105, round_to(network.neurons[2][1].delta_val, 5))

        self.assertEquals(-0.003267, round_to(network.neurons[1][0].delta_val, 6))
        self.assertEquals(-0.003267, round_to(network.neurons[1][1].delta_val, 6))

        self.assertEquals(-0.00008149, round_to(network.neurons[0][0].delta_val, 8))
        self.assertEquals(-0.00008149, round_to(network.neurons[0][1].delta_val, 8))

    def test_update_weights(self):
        network = get_small_example()
        network.learning_rate = 0.001
        network.feed_forward()
        network.set_errors([0])

        network.update_weights()

        self.assertEquals(0.0499327526, round(network.neurons[2][0].weights[0], 10))
        self.assertEquals(0.0498704, round(network.neurons[2][0].weights[1], 7))

        self.assertEquals(0.049999151045, round(network.neurons[1][0].weights[0], 12))
        self.assertEquals(0.0499983828788, round(network.neurons[1][0].weights[1], 13))

    def test_get_class_vec_from_output(self):
        l = [Neuron(0, 0, [], []), Neuron(0, 0, [], []), Neuron(0, 0, [], [])]
        l[0].output = 1
        l[1].output = 3
        l[2].output = 2

        tl1 = Network.get_class_vec_from_output(l)
        self.assertEquals(3, len(tl1))
        self.assertEquals(0, tl1[0])
        self.assertEquals(1, tl1[1])
        self.assertEquals(0, tl1[2])

        l[0].output = 3
        l[1].output = 1
        l[2].output = 0

        tl2 = Network.get_class_vec_from_output(l)
        self.assertEquals(3, len(tl2))
        self.assertEquals(1, tl2[0])
        self.assertEquals(0, tl2[1])
        self.assertEquals(0, tl2[2])



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

    def test_set_error_output_layer(self):
        neuron = Neuron(0, 0, [0.05, 0.05], [1, 1])
        neuron.output = 0.518979
        neuron.is_output_layer = True
        neuron.set_output_layer_error(0)

        self.assertEquals(-0.12955, round_to(neuron.delta_val, 5))

    def test_set_error_not_output_layer(self):
        network = get_small_example()
        network.neurons[2][0].output = 0.518979
        network.neurons[2][0].is_output_layer = True
        network.neurons[2][0].set_output_layer_error(0)

        network.neurons[1][0].output = 0.519053
        network.neurons[1][0].set_non_output_layer_error(network.neurons[2])

        self.assertEquals(-0.00161, round_to(network.neurons[1][0].delta_val, 5))

    def test_update_weights(self):
        neuron = Neuron(0, 0, [0.05, 0.05], [0.519053, 1])
        neuron.delta_val = -0.1295578
        neuron.update_weights(0.001)

        self.assertEquals(0.0499327526, round(neuron.weights[0], 10))
        self.assertEquals(0.0498704, round(neuron.weights[1], 7))


class TestTVecMaker(TestCase):

    def test_t_vec_maker_get(self):
        t = t_vec_maker(['a', 'b', 'c'])
        a_val = t.get('a')
        b_val = t.get('b')
        c_val = t.get('c')

        self.assertEquals(1, a_val[0])
        self.assertEquals(0, a_val[1])
        self.assertEquals(0, a_val[2])

        self.assertEquals(0, b_val[0])
        self.assertEquals(1, b_val[1])
        self.assertEquals(0, b_val[2])

        self.assertEquals(0, c_val[0])
        self.assertEquals(0, c_val[1])
        self.assertEquals(1, c_val[2])

    def test_t_vecs_equal(self):
        self.assertEquals(True, t_vec_maker.t_vecs_equal([1,2,3,4], [1,2,3,4]))
        self.assertEquals(False, t_vec_maker.t_vecs_equal([1,2,3,4], [1,2,3,3]))


class TestKFold(TestCase):

    def test_get_next(self):
        data = [1,2,3,4,5,6,7,8,9,10]
        classes = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']

        counter = 0
        kfold = KFold(2, data, classes)
        while kfold.has_next():
            train_d1, train_c1, test_d1, test_c1 = kfold.get_next()

            self.assertEquals(8, len(train_d1))
            self.assertEquals(8, len(train_c1))
            self.assertEquals(2, len(test_d1))
            self.assertEquals(2, len(test_c1))
            counter += 1

        self.assertEquals(5, counter)

        kfold = KFold(2, data, classes)

        train_d1, train_c1, test_d1, test_c1 = kfold.get_next()
        self.assertEquals(True, lists_are_equal(train_d1, [3,4,5,6,7,8,9,10]))
        self.assertEquals(True, lists_are_equal(train_c1, ['c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']))
        self.assertEquals(True, lists_are_equal(test_d1, [1,2]))
        self.assertEquals(True, lists_are_equal(test_c1, ['a', 'b']))

        train_d1, train_c1, test_d1, test_c1 = kfold.get_next()
        self.assertEquals(True, lists_are_equal(train_d1, [1,2,5,6,7,8,9,10]))
        self.assertEquals(True, lists_are_equal(train_c1, ['a', 'b', 'e', 'f', 'g', 'h', 'i', 'j']))
        self.assertEquals(True, lists_are_equal(test_d1, [3,4]))
        self.assertEquals(True, lists_are_equal(test_c1, ['c', 'd']))

        train_d1, train_c1, test_d1, test_c1 = kfold.get_next()
        train_d1, train_c1, test_d1, test_c1 = kfold.get_next()
        train_d1, train_c1, test_d1, test_c1 = kfold.get_next()

        self.assertEquals(True, lists_are_equal(train_d1, [1,2,3,4,5,6,7,8]))
        self.assertEquals(True, lists_are_equal(train_c1, ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']))
        self.assertEquals(True, lists_are_equal(test_d1, [9,10]))
        self.assertEquals(True, lists_are_equal(test_c1, ['i', 'j']))



#
# Helper Functions
#

def get_small_example():
    network = Network([1, 1, 1], [1, 1, 1])
    network.neurons[0][0].inputs = [1, 1]
    network.neurons[1][0].inputs = [0, 1]
    network.neurons[2][0].inputs = [0, 1]
    network.neurons[0][0].weights = [0.05, 0.05]
    network.neurons[1][0].weights = [0.05, 0.05]
    network.neurons[2][0].weights = [0.05, 0.05]
    network.neurons[2][0].is_output_layer = True
    return network

def get_large_example():
    network = Network([2, 2, 2], [1, 2, 2])

    network.neurons[0][0].inputs = [1, 1]
    network.neurons[0][1].inputs = [1, 1]

    network.neurons[1][0].inputs = [0, 0, 1]
    network.neurons[1][1].inputs = [0, 0, 1]

    network.neurons[2][0].inputs = [0, 0, 1]
    network.neurons[2][1].inputs = [0, 0, 1]

    network.neurons[2][0].is_output_layer = True
    network.neurons[2][1].is_output_layer = True

    for layer in network.neurons:
        for neuron in layer:
            for i in range(0, len(neuron.weights)):
                neuron.weights[i] = 0.05

    return network



def round_to(value, decimal):
    if value < 0:
        return math.ceil(value * (10 ** decimal)) / (10 ** decimal)
    else:
        return math.floor(value * (10 ** decimal)) / (10 ** decimal)


def lists_are_equal(l1, l2):
    l1_length = len(l1)
    l2_length = len(l2)
    if l1_length != l2_length:
        return False

    for i in range(0, l1_length):
        if l1[i] != l2[i]:
            return False
    return True