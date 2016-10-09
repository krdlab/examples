import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


class Gru(Chain):

    def __init__(self, v, eos_id, k):
        super(Gru, self).__init__(
            embed=L.EmbedID(v, k),
            H=L.StatefulGRU(k, k),
            W=L.Linear(k, v)
        )
        self.eos_id = eos_id

    def __call__(self, s):
        accum_loss = None
        _, k = self.embed.W.data.shape
        s_length = len(s)

        self.H.reset_state()
        for i in range(s_length):
            w1 = s[i]
            w2 = s[i + 1] if i < s_length - 1 else self.eos_id
            x_k = self.embed(Variable(np.array([w1], dtype=np.int32)))
            tx = Variable(np.array([w2], dtype=np.int32))

            y = self.H(x_k)
            h = y

            loss = F.softmax_cross_entropy(self.W(y), tx)
            accum_loss = loss if accum_loss is None else accum_loss + loss
        return accum_loss
