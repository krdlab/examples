import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
import collections
from chainer.utils import walker_alias

index2word = {}     # 単語 ID -> 単語
word2index = {}     # 単語 -> 単語 ID
counts = collections.Counter()
dataset = []        # dataset[コーパス内の位置] = 単語 ID
with open('.data/ptb.train.txt') as f:
    for line in f:
        for word in line.split():
            if word not in word2index:
                i = len(word2index)
                word2index[word] = i
                index2word[i] = word

            word_id = word2index[word]
            counts[word_id] += 1
            dataset.append(word_id)

n_vocab = len(word2index)
datasize = len(dataset)

cs = [counts[w] for w in range(len(counts))]
power = np.float32(0.75)
p = np.array(cs, power.dtype) ** power  # '** powner' が必要だよね？
sampler = walker_alias.WalkerAlias(p)


class Word2Vec(Chain):

    def __init__(self, n_vocab, n_units):
        super(Word2Vec, self).__init__(
            embed=L.EmbedID(n_vocab, n_units)
        )

    def __call__(self, xb, yb, tb):
        xc = Variable(np.array(xb, dtype=np.int32))
        yc = Variable(np.array(yb, dtype=np.int32))
        tc = Variable(np.array(tb, dtype=np.int32))
        fv = self.fwd(xc, yc)
        return F.sigmoid_cross_entropy(fv, tc)

    def fwd(self, x, y):
        xv = self.embed(x)
        yv = self.embed(y)
        return F.sum(xv * yv, axis=1)

demb = 100
model = Word2Vec(n_vocab, demb)
optimizer = optimizers.Adam()
optimizer.setup(model)

window_size = 3
negative_sample_size = 5


def make_batch_set(dataset, ids):
    xb, yb, tb = [], [], []
    for pos in ids:
        xid = dataset[pos]
        for i in range(1, window_size):
            p = pos - i
            if p >= 0:
                xb.append(xid)
                yid = dataset[p]
                yb.append(yid)
                tb.append(1)
                for nid in sampler.sample(negative_sample_size):
                    xb.append(yid)
                    yb.append(nid)
                    tb.append(0)
            p = pos + i
            if p < datasize:
                xb.append(xid)
                yid = dataset[p]
                yb.append(yid)
                tb.append(1)
                for nid in sampler.sample(negative_sample_size):
                    xb.append(yid)
                    yb.append(nid)
                    tb.append(0)
    return [xb, yb, tb]

batch_size = 100
for epoch in range(10):
    print('epoch: {0}'.format(epoch))
    indexes = np.random.permutation(datasize)
    for pos in range(0, datasize, batch_size):
        print(epoch, pos)
        end = (pos + batch_size) if (pos + batch_size) < datasize else datasize
        ids = indexes[pos:end]
        xb, yb, tb = make_batch_set(dataset, ids)
        model.zerograds()
        loss = model(xb, yb, tb)
        loss.backward()
        optimizer.update()

with open('.dest/word2vec.model', 'w') as f:
    f.write('%d %d\n' % (len(index2word), demb))
    w = model.embed.W.data
    w_nrow, _ = w.shape
    for r in range(w_nrow):
        v = ' '.join(['%f' % vi for vi in w[r]])
        f.write('%s %s\n' % (index2word[r], v))
