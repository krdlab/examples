import numpy as np
from sklearn import datasets

iris = datasets.load_iris()
x = iris.data.astype(np.float32)
y = iris.target
n = y.size

y2 = np.zeros(n * 3).reshape(n, 3).astype(np.float32)

for i in range(n):
    y2[i, y[i]] = 1.0

index = np.arange(n)

x_train = x[index[index % 2 != 0], :]
y_train = y2[index[index % 2 != 0], :]

x_test = x[index[index % 2 == 0], :]
y_ans = y[index[index % 2 == 0]]

np.savetxt('.data/iris-x.txt', x)
np.savetxt('.data/iris-y.txt', y)
np.savetxt('.data/iris-train-x.txt', x_train)
np.savetxt('.data/iris-train-y.txt', y_train)
np.savetxt('.data/iris-test-x.txt', x_test)
np.savetxt('.data/iris-test-ans-y.txt', y_ans)
