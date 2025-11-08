#!/bin/bash
rm ./ydr.sna
clear
wine sjasmplus.exe Main.asm
./NexC  ydr.txt ydr.nex
wine CSpect.exe -w3 -brk -zxnext ydr.nex
