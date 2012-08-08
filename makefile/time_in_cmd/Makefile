.PHONY: all fake
all: final.o
final.o: final1.o final2.o
final1.o: medium1.o
	cp medium1.o final1.o

medium1.o: fake initial1
	if [ initial1 -nt medium1.o ]; then cp initial1 medium1.o; fi

final2.o: medium2.o
	cp medium2.o final2.o

medium2.o: fake initial2
	if [ initial2 -nt medium2.o ]; then cp initial2 medium2.o; fi

fake:
