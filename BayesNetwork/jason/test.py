from unittest import TestCase
from BN import BN
from BNNode import BNNode
from util import util
import math

__author__ = 'Jason'

class TestUtil(TestCase):
    def test_log_fact(self):
        a = math.log(math.factorial(5))
        b = util.log_fact(5)
        a = math.floor(a*1000)/1000
        b = math.floor(b*1000)/1000

        self.assertEquals(a, b)

class TestBN(TestCase):

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


