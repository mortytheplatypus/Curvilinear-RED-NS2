#!/bin/bash

# whichRED :=  0 -> existing RED in VM, 1 -> CLRED, 2 -> basic RED 

cd wired
for whichRED in 0 1 2; do
	for j in {1..3}; do
		./wired.sh $whichRED
	done
done 
cd ..

cd wireless-802.11b
for whichRED in 0 1 2; do
	for j in {1..3}; do
		./wireless-802.11b.sh $whichRED
	done
done 
cd ..
