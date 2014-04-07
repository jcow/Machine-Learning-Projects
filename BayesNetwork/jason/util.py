import operator
import math

class util:

    @staticmethod
    def col( matrix, i):
        return [row[i] for row in matrix]

    @staticmethod
    def prod(iterable):
        return reduce(operator.mul, iterable, 1)

    @staticmethod
    def log_fact(n):
        val = 0
        for i in range(1, n+1):
            val += math.log(i)
        return val