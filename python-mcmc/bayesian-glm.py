# http://pymc-devs.github.io/pymc3/GLM-linear/

import pymc3 as pm
import numpy as np
import matplotlib.pyplot as plt

size = 200
true_intercept = 1
true_slope = 2

x = np.linspace(0, 1, size)
true_regression_line = true_intercept + true_slope * x
y = true_regression_line + np.random.normal(scale=0.5, size=size)

data = dict(x=x, y=y)

fig = plt.figure(figsize=(7, 7))
ax = fig.add_subplot(111, xlabel='x', ylabel='y',
                     title='Generated data and underlying model')
ax.plot(x, y, 'x', label='sampled data')
ax.plot(x, true_regression_line, label='true regression line', lw=2.0)
plt.legend(loc=0)
plt.savefig("figures/glm-01.png")

with pm.Model() as model:
    sigma = pm.HalfCauchy('sigma', beta=10, testval=1.0)
    intercept = pm.Normal('Intercept', 0, sd=20)
    x_coeff = pm.Normal('x', 0, sd=20)

    likelihood = pm.Normal('y', mu=intercept + x_coeff * x,
                           sd=sigma, observed=y)

    start = pm.find_MAP()
    step = pm.NUTS(scaling=start)
    trace = pm.sample(2000, step, start=start, progressbar=True)

plt.figure(figsize=(7, 7))
pm.traceplot(trace[100:])
plt.tight_layout()
plt.savefig("figures/glm-02.png")

plt.figure(figsize=(7, 7))
plt.plot(x, y, 'x', label='data')
pm.glm.plot_posterior_predictive(trace, samples=100,
                                 label='posterior predictive regression lines')
plt.plot(x, true_regression_line, label='true regression line', lw=3.0, c='y')
plt.title('Posterior predictive regression lines')
plt.legend(loc=0)
plt.xlabel('x')
plt.ylabel('y')
plt.savefig("figures/glm-03.png")
plt.show()
