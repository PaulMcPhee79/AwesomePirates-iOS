#!/bin/bash

TP="/usr/local/bin/TexturePacker"
FONT_PATH_1X="../Graphics/@1x/Atlases"
FONT_PATH_2X="../Graphics/@2x/Atlases"
GFX_PATH_1X="../Graphics/@1x/Atlases"
GFX_PATH_2X="../Graphics/@2x/Atlases"
OUT_PATH_1X="../../Art/Graphics/@1x/Atlases"
OUT_PATH_2X="../../Art/Graphics/@2x/Atlases"
OUT_PATH_HD="../../Art/Graphics/@hd/Atlases"

RES_PATH_IMAGES_1X="../../Art/Graphics/@1x/Images"
RES_PATH_IMAGES_2X="../../Art/Graphics/@2x/Images"
RES_PATH_IMAGES_HD="../../Art/Graphics/@hd/Images"
RES_PATH_FONTS_1X="../../Art/Graphics/@1x/Fonts"
RES_PATH_FONTS_2X="../../Art/Graphics/@2x/Fonts"

if [ "${1}" = "clean" ]
then
	echo "cleaning..."
	
	# 1x
	rm -f ${OUT_PATH_1X}/*.xml
	rm -f ${OUT_PATH_1X}/*.pvr.gz
	rm -f ${OUT_PATH_1X}/*.png
	
	rm -f ${RES_PATH_IMAGES_1X}/*.png
	rm -f ${RES_PATH_IMAGES_1X}/*.pvr
	rm -f ${RES_PATH_IMAGES_1X}/uiview/*.png
	rm -f ${RES_PATH_FONTS_1X}/*.fnt
	
	# 2x
	rm -f ${OUT_PATH_2X}/*.xml
	rm -f ${OUT_PATH_2X}/*.pvr.gz
	rm -f ${OUT_PATH_2X}/*.png
	
	rm -f ${RES_PATH_IMAGES_2X}/*.png
	rm -f ${RES_PATH_IMAGES_2X}/*.pvr
	rm -f ${RES_PATH_IMAGES_2X}/uiview/*.png
	rm -f ${RES_PATH_FONTS_2X}/*.fnt
	
	# hd Images
	rm -f ${RES_PATH_IMAGES_HD}/*.png
else
	echo "building..."
	
	# 1x Images and Fonts
	cp ../Graphics/@2x/Images/*.png ${RES_PATH_IMAGES_1X}
	cp ../Graphics/@2x/Images/*.pvr ${RES_PATH_IMAGES_1X}
	cp ../Graphics/@2x/Images/uiview/*.png ${RES_PATH_IMAGES_1X}/uiview/
	cp ../Graphics/@1x/Atlases/font/*.fnt ${RES_PATH_FONTS_1X}

	mogrify -scale 50% ${RES_PATH_IMAGES_1X}/*.png
	mogrify -scale 50% ${RES_PATH_IMAGES_1X}/uiview/*.png


	for i in ${RES_PATH_IMAGES_1X}/*@2x.png
	do
		NEW_PATH=${i/%@2x.png/.png}
		mv $i $NEW_PATH
	done

	for i in ${RES_PATH_IMAGES_1X}/*@2x.pvr
	do
		NEW_PATH=${i/%@2x.pvr/.pvr}
		mv $i $NEW_PATH
	done

	for i in ${RES_PATH_IMAGES_1X}/uiview/*@2x.png
	do
		NEW_PATH=${i/%@2x.png/.png}
		mv $i $NEW_PATH
	done
	
	# 2x Images and Fonts
	cp ../Graphics/@2x/Images/*.png ${RES_PATH_IMAGES_2X}
	cp ../Graphics/@2x/Images/*.pvr ${RES_PATH_IMAGES_2X}
	cp ../Graphics/@2x/Images/uiview/*.png ${RES_PATH_IMAGES_2X}/uiview/
	cp ../Graphics/@2x/Atlases/font/*.fnt ${RES_PATH_FONTS_2X}

	# hd Images
	cp ../Graphics/@hd/Images/*.png  ${RES_PATH_IMAGES_HD}
	
	
	# Achievements SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/achievements \
			--data ${OUT_PATH_1X}/achievements-atlas.xml \
			--sheet ${OUT_PATH_1X}/achievements-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Achievements HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/achievements \
			--data ${OUT_PATH_2X}/achievements-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/achievements-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Cabin SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/swindlers-shops/cabin \
			--data ${OUT_PATH_1X}/cabin-atlas.xml \
			--sheet ${OUT_PATH_1X}/cabin-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Cabin HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/swindlers-shops/cabin \
			--data ${OUT_PATH_2X}/cabin-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/cabin-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Company SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/company \
			--data ${OUT_PATH_1X}/company-atlas.xml \
			--sheet ${OUT_PATH_1X}/company-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Company HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/company \
			--data ${OUT_PATH_2X}/company-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/company-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Doubloon Notifier SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/doubloon-notifier \
			--data ${OUT_PATH_1X}/doubloon-notifier-atlas.xml \
			--sheet ${OUT_PATH_1X}/doubloon-notifier-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Doubloon Notifier HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/doubloon-notifier \
			--data ${OUT_PATH_2X}/doubloon-notifier-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/doubloon-notifier-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Cove Common SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/common \
			--data ${OUT_PATH_1X}/cove-common-atlas.xml \
			--sheet ${OUT_PATH_1X}/cove-common-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Cove Common HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/common \
			--data ${OUT_PATH_2X}/cove-common-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/cove-common-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Cove Entrance SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/entrance \
			--data ${OUT_PATH_1X}/cove-entrance-atlas.xml \
			--sheet ${OUT_PATH_1X}/cove-entrance-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Cove Entrance HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/entrance \
			--data ${OUT_PATH_2X}/cove-entrance-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/cove-entrance-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Ethereal's Haunt SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/etherealsHauntVenue \
			--data ${OUT_PATH_1X}/ethereals-haunt-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/ethereals-haunt-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Ethereal's Haunt HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/etherealsHauntVenue \
			--data ${OUT_PATH_2X}/ethereals-haunt-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/ethereals-haunt-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# FancyText SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/fancy-text \
			--data ${OUT_PATH_1X}/fancy-text-atlas.xml \
			--sheet ${OUT_PATH_1X}/fancy-text-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# FancyText HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/fancy-text \
			--data ${OUT_PATH_2X}/fancy-text-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/fancy-text-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Font SD
	${TP}	--smart-update \
			--format sparrow \
			${FONT_PATH_1X}/font \
			--data ${OUT_PATH_1X}/font-atlas.xml \
			--sheet ${OUT_PATH_1X}/font-atlas.png \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Font HD
	${TP}	--smart-update \
			--format sparrow \
			${FONT_PATH_2X}/font \
			--data ${OUT_PATH_2X}/font-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/font-atlas@2x.png \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Gadget Shop SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/swindlers-shops/gadget-shop \
			--data ${OUT_PATH_1X}/gadget-atlas.xml \
			--sheet ${OUT_PATH_1X}/gadget-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Gadget Shop HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/swindlers-shops/gadget-shop \
			--data ${OUT_PATH_2X}/gadget-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/gadget-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Gameover SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/gameover \
			--data ${OUT_PATH_1X}/gameover-atlas.xml \
			--sheet ${OUT_PATH_1X}/gameover-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Gameover HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/gameover \
			--data ${OUT_PATH_2X}/gameover-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/gameover-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Handbook SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/handbook \
			--data ${OUT_PATH_1X}/handbook-atlas.xml \
			--sheet ${OUT_PATH_1X}/handbook-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Handbook HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/handbook \
			--data ${OUT_PATH_2X}/handbook-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/handbook-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Help SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/help \
			--data ${OUT_PATH_1X}/help-atlas.xml \
			--sheet ${OUT_PATH_1X}/help-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Help HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/help \
			--data ${OUT_PATH_2X}/help-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/help-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Loading SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/loading \
			--data ${OUT_PATH_1X}/loading-atlas.xml \
			--sheet ${OUT_PATH_1X}/loading-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Loading HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/loading \
			--data ${OUT_PATH_2X}/loading-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/loading-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# Loading iPad
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/loading_hd \
			--data ${OUT_PATH_HD}/loading-atlas_hd@2x.xml \
			--sheet ${OUT_PATH_HD}/loading-atlas_hd@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Merchant Venue SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/merchantVenue \
			--data ${OUT_PATH_1X}/merchant-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/merchant-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Merchant Venue HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/merchantVenue \
			--data ${OUT_PATH_2X}/merchant-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/merchant-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Parlor Venue SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/parlorVenue \
			--data ${OUT_PATH_1X}/parlor-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/parlor-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Parlor Venue HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/parlorVenue \
			--data ${OUT_PATH_2X}/parlor-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/parlor-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Pause SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/pause \
			--data ${OUT_PATH_1X}/pause-atlas.xml \
			--sheet ${OUT_PATH_1X}/pause-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Pause HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/pause \
			--data ${OUT_PATH_2X}/pause-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/pause-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Playfield SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/playfield \
			--data ${OUT_PATH_1X}/playfield-atlas.xml \
			--sheet ${OUT_PATH_1X}/playfield-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Playfield HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/playfield \
			--data ${OUT_PATH_2X}/playfield-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/playfield-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Railings SD
	for i in ${GFX_PATH_1X}/railings/*.png
	do
		RAILING=$(basename $i .png)
	
		${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/railings/$RAILING.png \
			--data ${OUT_PATH_1X}/railings/$RAILING-atlas.xml \
			--sheet ${OUT_PATH_1X}/railings/$RAILING-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 0 \
			--disable-rotation \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
	done

	# Railings HD
	for i in ${GFX_PATH_2X}/railings/*.png
	do
		RAILING=$(basename $i .png)

		${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/railings/$RAILING.png \
			--data ${OUT_PATH_2X}/railings/$RAILING-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/railings/$RAILING-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 0 \
			--disable-rotation \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
	done

	# ---------------------------------------------------------------------------------
	
	# Scum Prison Venue SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/scumPrisonVenue \
			--data ${OUT_PATH_1X}/scum-prison-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/scum-prison-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Scum Prison Venue HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/scumPrisonVenue \
			--data ${OUT_PATH_2X}/scum-prison-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/scum-prison-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Shipyard Shop SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/swindlers-shops/shipyard \
			--data ${OUT_PATH_1X}/shipyard-atlas.xml \
			--sheet ${OUT_PATH_1X}/shipyard-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Shipyard Shop HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/swindlers-shops/shipyard \
			--data ${OUT_PATH_2X}/shipyard-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/shipyard-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Shipyard Venue SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/shipyardVenue \
			--data ${OUT_PATH_1X}/shipyard-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/shipyard-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Shipyard Venue HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/shipyardVenue \
			--data ${OUT_PATH_2X}/shipyard-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/shipyard-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Splash SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/splash \
			--data ${OUT_PATH_1X}/splash-atlas.xml \
			--sheet ${OUT_PATH_1X}/splash-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Splash HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/splash \
			--data ${OUT_PATH_2X}/splash-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/splash-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Swindlers Alley SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/swindlers-alley \
			--data ${OUT_PATH_1X}/swindlers-alley-atlas.xml \
			--sheet ${OUT_PATH_1X}/swindlers-alley-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Swindlers Alley HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/swindlers-alley \
			--data ${OUT_PATH_2X}/swindlers-alley-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/swindlers-alley-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Tavern SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/tavern \
			--data ${OUT_PATH_1X}/tavern-atlas.xml \
			--sheet ${OUT_PATH_1X}/tavern-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Tavern HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/tavern \
			--data ${OUT_PATH_2X}/tavern-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/tavern-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Tavern Venue SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/tavernVenue \
			--data ${OUT_PATH_1X}/tavern-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/tavern-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Tavern Venue HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/tavernVenue \
			--data ${OUT_PATH_2X}/tavern-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/tavern-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Title SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/title \
			--data ${OUT_PATH_1X}/title-atlas.xml \
			--sheet ${OUT_PATH_1X}/title-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Title HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/title \
			--data ${OUT_PATH_2X}/title-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/title-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Villains Den Venue SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/cove/villainsDenVenue \
			--data ${OUT_PATH_1X}/villains-den-venue-atlas.xml \
			--sheet ${OUT_PATH_1X}/villains-den-venue-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Villains Den Venue HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/cove/villainsDenVenue \
			--data ${OUT_PATH_2X}/villains-den-venue-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/villains-den-venue-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Voodoo Shop SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/swindlers-shops/voodoo-shop \
			--data ${OUT_PATH_1X}/voodoo-atlas.xml \
			--sheet ${OUT_PATH_1X}/voodoo-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Voodoo Shop HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/swindlers-shops/voodoo-shop \
			--data ${OUT_PATH_2X}/voodoo-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/voodoo-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Waves SD
	for i in {0..5}
	do
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/waves/waves$i.png \
			--data ${OUT_PATH_1X}/waves$i-atlas.xml \
			--sheet ${OUT_PATH_1X}/waves$i-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 0 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
	done
	
	# Waves HD
	for i in {0..5}
	do
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/waves/waves$i.png \
			--data ${OUT_PATH_2X}/waves$i-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/waves$i-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 0 \
			--disable-rotation \
			--trim \
			--opt RGBA8888 \
			--dither-fs-alpha \
			--replace .+\/=
	done
fi
exit 0

