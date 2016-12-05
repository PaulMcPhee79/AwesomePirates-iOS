#!/bin/bash

rm ../../Art/Audio/aifc/*.aifc
rm ../../Art/Audio/caf/*.caf

for i in ../Audio/aiff/*.aiff; do
	afconvert -f AIFC -d ima4@22050 -c 1 $i
done

for i in ../Audio/aiff-HQ/*.aiff; do
	afconvert -f AIFC -d ima4@22050 -c 1 $i
done

mv ../Audio/aiff/*.aifc ../../Art/Audio/aifc/
mv ../Audio/aiff-HQ/*.aifc ../../Art/Audio/aifc/

for i in ../Audio/wav/*.wav; do
	afconvert -f caff -d LEI16@22050 -c 1 $i
done

mv ../Audio/wav/*.caf ../../Art/Audio/caf/
