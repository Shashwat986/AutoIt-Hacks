'''
This program opens the wordlist en.txt and extracts all the words with the most frequency starting with each letter of the alphabet.
These words are stored in a new file unigram.txt
'''

fp = open('en.txt')
fq = open('unigram.txt','w')

alph = list('abcdefghijklmnopqrstuvwxyz')
ctr=0

for line in fp:
	ctr+=1
	if line[0] in alph:
		fq.write(line)
		alph.remove(line[0])
		if len(alph)==0:
			break

print ctr
fp.close()
fq.close()