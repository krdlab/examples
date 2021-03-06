import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
import math
import sys

from impls import use_lstm, helpers


def calc_perplexity(model, s):
    sum = 0.0
    _, dim = model.embed.W.data.shape
    for i in range(1, len(s)):
        w1, w2 = s[i - 1], s[i]
        x_k = model.embed(Variable(np.array([w1], dtype=np.int32), volatile='on'))
        y = model.H(x_k)
        h = y
        yv = F.softmax(model.W(y))
        pi = yv.data[0][w2]
        sum -= math.log(pi, 2)
    return sum


model_filename = sys.argv[1]

vocab = {}
train_data = helpers.load_data('.data/ptb.train.min.txt', vocab)
eos_id = vocab['<eos>']
max_id = len(vocab) - 1

demb = 100
model = use_lstm.Lstm(len(vocab), eos_id, demb)
serializers.load_npz(model_filename, model)

test_data = helpers.load_data('.data/ptb.test.txt', vocab)
test_data = test_data[0:1000]

s = []
has_unknown = False
total_word_num = 0
sum = 0.0

for pos in range(len(test_data)):
    id = test_data[pos]
    s.append(id)
    if id > max_id:
        has_unknown = True
    if id == eos_id:
        if not has_unknown:
            ps = calc_perplexity(model, s)
            sum += ps
            total_word_num += len(s) - 1
        else:
            has_unknown = False
        s = []

print(math.pow(2, sum / total_word_num))
