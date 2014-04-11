# Jason Cowan
# Machine Learning
# 4/10/2014
# Bayes Network

# python imports
from __future__ import division
from random import shuffle
import csv

# custom class imports
from BN import BN
from BNNode import BNNode
from util import util
from BNClassifier import BNClassifier
from KFold import KFold

# function to get the initial data from the csv
def get_data():
    raw_data = []

    # loop through the csv and get each row
    with open('data/forestFireData.csv', 'rb') as csvfile:
        # reader reads the csv
        reader = csv.reader(csvfile, delimiter=',', quotechar='|')
        # append to the list the row
        for row in reader:
            raw_data.append(row)

    # get the header from the raw_data
    header = raw_data[0]

    # get the rest of the data
    data = raw_data[1:len(raw_data)]

    # make the nodes
    nodes = []

    # loop through the dimensions and make a node for each one
    for i in range(0, len(header)):
        node = BNNode(['0', '1'], util.col(data, i))
        node.col_index = i
        node.name = header[i]
        nodes.append(node)

    # set the classes
    classes = nodes[-1]
    del nodes[-1]

    # return everything
    return (nodes, data, classes.row_values)

# get the nodes, data, and classes
nodes, data, classes = get_data()

# randomly permute the data
srt = range(0, len(data)-1)
shuffle(srt)

# make new_data from the permutation
new_data = []
new_classes = []
for index in srt:
    new_data.append(data[index])
    new_classes.append(classes[index])

# setup the network
for node in nodes:
    BN.setup_node(node, nodes)

# initial confusion matrix
confusion = {'0':{'0':0, '1':0}, '1':{'0':0, '1':0}}

# do k-fold validation
total_count = 0
kfold = KFold(100, new_data, new_classes)
while kfold.has_next():
    
    dat, cls = kfold.get_next()

    correct_count = 0
    for i in range(0, len(dat)):
        row = dat[i]
        guess = BNClassifier.classify(row, nodes, dat, cls, ['0', '1'])

        if guess == cls[i]:
            correct_count += 1

        confusion[cls[i]][guess] += 1

    total_count += correct_count


for node in nodes:
    pind = ""
    for pnode in node.parents:
        pind += " "+str(pnode.col_index)
    print "Node "+str(node.col_index)+" has parents: "+pind

print ""
print "Average Accuracy: "+str(total_count / len(data))+"\n"
print "Confusion"
print "\t0\t1"
print "0\t"+str(confusion['0']['0'])+"\t"+str(confusion['0']['1'])
print "1\t"+str(confusion['1']['0'])+"\t"+str(confusion['1']['1'])