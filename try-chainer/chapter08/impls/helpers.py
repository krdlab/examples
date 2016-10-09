import re


def load_jp_data(filename, jvocab):
    jlines = None

    with open(filename) as f:
        itr = f.read().split('\n')
        itr = filter(lambda l: l, itr)
        jlines = list(itr)

    for l in jlines:
        ws = l.split()
        for w in ws:
            if w not in jvocab:
                jvocab[w] = len(jvocab)

    return jlines


def load_en_data(filename, evocab, id2wd):
    elines = None

    with open('.data/eng.txt') as f:
        itr = f.read().split('\n')
        itr = filter(lambda l: l, itr)
        itr = map(lambda l: l.lower(), itr)
        itr = map(lambda l: re.sub(r'^(.+)\.$', r'\1 .', l), itr)
        itr = map(lambda l: re.sub(r'([",\'\(\)\[\]])', r' \1 ', l), itr)
        elines = list(itr)

    for l in elines:
        ws = l.split()
        for w in ws:
            if w not in evocab:
                id = len(evocab)
                evocab[w] = id
                id2wd[id] = w

    return elines
