def process_corpus(corpus, new):
    with open(corpus) as f:
        with open(new, 'w') as t:
            for line in f.readlines():
                line = line.upper()
                '''
                line = line.replace('.', '\n')
                line = line.replace('-', '\n')
                line = line.replace('<P>', '')
                line = line.replace(',', '\n')
                line = line.replace(';', '\n')
                line = line.replace('(', '')
                line = line.replace('#', '')
                line = line.replace(')', '')
                line = line.replace('</P>', '')
                line = line.replace('<', '')
                line = line.replace('>', '')
                line = line.replace('\'', '')
                line = line.replace(':', '')
                line = line.replace('/', ' ')
                line = line.replace('1', 'ONE ')
                line = line.replace('2', 'TWO ')
                line = line.replace('3', 'THREE ')
                line = line.replace('4', 'FOUR ')
                line = line.replace('5', 'FIVE ')
                line = line.replace('6', 'SIX ')
                line = line.replace('7', 'SEVEN ')
                line = line.replace('8', 'EIGHT ')
                line = line.replace('9', 'NINE ')
                line = line.replace('0', 'ZERO ')
                line = line.replace('+', 'PLUS ')
                line = line.replace('_', ' ')
                line = line.replace('  ', ' ')
                '''
                t.write(line)
    


#process_corpus('TED_LIUM.txt', 'TED_preprocessed.txt')

def repeat_combine_corpus(corpusa, corpusb, new):
    t = open(new, 'w')
    with open(corpusa) as f:
        for line in f.readlines():
            t.write((line)*160)
     
    with open(corpusb) as f:
        for line in f.readlines():
            t.write(line)
    t.close()

repeat_combine_corpus('corpusTUTDOC.txt', 'corpus.txt', 'combined.txt')

