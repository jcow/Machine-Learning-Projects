from itertools import combinations
import random

def consistent(hypo1, hypo2, cls):
    r = []
    for h1, h2 in zip(hypo1, hypo2):
        if h1 == '?' or h2 == '?':
            r.append(True)
            continue
        if h1 == '' or h2 == '':
            r.append(False)
            continue
        r.append(h1 == h2)
    return all(r) == cls

def versionspace(hypos, classes):
    hyposize = len(hypos[0])
    G = [['?' for _ in range(hyposize)]]
    S = [['' for _ in range(hyposize)]]

    for hypo, cls in zip(hypos, classes):
        if cls:
            # positive example
            # remove inconsistent hypotheses from G
            G = filter(lambda x: consistent(x, hypo, cls), G)
            # deal with S
            Snew = []
            for s in S:
                if consistent(hypo, s, cls):
                    continue
                # remove inconsistent hypotheses and add generalizations
                snew = []
                for si, hi in zip(s, hypo):
                    if si == '':
                        snew.append(hi)
                        continue
                    if si != '?' and si != hi:
                        snew.append('?')
                        continue
                    snew.append(si)
                Snew.append(snew)
            S = Snew
            # remove from S any hypothesis more general than any other but this
            # is a noop since we never get more than one element in S
            pass
        else:
            # negative example
            # remove inconsistent hypotheses from S, this is a noop
            pass
            # deal with G
            Gnew = []
            for g in G:
                if consistent(hypo, g, cls):
                    continue
                # remove inconsistent hypotheses and add specializations
                for i in range(len(hypo)):
                    if S[0][i] != '?' and S[0][i] != hypo[i]:
                        gnew = ['?' for _ in range(len(hypo))]
                        gnew[i] = S[0][i]
                        Gnew.append(gnew)
            G = Gnew
    # Create the version space
    inds = []
    for i in range(len(S[0])):
        if S[0][i] != '?':
            inds.append(i)
    valueinds = list(combinations(inds, len(inds) - 1))
    V = []
    for vi in valueinds:
        vnew = []
        for i in range(len(hypo)):
            if i in vi:
                vnew.append(S[0][i])
            else:
                vnew.append('?')
        V.append(vnew)
    return G, S, V

def classify(G, S, V, candidate, cls):
    yes = 0
    no = 0
    for voter in G + S + V:
        if consistent(voter, candidate, cls):
            yes += 1
        else:
            no += 1
    return yes > no

# Testing
hypos = [
        ['sunny', 'warm', 'normal', 'strong', 'warm', 'same'],
        ['sunny', 'warm', 'high', 'strong', 'warm', 'same'],
        ['rainy', 'cold', 'high', 'strong', 'warm', 'change'],
        ['sunny', 'warm', 'high', 'strong', 'cool', 'change']
        ]
classes = [True, True, False, True]

G, S, V = versionspace(hypos, classes)
print V

# Run with actual data
hypos = []
classes = []
raw = []
with open('trainingDataCandElim.csv', 'r') as datafile:
    datafile.readline() # Burn the first line
    for row in datafile:
        raw.append(row.split(','))

# Permute
random.shuffle(raw)

for data in raw:
    hypos.append(data[:6])
    classes.append(data[6] == 'Enjoy Sport')

for i in range(10):
    start = i * 10
    training_hypos = hypos[0:start] + hypos[start+10:]
    training_classes = classes[0:start] + classes[start+10:]
    testing_hypos = hypos[start:start+10]
    testing_classes = classes[start:start+10]

    G, S, V = versionspace(training_hypos, training_classes)

    res = []
    for j in range(10):
        res.append(classify(G, S, V, testing_hypos[j], testing_classes[j]))
    print sum(res), 'correct out of 10'













