from __future__ import division
from random import shuffle
import csv

from BN import BN
from BNNode import BNNode
from util import util
from BNClassifier import BNClassifier
from KFold import KFold


def get_data():
    raw_data = []

    with open('data/forestFireData.csv', 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='|')
        for row in reader:
            raw_data.append(row)


    header = raw_data[0]
    data = raw_data[1:len(raw_data)]

    nodes = []
    for i in range(0, len(header)):
        node = BNNode(['0', '1'], util.col(data, i))
        node.col_index = i
        node.name = header[i]
        nodes.append(node)

    classes = nodes[-1]
    del nodes[-1]

    return (nodes, data, classes.row_values)


nodes, data, classes = get_data()

srt = range(0, len(data)-1)
shuffle(srt)

new_data = []
for index in srt:
    new_data.append(data[index])

for node in nodes:
    BN.setup_node(node, nodes)

confusion = {'0':{'0':0, '1':0}, '1':{'0':0, '1':0}}

total_count = 0
kfold = KFold(100, new_data, classes)
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