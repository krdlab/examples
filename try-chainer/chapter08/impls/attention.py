import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


EOS = '<eos>'


def mk_ct(gh, ht):
    s = 0.0
    for h in gh:
        s += np.exp(ht.dot(h))

    dim = ht.size
    ct = np.zeros(dim)
    for h in gh:
        ai = np.exp(ht.dot(h)) / s
        ct += ai * h

    return np.array([ct]).astype(np.float32)


class Attention(Chain):

    def __init__(self, jvocab, evocab, k):
        jv, ev = len(jvocab), len(evocab)
        super(Attention, self).__init__(
            embedx=L.EmbedID(jv, k),
            embedy=L.EmbedID(ev, k),
            H=L.LSTM(k, k),
            Wc1=L.Linear(k, k),
            Wc2=L.Linear(k, k),
            W=L.Linear(k, ev)
        )
        self.jvocab = jvocab
        self.evocab = evocab

    def __call__(self, jline, eline):
        gh = []
        self.H.reset_state()
        for w in jline:
            wid = self.jvocab[w]
            x_k = self.embedx(Variable(np.array([wid], dtype=np.int32)))
            h = self.H(x_k)
            gh.append(np.copy(h.data[0]))

        x_k = self.embedx(Variable(np.array([self.jvocab[EOS]], dtype=np.int32)))
        tx = Variable(np.array([self.evocab[eline[0]]], dtype=np.int32))
        h = self.H(x_k)
        ct = Variable(mk_ct(gh, h.data[0]))
        h2 = F.tanh(self.Wc1(ct) + self.Wc2(h))
        accum_loss = F.softmax_cross_entropy(self.W(h2), tx)

        for i in range(len(eline)):
            wid = self.evocab[eline[i]]
            x_k = self.embedy(Variable(np.array([wid], dtype=np.int32)))
            next_w = eline[i + 1] if i < len(eline) - 1 else EOS
            next_wid = self.evocab[next_w]
            tx = Variable(np.array([next_wid], dtype=np.int32))
            h = self.H(x_k)
            ct = Variable(mk_ct(gh, h.data[0]))
            h2 = F.tanh(self.Wc1(ct) + self.Wc2(h))
            loss = F.softmax_cross_entropy(self.W(h2), tx)
            accum_loss += loss

        return accum_loss
