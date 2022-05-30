from re import I
import sys
from turtle import st
from bitstring import Bits

f = open('in.txt', 'r')
g = open('bin.txt', 'w')

lines = f.readlines()
for line in lines:
	instr = line.split(' ')

	if (instr[0] == "add" or instr[0] == "adc" or instr[0] == "adz" or instr[0] == "adl" or instr[0] == "ndu" or instr[0] == "ndc" or instr[0] == "ndz"):
		if instr[0][0] == 'a':
			binline = "0001"
		else:
			binline = "0010"
		binline = binline + '{0:03b}'.format(int(instr[2][1])) + '{0:03b}'.format(int(instr[3][1])) + '{0:03b}'.format(int(instr[1][1])) + "0"
		if instr[0][2] == 'c':
			binline = binline + "01"
		elif instr[0][2] == 'z':
			binline = binline + "10"
		elif instr[0][2] == 'l':
			binline = binline + "11"
		else:
			binline = binline + "00"


	elif instr[0] == "adi":
		imm = int(instr[3])
		b = Bits(int = imm, length=6)
		binline = "0000" + '{0:03b}'.format(int(instr[2][1])) + '{0:03b}'.format(int(instr[1][1])) + b.bin

	elif instr[0] == "lhi":
		imm = int(instr[2])
		b = Bits(int = imm, length=9)
		binline = "1111" + '{0:03b}'.format(int(instr[1][1])) + b.bin

	elif instr[0] == "lw":
		imm = int(instr[3])
		b = Bits(int = imm, length=6)
		binline = "0101" + '{0:03b}'.format(int(instr[1][1])) + '{0:03b}'.format(int(instr[2][1])) + b.bin

	elif instr[0] == "sw":
		imm = int(instr[3])
		b = Bits(int = imm, length=6)
		binline = "0111" + '{0:03b}'.format(int(instr[1][1])) + '{0:03b}'.format(int(instr[2][1])) + b.bin

	elif instr[0] == "lm":
		binline = "1101" + '{0:03b}'.format(int(instr[1][1])) + "0"

		l = ['0' for i in range(8)]
		for i in range(2, len(instr)):
			if(i==2):
				l[len(l)-1-int(instr[i][2])] = '1'
			else:
				l[len(l)-1-int(instr[i][1])] = '1'

		for ele in l: 
			binline += ele

	elif instr[0] == "sm":
		binline = "1100" + '{0:03b}'.format(int(instr[1][1])) + "000000000"

		l  = ['0' for i in range(8)]

		for i in range(2, len(instr)):
			if(i==2):
				l[len(l)-1-int(instr[i][2])] = '1'
			else:
				l[len(l)-1-int(instr[i][1])] = '1'

		for ele in l:
			binline += ele
		


	elif instr[0] == "beq":
		imm = int(instr[3])
		b = Bits(int = imm, length=6)
		binline = "1000" + '{0:03b}'.format(int(instr[1][1])) + '{0:03b}'.format(int(instr[2][1])) + b.bin

	elif instr[0] == "jalr":
		if instr[2][0] == 'r':
			binline = "1010" + '{0:03b}'.format(int(instr[1][1])) + '{0:03b}'.format(int(instr[2][1])) + "000000"
		else:
			imm = int(instr[2])
			b = Bits(int = imm, length=9)
			binline = "1001" + '{0:03b}'.format(int(instr[1][1])) + b.bin

	elif instr[0] == "jri":
			imm = int(instr[2])
			b = Bits(int = imm, length=9)
			binline = "1011" + '{0:03b}'.format(int(instr[1][1])) + b.bin
	else:
		sys.exit("Invalid Instruction")

	g.write(binline + "\n")
