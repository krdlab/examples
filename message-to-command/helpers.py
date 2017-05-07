import preprocess

def load_train_messages():
    filename = '.data/messages.txt'
    lines = []
    vocab = {}
    dics = []

    org_lines = None
    with open(filename) as f:
        itr = f.read().split('\n')
        itr = filter(lambda l: l, itr)
        org_lines = list(itr)

    for l in org_lines:
        text, d = preprocess.preprocess(l)
        dics.append(d)
        ws = preprocess.tokenize(text)
        lines.append(' '.join(ws))
        for w in ws:
            if w not in vocab:
                vocab[w] = len(vocab)

    return (lines, vocab, dics)

def load_train_commands():
    filename = '.data/commands.txt'
    lines = None
    vocab = {}
    id2wd = {}

    with open(filename) as f:
        itr = f.read().split('\n')
        itr = filter(lambda l: l, itr)
        lines = list(itr)

    for l in lines:
        ws = l.split()
        for w in ws:
            if w not in vocab:
                id = len(vocab)
                vocab[w] = id
                id2wd[id] = w

    return (lines, vocab, id2wd)
