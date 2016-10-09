import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
from impls import attention, helpers
from impls.attention import EOS


def translate(model, id2wd, jline):
    result_words = []

    gh = []
    for w in jline:
        wid = model.jvocab[w]
        x_k = model.embedx(Variable(np.array([wid], dtype=np.int32), volatile='on'))
        h = model.H(x_k)
        gh.append(h.data[0])

    x_k = model.embedx(Variable(np.array([model.jvocab[EOS]], dtype=np.int32), volatile='on'))
    h = model.H(x_k)
    ct = Variable(attention.mk_ct(gh, h.data[0]), volatile='on')
    h2 = F.tanh(model.Wc1(ct) + model.Wc2(h))
    wid = np.argmax(F.softmax(model.W(h2)).data[0])
    result_words.append(id2wd.get(wid, wid))

    loop = 0
    while (wid != model.evocab[EOS]) and (loop <= 30):
        x_k = model.embedy(Variable(np.array([wid], dtype=np.int32), volatile='on'))
        h = model.H(x_k)
        ct = Variable(attention.mk_ct(gh, h.data[0]), volatile='on')
        h2 = F.tanh(model.Wc1(ct) + model.Wc2(h))
        wid = np.argmax(F.softmax(model.W(h2)).data[0])
        result_words.append(id2wd.get(wid, wid))
        loop += 1

    return ' '.join(result_words)


jvocab = {}
jlines = helpers.load_jp_data('.data/jp.txt', jvocab)
jvocab[EOS] = len(jvocab)

evocab = {}
eid2ewd = {}
elines = helpers.load_en_data('.data/eng.txt', evocab, eid2ewd)
id = len(evocab)
evocab[EOS] = id
eid2ewd[id] = EOS

jtests = None
with open('.data/jp-test.txt') as f:
    itr = f.read().split('\n')
    itr = filter(lambda l: l, itr)
    jtests = list(itr)

demb = 100
for epoch in range(50):
    model = attention.Attention(jvocab, evocab, demb)
    filename = ".dest/attention-{}.model".format(epoch)
    serializers.load_npz(filename, model)
    for jtest in jtests:
        jtest = jtest.split()[::-1]
        print(epoch, ': ', translate(model, eid2ewd, jtest))
