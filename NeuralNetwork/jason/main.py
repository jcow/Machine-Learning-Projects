from __future__ import division
from random import shuffle
from network import *
from util import *
from t_vec_maker import *
from KFold import *


head, d, c = util.get_data("data/iris.csv")
d = util.matrix_to_float(d)
t_maker = t_vec_maker(util.unique_list(c))

srt = range(0, len(d)-1)
shuffle(srt)

new_d = []
new_c = []
for i in srt:
    new_d.append(d[i])
    new_c.append(c[i])


def print_confusion(confusion):
    print "\t \t1\t2\t3"
    print "\t 1\t"+str(confusion['1']['1'])+"\t"+str(confusion['1']['2'])+"\t"+str(confusion['1']['3'])
    print "\t 2\t"+str(confusion['2']['1'])+"\t"+str(confusion['2']['2'])+"\t"+str(confusion['2']['3'])
    print "\t 3\t"+str(confusion['3']['1'])+"\t"+str(confusion['3']['2'])+"\t"+str(confusion['3']['3'])

def test_network(data, classes, nodes, weights):

    confusion_matrix = {}
    for key1 in t_maker.mapping.keys():
        confusion_matrix[key1] = {}
        for key2 in t_maker.mapping.keys():
            confusion_matrix[key1][key2] = 0

    correct = 0
    kfold_counter = 1
    kfold = KFold(15, data, classes)
    while kfold.has_next():

        print "Starting KFold "+str(kfold_counter)

        network = Network(nodes, weights)
        network.learning_rate = 0.04

        train_d, train_c, test_d, test_c = kfold.get_next()

        # update network until it levels out
        for i in range(0, 1000):
            for j in range(0, len(train_d)):

                counter = 0
                for val in train_d[j]:
                    Network.set_inputs(counter, val, network.neurons[0])
                    counter += 1

                t_val = t_maker.get(train_c[j])
                network.feed_forward()
                network.set_errors(t_val)
                network.update_weights()

        for i in range(0, len(test_d)):

            counter = 0
            for val in test_d[i]:
                Network.set_inputs(counter, val, network.neurons[0])
                counter += 1

            network.feed_forward()
            actual = t_maker.get(test_c[i])
            guess = Network.get_class_vec_from_output(network.neurons[-1])
            are_equal = t_vec_maker.t_vecs_equal(actual, guess)

            confusion_matrix[t_maker.vec_to_val(guess)][t_maker.vec_to_val(actual)] += 1

            if are_equal:
                correct += 1

        kfold_counter += 1

    return correct, 150, confusion_matrix

print "--------------------------"
print "Starting Network 3, 3, 3"
correct, out_of, confusion = test_network(new_d, new_c, [3, 3, 3], [len(d[0]), 3, 3])
print "Accuracy: "+str(correct/out_of)
print "Confusion"
print_confusion(confusion)
print ""

print "--------------------------"
print "Starting Network 4, 4, 3"
correct, out_of, confusion = test_network(new_d, new_c, [4, 4, 3], [len(d[0]), 4, 3])
print "Accuracy: "+str(correct/out_of)
print "Confusion"
print_confusion(confusion)
print ""

print "--------------------------"
print "Starting Network 3, 3, 3, 3"
correct, out_of, confusion = test_network(new_d, new_c, [3, 3, 3, 3], [len(d[0]), 3, 3, 3])
print "Accuracy: "+str(correct/out_of)
print "Confusion"
print_confusion(confusion)
print ""

print "--------------------------"
print "Starting Network 4, 12, 3"
correct, out_of, confusion = test_network(new_d, new_c, [4, 12, 3], [len(d[0]), 4, 12])
print "Accuracy: "+str(correct/out_of)
print "Confusion"
print_confusion(confusion)
print ""