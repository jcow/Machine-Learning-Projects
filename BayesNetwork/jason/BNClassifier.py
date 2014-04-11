from __future__ import division
from BNNode import BNNode
import sys

class BNClassifier:

    @staticmethod
    def classify(row, nodes, data, classes, class_possibilities):
        probs = {}
        for i in class_possibilities:
            probs[i] = 0

        for i in range(0, len(nodes)):
            counts = BNClassifier.get_count(row, nodes[i], data, classes, class_possibilities)
            total = sum(counts.values())

            for k,v in counts.iteritems():
                if probs[k] == 0:
                    probs[k] = v/total
                else:
                    probs[k] *= v/total

        return BNClassifier.get_max_class(probs)

    @staticmethod
    def get_max_class(probs):
        max_class = ""
        max_score = -sys.float_info.max

        for k,v in probs.iteritems():
            if max_class == "":
                max_class = k
                max_score = v
            elif max_score < v:
                max_class = k
                max_score = v
        return max_class


    @staticmethod
    def get_count(row, node, data, classes, class_possibilities):
        col_list = [node.col_index]
        to_add = BNClassifier.get_list_of_cols(node)
        for index in to_add:
            col_list.append(index)

        return BNClassifier.counts(col_list, row, data, classes, class_possibilities)

    @staticmethod
    def get_list_of_cols(node):
        l = []
        for n in node.parents:
            l.append(n.col_index)
        return l

    # cols in a list into the indexes in which we care
    @staticmethod
    def counts(cols, row, data, classes, class_possibilities):
        cnt = {}
        for c in class_possibilities:
            cnt[c] = 0

        for i in range(0, len(data)):
            matched = True
            for j in range(0, len(cols)):
                if row[j] != data[i][j]:
                    matched = False
                    break

            if matched:
                cnt[classes[i]] += 1

        return cnt
