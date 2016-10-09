import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


class Iris(Chain):

    def __init__(self):
        super(Iris, self).__init__(
            l1=L.Linear(4, 3),
        )

    def __call__(self, x, y):
        return F.mean_squared_error(self.fwd(x), y)

    def fwd(self, x):
        return F.softmax(self.l1(x))
