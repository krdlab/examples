import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


class MyChain(Chain):

    def __init__(self):
        super(MyChain, self).__init__(
            l1=L.Linear(4, 3),
            l2=L.Linear(3, 3),
        )

    def __call__(self, x, y):
        fv = self.fwd(x)
        loss = F.mean_squared_error(fv, y)
        return loss

    def fwd(self, x):
        return self.l2(F.sigmoid(self.l1(x)))


model = MyChain()
optimizer = optimizers.SGD()
optimizer.setup(model)

x = Variable(np.array([[1, 0, 0, 0], [1, 0, 0, 0]]).astype(np.float32))
y = Variable(np.array([[0, 0, 1], [0, 0, 1]]).astype(np.float32))

for epoch in range(100):
    model.zerograds()
    loss = model(x, y)
    loss.backward()
    optimizer.update()

    print("epoch {}: {}".format(epoch, loss.data))
    print(model.l1.W.data)
    print(model.l1.b.data)
    print(model.l2.W.data)
    print(model.l2.b.data)
