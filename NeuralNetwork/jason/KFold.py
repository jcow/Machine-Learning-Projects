
class KFold:

    current = 0
    step = 1
    data = []
    classes = []

    def __init__(self, s, d, c):
        self.step = s
        self.data = d
        self.classes = c

    def has_next(self):
        if self.current < len(self.classes):
            return True
        else:
            return False

    def get_next(self):
        data_length = len(self.data)
        step_end = self.current+self.step

        test_d, test_c = self.data[self.current:step_end], self.classes[self.current:step_end]

        train_d = self.data[0:self.current]
        train_d.extend(self.data[step_end:data_length])

        train_c = self.classes[0:self.current]
        train_c.extend(self.classes[step_end:data_length])

        self.current += self.step

        return train_d, train_c, test_d, test_c