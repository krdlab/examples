import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L


EOS = '<eos>'


class MT(Chain):

    def __init__(self, jvocab, evocab, k):
        jv, ev = len(jvocab), len(evocab)
        super(MT, self).__init__(
            embedx=L.EmbedID(jv, k),
            embedy=L.EmbedID(ev, k),
            H=L.LSTM(k, k),
            W=L.Linear(k, ev)
        )
        self.jvocab = jvocab
        self.evocab = evocab

    def __call__(self, jline, eline):
        self.H.reset_state()
        for w in jline:
            wid = self.jvocab[w]
            x_k = self.embedx(Variable(np.array([wid], dtype=np.int32)))
            h = self.H(x_k)

        x_k = self.embedx(Variable(np.array([self.jvocab[EOS]], dtype=np.int32)))
        tx = Variable(np.array([self.evocab[eline[0]]], dtype=np.int32))
        h = self.H(x_k)
        accum_loss = F.softmax_cross_entropy(self.W(h), tx)

        for i in range(len(eline)):
            wid = self.evocab[eline[i]]
            x_k = self.embedy(Variable(np.array([wid], dtype=np.int32)))
            next_w = eline[i + 1] if i < len(eline) - 1 else EOS
            next_wid = self.evocab[next_w]
            tx = Variable(np.array([next_wid], dtype=np.int32))
            h = self.H(x_k)
            loss = F.softmax_cross_entropy(self.W(h), tx)
            accum_loss += loss

        return accum_loss
