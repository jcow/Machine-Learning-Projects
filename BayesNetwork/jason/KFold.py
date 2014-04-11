
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
        end = self.current+self.step
        d, c = self.data[self.current:end], self.classes[self.current:end]
        self.current += self.step

        return d, c