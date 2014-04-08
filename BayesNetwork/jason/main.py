from BN import BN
from BNNode import BNNode
from util import util

# import operator
#
# import csv
#
# def get_data():
#     raw_data = []
#
#     with open('data/forestFireData.csv', 'rb') as csvfile:
#         reader = csv.reader(csvfile, delimiter=',', quotechar='|')
#         for row in reader:
#             raw_data.append(row)
#
#
#     header = raw_data[0]
#     data = raw_data[1:len(raw_data)]
#
#     nodes = []
#     for i in range(0, len(header)):
#         node = BNNode(['0', '1'], util.col(data, i))
#         node.name = header[i]
#         nodes.append(node)
#
#     classes = nodes[-1]
#     del nodes[-1]
#
#     return (nodes, classes)


#nodes, classes = get_data()
#BN.setup_node(nodes[0], nodes)


# i = 0
# for node in nodes:
#     BN.setup_node(node, nodes)
#
#     i += 1
#     # if i == 3:
#     #     break


a = BNNode([], [])
a.name = "A"
b = BNNode([], [])
b.name = "B"

nodes = [a, b]
BN.setup_node(nodes[0], nodes)

for node in nodes:
    print node.name
    for n in node.parents:
        print "\t"+n.name
    print "----------"