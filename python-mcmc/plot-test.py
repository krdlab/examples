import matplotlib.pyplot as plt
import numpy as np

N = 100
X = np.random.uniform(10, size=N)
Y = X * 10 + 5 + np.random.normal(0, 16, size=N)

fig = plt.figure()
plt.plot(X, Y, "o")
plt.savefig("figures/plot-test.png")
plt.show()
