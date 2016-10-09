import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


class Lstm(Chain):

    def __init__(self, v, eos_id, k):
        super(Lstm, self).__init__(
            embed=L.EmbedID(v, k),
            Wz=L.Linear(k, k),
            Wi=L.Linear(k, k),
            Wf=L.Linear(k, k),
            Wo=L.Linear(k, k),
            Rz=L.Linear(k, k),
            Ri=L.Linear(k, k),
            Rf=L.Linear(k, k),
            Ro=L.Linear(k, k),
            W=L.Linear(k, v)
        )
        self.eos_id = eos_id

    def __call__(self, s):
        accum_loss = None
        _, k = self.embed.W.data.shape
        h = Variable(np.zeros((1, k), dtype=np.float32))
        c = Variable(np.zeros((1, k), dtype=np.float32))
        s_length = len(s)
        for i in range(s_length):
            w1 = s[i]
            w2 = s[i + 1] if i < s_length - 1 else self.eos_id
            x_k = self.embed(Variable(np.array([w1], dtype=np.int32)))
            tx = Variable(np.array([w2], dtype=np.int32))
            z0 = self.Wz(x_k) + self.Rz(F.dropout(h))
            z1 = F.tanh(z0)
            i0 = self.Wi(x_k) + self.Ri(F.dropout(h))
            i1 = F.sigmoid(i0)
            f0 = self.Wf(x_k) + self.Rf(F.dropout(h))
            f1 = F.sigmoid(f0)
            c = i1 * z1 + f1 * c
            o0 = self.Wo(x_k) + self.Ro(F.dropout(h))
            o1 = F.sigmoid(o0)
            y = o1 * F.tanh(c)
            h = y
            loss = F.softmax_cross_entropy(self.W(y), tx)
            accum_loss = loss if accum_loss is None else accum_loss + loss
        return accum_loss
