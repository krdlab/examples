import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
from impls import from_scratch_old, helpers

name = helpers.get_script_name(__file__)
data_path = '.data/ptb.train.min.txt'
dest_root = '.dest'

vocab = {}
train_data = helpers.load_data(data_path, vocab)

vocab_num = len(vocab)
eos_id = vocab['<eos>']

demb = 100
model = from_scratch_old.Lstm(vocab_num, eos_id, demb)

optimizer = optimizers.Adam()
optimizer.setup(model)

for epoch in range(5):
    s = []
    for pos in range(len(train_data)):
        id = train_data[pos]
        s.append(id)
        if id == eos_id:
            model.zerograds()
            loss = model(s)
            loss.backward()
            if len(s) >= 30:
                loss.unchain_backward()
            optimizer.update()
            s = []

    outfile = "{0}/{1}-{2}.model".format(dest_root, name, epoch)
    serializers.save_npz(outfile, model)

    print('epoch {} finished'.format(epoch))
