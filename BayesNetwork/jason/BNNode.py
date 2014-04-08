
class BNNode:

    name = ""
    values = []
    row_values = []
    parents = []

    def __init__(self, vals, row_vals):
        name = ""
        self.values = vals
        self.row_values = row_vals
        self.parents = []