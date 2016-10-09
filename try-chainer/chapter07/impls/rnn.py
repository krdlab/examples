import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


class Rnn(Chain):

    def __init__(self, v, eos_id, k):
        super(Rnn, self).__init__(
            embed=L.EmbedID(v, k),
            H=L.Linear(k, k),
            W=L.Linear(k, v)
        )
        self.eos_id = eos_id

    def __call__(self, s):
        accum_loss = None
        _, k = self.embed.W.data.shape
        h = Variable(np.zeros((1, k), dtype=np.float32))
        s_length = len(s)
        for i in range(s_length):
            w1 = s[i]
            w2 = s[i + 1] if i < s_length - 1 else self.eos_id
            x_k = self.embed(Variable(np.array([w1], dtype=np.int32)))
            tx = Variable(np.array([ws], dtype=np.int32))
            h = F.tanh(x_k + self.H(h))
            loss = F.softmax_cross_entropy(self.W(h), tx)
            accum_loss = loss if accum_loss is None else accum_loss + loss
        return accum_loss
