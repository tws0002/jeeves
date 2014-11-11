#!/usr/bin/env python

import nuke

def RenderSpecificFrames():
	sRanges = nuke.getInput("Enter frames ranges, separated by spaces. Ex: 4 10,20 100,150,2")
	print sRanges
	lRanges = sRanges.split()
	lNukeRanges = []
	for sRange in lRanges:
		lRange = sRange.split(',')
		lRange = [int(i) for i in lRange]
		if len(lRange) == 0:
			continue
		elif len(lRange) == 1:  # Only start frame. Add end frame (same as start frame) and step (1).
			lRange.extend([lRange[0], 1])
		elif len(lRange) == 2:  # Start frame and End Frame. Add step (1)
			lRange.extend([1])
		elif len(lRange) > 3:   # 4 Elements. Error.
			nuke.message("Wrong format: %s. Cannot process 4 elements" % str(lRange))
			return False
		lNukeRanges.append(lRange)

	print lNukeRanges
	nuke.executeMultiple(nuke.selectedNodes(), lNukeRanges)

RenderSpecificFrames()