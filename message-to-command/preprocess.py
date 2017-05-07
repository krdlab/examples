# -*- coding: utf-8 -*-

import re
import unicodedata
import jaconv
import MeCab


class Node:
    def __init__(self, node):
        self.surface = node.surface
        parts = node.feature.split(',')
        self.word_class = parts[0]
        self.word_sub_class1 = parts[1]
        self.word_sub_class2 = parts[2]
        self.is_unknown = (parts[6] == u'*')
        if self.is_unknown:
            self.original = self.surface
        else:
            self.original = parts[6]

class Morpho:
    def __init__(self, text):
        self.text = text
        self.m = MeCab.Tagger()
        self.m.parse('')
        self.nodes = self.parse()

    def parse(self):
        res = self.m.parseToNode(self.text)
        nodes = []
        while res:
            node = Node(res)
            if node.word_class != u'BOS/EOS':
                nodes.append(node)
            res = res.next
        return nodes


def clean(t):
    t = t.lower()
    t = re.sub(r'[【】]', ' ', t)
    t = re.sub(r'[（）()]', ' ', t)
    t = re.sub(r'[［］\[\]]', ' ', t)
    t = re.sub(r'[　,\.\-_\n]', ' ', t)
    return t

def normalize(t):
    t = unicodedata.normalize('NFKC', t)
    t = jaconv.z2h(t, kana=False, digit=True, ascii=True)
    return t

TIME_PATTERN = re.compile(r'(\d+時)|(\d+時\d+分)|(\d+:\d)')

def generalize_time(t, dic):
    res = ''
    index = 0
    s = 0

    for m in re.finditer(TIME_PATTERN, t):
        res += t[s:m.start()]
        res += (u' time%d ' % (index))
        dic[u'time%d' % (index)] = m.group(1)
        index += 1
        s = m.end()

    if s != len(t):
        res += t[s:len(t)]

    return (res, dic)

def generalize_name(t, dic):
    t = re.sub(r'さん|くん|ちゃん|様|殿|氏', '', t)
    index = 0
    name_dic = dict()

    for n in Morpho(t).nodes:
        if n.word_sub_class2 == u'人名':
            dic['name%d' % (index)] = n.surface
            name_dic['name%d' % (index)] = n.surface
            index += 1

    for k, v in name_dic.items():
        t = re.sub(v, ' {0} '.format(k), t)

    return (t, dic)

def generalize(t):
    dic = dict()
    t, dic = generalize_time(t, dic)
    t, dic = generalize_name(t, dic)
    return (t, dic)


def preprocess(t):
    t = clean(t)
    t = normalize(t)
    return generalize(t)

def tokenize(t):
    res = []
    m = MeCab.Tagger('-Owakati')
    ps = re.sub(r'\n$', '', m.parse(t)).split(' ')
    l = len(ps)
    i = 0
    while i < l:
        if ps[i] in [u'name', u'time']:
            if i + 1 < l and ps[i + 1].isdigit():
                res.append(ps[i] + ps[i + 1])
                i += 1
            else:
                res.append(ps[i])
        else:
            res.append(ps[i])
        i += 1
    return list(filter(lambda x: len(x) > 0, res))

if __name__ == '__main__':
    print('> ', end='')
    text = input()

    text, dic = preprocess(text)
    print('> text = {0}'.format(text))
    print('> dic  = {0}'.format(dic))

    for n in Morpho(text).nodes:
        print('{0:10s} \t {1:10s} \t {2:10s} \t {3}'\
                .format(n.surface, n.word_class, n.original, n.is_unknown))

    print(tokenize(text))
