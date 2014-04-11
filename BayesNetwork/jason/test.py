from unittest import TestCase
from BN import BN
from BNNode import BNNode
from util import util
from KFold import KFold
from BNClassifier import BNClassifier
import math


__author__ = 'Jason'

class TestBNClassifier(TestCase):

    def test_get_max_class(self):
        dict1 = {'a':10, 'b':11, 'c': 6}
        dict2 = {'a':14, 'b':11, 'c': 6}

        res1 = BNClassifier.get_max_class(dict1)
        res2 = BNClassifier.get_max_class(dict2)

        self.assertEquals('b', res1)
        self.assertEquals('a', res2)

    def test_get_count(self):

        n1 = BNNode([], [])
        n1.col_index = 0

        n2 = BNNode([], [])
        n2.col_index = 1

        n3 = BNNode([], [])
        n3.col_index = 2

        n1.parents.append(n2)
        n1.parents.append(n3)

        cols = [1,2]
        row = [0,1,0]
        data = [[0,1,0], [0,1,0], [0,0,0], [0,1,0]]
        classes = ['a', 'b', 'a', 'b']
        poss = ['a', 'b']
        counts = BNClassifier.get_count(row, n1, data, classes, poss)

    def test_get_list_of_cols(self):
        n1 = BNNode([], [])
        n1.col_index = 0

        n2 = BNNode([], [])
        n2.col_index = 1

        n3 = BNNode([], [])
        n3.col_index = 2

        n1.parents.append(n2)
        n1.parents.append(n3)

        col_list = BNClassifier.get_list_of_cols(n1)
        self.assertEquals(1, col_list[0])
        self.assertEquals(2, col_list[1])

    def test_counts(self):
        cols = [1,2]
        row = [0,1,0]
        data = [[0,1,1], [0,1,0], [0,0,0], [0,1,1]]
        classes = ['a', 'b', 'a', 'b']
        poss = ['a', 'b']
        counts = BNClassifier.counts(cols, row, data, classes, poss)
        self.assertEquals(1, counts['a'])
        self.assertEquals(2, counts['b'])

class TestKFold(TestCase):

    def test_get_next(self):
        data = [1,2,3,4,5,6]
        classes = ['a', 'b', 'c', 'd', 'e', 'f']

        kfold = KFold(3, data, classes)
        d1, c1 = kfold.get_next()
        d2, c2 = kfold.get_next()

        self.assertEquals(1, d1[0])
        self.assertEquals(2, d1[1])
        self.assertEquals(3, d1[2])

        self.assertEquals('a', c1[0])
        self.assertEquals('b', c1[1])
        self.assertEquals('c', c1[2])

        self.assertEquals(4, d2[0])
        self.assertEquals(5, d2[1])
        self.assertEquals(6, d2[2])

        self.assertEquals('d', c2[0])
        self.assertEquals('e', c2[1])
        self.assertEquals('f', c2[2])

class TestUtil(TestCase):
    def test_log_fact(self):
        a = math.log(math.factorial(5))
        b = util.log_fact(5)
        a = math.floor(a*1000)/1000
        b = math.floor(b*1000)/1000

        self.assertEquals(a, b)

class TestBN(TestCase):

    def test_remove_parental_diff_from_pred(self):
        a = BNNode([], [])
        b = BNNode([], [])
        c = BNNode([], [])
        pred = [a,b,c]

        node = BNNode([], [])
        node.parents = [c]

        new_pred = BN.remove_parental_diff_from_pred(node, pred)
        self.assertEquals(2, len(new_pred))
        self.assertEquals(True, new_pred[0] == a)
        self.assertEquals(True, new_pred[1] == b)


    def test_pred(self):
        a = BNNode([], [])
        b = BNNode([], [])
        c = BNNode([], [])
        l = [a,b,c]
        ret = BN.pred(c, l)
        self.assertEquals(a, ret[0])
        self.assertEquals(b, ret[1])


    def test_match_counts(self):
        child = BNNode([0,1], [1,0,1])
        p1 = BNNode([0,1], [1,1,1])
        p2 = BNNode([0,1], [1,1,0])
        parents = [p1,p2]

        counts = BN.match_counts(child, parents, [1,1])
        self.assertEquals(1, counts[0])
        self.assertEquals(1, counts[1])

        p1 =    BNNode([0,1], [0,0,0])
        p2 =    BNNode([0,1], [1,1,1])
        child = BNNode([0,1], [0,0,0])
        parents = [p1,p2]

        counts = BN.match_counts(child, parents, [0,1])
        self.assertEquals(3, counts[0])
        self.assertEquals(0, counts[1])

    def test_create_row_from_child_n_parents(self):
        child = BNNode([0,1], [0,0,1])
        p1 = BNNode([0,1], [1,0,1])
        p2 = BNNode([0,1], [0,1,0])
        parents = [p1,p2]

        row1 = BN.create_row_from_child_n_parents(child, parents, 0)
        self.assertEquals(True, BN.lists_match([1,0,0], row1))

        row2 = BN.create_row_from_child_n_parents(child, parents, 1)
        self.assertEquals(True, BN.lists_match([0,1,0], row2))

        row3 = BN.create_row_from_child_n_parents(child, parents, 2)
        self.assertEquals(True, BN.lists_match([1,0,1], row3))

    def test_lists_match(self):
        l1 = [0,1,2,3,4]
        l2 = [0,1,2,3,4]
        self.assertEquals(True, BN.lists_match([0,1,2,3,4], [0,1,2,3,4]))
        self.assertEquals(False, BN.lists_match([1,2,3], [1]))
        self.assertEquals(False, BN.lists_match([1,2,3], [1,2,4]))

    def test_get_all_potential_values(self):
        a = BNNode([0,1], [])
        b = BNNode([0,1], [])
        c = BNNode([0,1], [])

        vals = BN.get_all_potential_values([a,b,c])
        self.assertEquals(3, len(vals))
        for val in vals:
            self.assertEquals(0, val[0])
            self.assertEquals(1, val[1])


    def test_cartesian_product(self):
        my_list = [[1,0],[1,0],[1,0]]
        end_list = [(1,1,1),(1,1,0),(1,0,1),(0,1,1),(1,0,0),(0,0,1),(0,1,0),(0,0,0)]
        c_list = BN.cartesian_product(my_list)

        self.assertEquals(8, len(c_list))
        for tup in end_list:
            self.assertTrue(tup in c_list)


