import os
import numpy as np


def get_script_name(p):
    return os.path.splitext(os.path.basename(p))[0]


def load_data(filename, vocab):
    words = open(filename).read().replace('\n', '<eos>').strip().split()
    dataset = np.ndarray((len(words),), dtype=np.int32)
    for i, word in enumerate(words):
        if word not in vocab:
            vocab[word] = len(vocab)
        dataset[i] = vocab[word]
    return dataset
