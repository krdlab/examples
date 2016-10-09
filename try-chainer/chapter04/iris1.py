import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
from impls import basic

train_x = np.loadtxt('.data/iris-train-x.txt').astype(np.float32)
train_y = np.loadtxt('.data/iris-train-y.txt').astype(np.float32)
test_x = np.loadtxt('.data/iris-test-x.txt').astype(np.float32)
test_ans_y = np.loadtxt('.data/iris-test-ans-y.txt').astype(np.int32)


# 学習
model = basic.Iris()
optimizer = optimizers.SGD()
optimizer.setup(model)

n = 75      # data size
bs = 25     # batch size
for j in range(5000):
    indexes = np.random.permutation(n)  # [0, n) の整数をシャッフルしたリスト
    for i in range(0, n, bs):
        end = (i + bs) if (i + bs) < n else n
        x = Variable(train_x[indexes[i:end]])
        y = Variable(train_y[indexes[i:end]])
        model.zerograds()
        loss = model(x, y)
        loss.backward()
        optimizer.update()


# 評価
pred_y = model.fwd(Variable(test_x, volatile=True)).data
pred_nrow, _ = pred_y.shape
correct_count = 0
for i in range(pred_nrow):
    cls = np.argmax(pred_y[i])
    print(pred_y[i], cls)
    if cls == test_ans_y[i]:
        correct_count += 1

print(correct_count, "/", pred_nrow, " = ", (correct_count * 1.0) / pred_nrow)
