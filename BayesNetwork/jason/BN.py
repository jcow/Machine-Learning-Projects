from __future__ import division
import itertools
import math
from util import util

class BN:

    nodes = []
    classes = None

    def __init__(self, ns, classs):
        nodes = ns
        classes = classs

    @staticmethod
    def pred(item, lst):
        preds = []
        for lst_item in lst:
            if item != lst_item:
                preds.append(lst_item)
            else:
                break
        return preds

    @staticmethod
    def get_score(child, parents):
        score = 0

        r_i = len(child.values)

        if len(parents) == 0:
            n_ij = len(child.row_values)
            n_ijk_list = [0]*len(child.values)

            for i in range(0, len(child.values)):
                n_ijk_list[i] = child.row_values.count(child.values[i])

            score += BN.make_score(n_ijk_list, n_ij, r_i)
        else:
            cart_prods = BN.cartesian_product(BN.get_all_potential_values(parents))
            for prod in cart_prods:
                n_ijk_list = BN.match_counts(child, parents, prod)
                n_ij = sum(n_ijk_list)

        return score

    @staticmethod
    def make_score(n_ijk_list, n_ij, r_i):
        return util.log_fact(r_i - 1) - util.log_fact(n_ij + r_i - 1) + sum(map(util.log_fact, n_ijk_list))
        #return (math.factorial(r_i - 1) / math.factorial(n_ij + r_i - 1)) * util.prod(map(math.factorial, n_ijk_list))

    @staticmethod
    def match_counts(child, parents, value):
        counts = [0]*len(child.values)

        to_match = [list(value) for x in xrange(len(child.values))]

        for i in range(0, len(child.values)):
            to_match[i].append(child.values[i])

        for i in range(0, len(to_match)):
            mat = to_match[i]

            for j in range(0, len(child.row_values)):
                m = BN.create_row_from_child_n_parents(child, parents, j)
                if BN.lists_match(mat, m):
                    counts[i] += 1

        return counts


    @staticmethod
    def create_row_from_child_n_parents(child, parents, index):
        ret = []
        for i in range(0, len(parents)):
            ret.append(parents[i].row_values[index])

        ret.append(child.row_values[index])

        return ret

    @staticmethod
    def lists_match(l1, l2):
        if len(l1) != len(l2):
            return False

        for i in range(0, len(l1)):
            if l1[i] != l2[i]:
                return False

        return True

    @staticmethod
    def get_all_potential_values(nodes):
        p_vals = []
        for node in nodes:
            p_vals.append(node.values)
        return p_vals

    @staticmethod
    def cartesian_product(list_of_lists):
        return list(itertools.product(*list_of_lists))

