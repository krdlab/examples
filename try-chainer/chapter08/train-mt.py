import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
from impls import mt, helpers
from impls.mt import EOS


jvocab = {}
jlines = helpers.load_jp_data('.data/jp.txt', jvocab)
jvocab[EOS] = len(jvocab)

evocab = {}
eid2ewd = {}
elines = helpers.load_en_data('.data/eng.txt', evocab, eid2ewd)
id = len(evocab)
evocab[EOS] = id
eid2ewd[id] = EOS


model = mt.MT(jvocab, evocab, 100)
optimizer = optimizers.Adam()
optimizer.setup(model)

for epoch in range(10):
    for jline, eline in zip(jlines, elines):
        jline = jline.split()[::-1]
        eline = eline.split()

        model.zerograds()
        loss = model(jline, eline)
        loss.backward()
        loss.unchain_backward()
        optimizer.update()

    outfile = ".dest/mt-{}.model".format(epoch)
    serializers.save_npz(outfile, model)

    print(epoch)
