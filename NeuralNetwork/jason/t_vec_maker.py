


class t_vec_maker:

    mapping = {}

    def __init__(self, unique_vals):
        self.mapping = {}

        counter = 0
        unique_vals_length = len(unique_vals)
        for val in unique_vals:
            l = [0]*unique_vals_length
            l[counter] = 1
            self.mapping[val] = l
            counter += 1

    def get(self, val):
        return self.mapping[val]

    def vec_to_val(self, vec):
        for k,v in self.mapping.items():
            if self.lists_are_equal(vec, v):
                return k

    def lists_are_equal(self, l1, l2):
        l1_length = len(l1)
        l2_length = len(l2)

        if l1_length != l2_length:
            return False

        for i in range(0, l1_length):
            if l1[i] != l2[i]:
                return False
        return True


    @staticmethod
    def t_vecs_equal(t1, t2):
        for i in range(0, len(t1)):
            if t1[i] != t2[i]:
                return False
        return True