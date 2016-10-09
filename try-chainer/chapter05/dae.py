import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
from sklearn import datasets
import matplotlib.pyplot as plt


def add_gaussian_noise_to(src):
    mean = 0.0
    sigma = 1.0
    nrow, ncol = src.shape
    noise = np.random.normal(mean, sigma, (nrow, ncol)).astype(np.float32)
    return src + noise


iris = datasets.load_iris()
train_x = iris.data.astype(np.float32)
noised_x = add_gaussian_noise_to(train_x)


class AE(Chain):

    def __init__(self):
        super(AE, self).__init__(
            l1=L.Linear(4, 2),
            l2=L.Linear(2, 4),
        )

    def __call__(self, x):
        fv = F.sigmoid(self.l1(x))
        bv = self.l2(fv)
        return bv

    def error(self, output, expect):
        return F.mean_squared_error(output, expect)


model = AE()
optimizer = optimizers.SGD()
optimizer.setup(model)

n = 150
bs = 30
for j in range(3000):
    permutated = np.random.permutation(n)
    for i in range(0, n, bs):
        end = (i + bs) if (i + bs) < n else n
        x = Variable(noised_x[permutated[i:end]])
        model.zerograds()
        loss = model.error(model(x), x)
        loss.backward()
        optimizer.update()

x = Variable(train_x)
i = F.sigmoid(model.l1(x)).data

i0x = i[0:50, 0]
i0y = i[0:50, 1]
i1x = i[50:100, 0]
i1y = i[50:100, 1]
i2x = i[100:150, 0]
i2y = i[100:150, 1]

plt.scatter(i0x, i0y, marker="^")
plt.scatter(i1x, i1y, marker="o")
plt.scatter(i2x, i2y, marker="+")
plt.show()
