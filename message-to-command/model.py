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

    def __init__(self, in_vocab, out_vocab, k):
        iv_size, ov_size = len(in_vocab), len(out_vocab)
        super(Attention, self).__init__(
            embedx=L.EmbedID(iv_size, k),
            embedy=L.EmbedID(ov_size, k),
            H=L.LSTM(k, k),
            Wc1=L.Linear(k, k),
            Wc2=L.Linear(k, k),
            W=L.Linear(k, ov_size)
        )
        self.in_vocab  = in_vocab
        self.out_vocab = out_vocab

    def get_embed_x(self, word, volatile='off'):
        wid = self.in_vocab[word]
        var = Variable(np.array([wid], dtype=np.int32), volatile=volatile)
        return self.embedx(var)

    def get_embed_y(self, word, volatile='off'):
        wid = self.out_vocab[word]
        return self.get_embed_y_by_id(wid, volatile=volatile)

    def get_embed_y_by_id(self, wid, volatile='off'):
        var = Variable(np.array([wid], dtype=np.int32), volatile=volatile)
        return self.embedy(var)

    def input(self, ws, volatile='off'):
        gh = []
        for w in ws:
            x = self.get_embed_x(w, volatile=volatile)
            h = self.H(x)
            gh.append(np.copy(h.data[0]))
        return gh

    def input_eos(self, gh, volatile='off'):
        x = self.get_embed_x(EOS, volatile=volatile)
        return self.output_step(x, gh, volatile=volatile)

    def output_step(self, x, gh, volatile='off'):
        h = self.H(x)
        ct = Variable(mk_ct(gh, h.data[0]), volatile=volatile)
        return F.tanh(self.Wc1(ct) + self.Wc2(h))

    def __call__(self, iline, oline):
        self.H.reset_state()

        gh = self.input(iline)
        h2 = self.input_eos(gh)

        tx = Variable(np.array([self.out_vocab[oline[0]]], dtype=np.int32))
        accum_loss = F.softmax_cross_entropy(self.W(h2), tx)

        for i in range(len(oline)):
            x = self.get_embed_y(oline[i])
            h2 = self.output_step(x, gh)

            next_w = oline[i + 1] if i < len(oline) - 1 else EOS
            next_wid = self.out_vocab[next_w]

            tx = Variable(np.array([next_wid], dtype=np.int32))
            loss = F.softmax_cross_entropy(self.W(h2), tx)
            accum_loss += loss

        return accum_loss

    def output_word_id_is_eos(self, wid):
        return wid == self.out_vocab[EOS]
