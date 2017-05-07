import numpy as np
import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L
import model, helpers
from model import EOS
import preprocess
import sys

UNKNOWN_WORD = '<unknown>'

def translate(m, id2wd, iline):
    result_words = []

    gh = m.input(iline, volatile='on')

    h2 = m.input_eos(gh, volatile='on')
    wid = np.argmax(F.softmax(m.W(h2)).data[0])
    result_words.append(id2wd.get(wid, UNKNOWN_WORD))

    loop = 0
    while (not m.output_word_id_is_eos(wid)) and (loop <= 30):
        x = m.get_embed_y_by_id(wid, volatile='on')
        h2 = m.output_step(x, gh, volatile='on')
        wid = np.argmax(F.softmax(m.W(h2)).data[0])
        result_words.append(id2wd.get(wid, UNKNOWN_WORD))
        loop += 1

    return ' '.join(result_words)


msg_lines, msg_vocab, msg_dics = helpers.load_train_messages()
msg_vocab[EOS] = len(msg_vocab)

cmd_lines, cmd_vocab, cmd_id2wd = helpers.load_train_commands()
id = len(cmd_vocab)
cmd_vocab[EOS] = id
cmd_id2wd[id] = EOS


print('> ', end='')
test_msg = input() # 'ミーティングは来週の月曜日14時にやる'
text, dic = preprocess.preprocess(test_msg)
print('dic = {0}'.format(dic))
ws = preprocess.tokenize(text)

demb = 100
for epoch in range(20):
    m = model.Attention(msg_vocab, cmd_vocab, demb)
    filename = ".dest/m2c-{}.model".format(epoch)
    serializers.load_npz(filename, m)

    print(epoch, ': ', translate(m, cmd_id2wd, ws))
