import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
import model, helpers
from model import EOS


msg_lines, msg_vocab, msg_dics = helpers.load_train_messages()
msg_vocab[EOS] = len(msg_vocab)
# TODO: dump vocab

cmd_lines, cmd_vocab, cmd_id2wd = helpers.load_train_commands()
id = len(cmd_vocab)
cmd_vocab[EOS] = id
cmd_id2wd[id] = EOS


embedded_dim = 100
model = model.Attention(msg_vocab, cmd_vocab, embedded_dim)
optimizer = optimizers.Adam()
optimizer.setup(model)

for epoch in range(20):
    for mline, cline in zip(msg_lines, cmd_lines):
        mline = mline.split()
        cline = cline.split()

        model.cleargrads()
        loss = model(mline, cline)
        loss.backward()
        loss.unchain_backward()
        optimizer.update()

    outfile = ".dest/m2c-{}.model".format(epoch)
    serializers.save_npz(outfile, model)

    print(epoch)
