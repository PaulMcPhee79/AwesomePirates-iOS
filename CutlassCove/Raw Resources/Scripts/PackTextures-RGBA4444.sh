#!/bin/bash

# If you get a "bad interpreter: Operation not permitted" error, do the following:
# At terminal: xattr -d com.apple.quarantine ./PackTextures-RGBA4444.sh

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
	rm -f ${OUT_PATH_1X}/*.jpg

	# rm -f ${OUT_PATH_1X}/railings/*.xml
	# rm -f ${OUT_PATH_1X}/railings/*.pvr.gz
	# rm -f ${OUT_PATH_1X}/railings/*.png
	# rm -f ${OUT_PATH_1X}/railings/*.jpg
	
	rm -f ${RES_PATH_IMAGES_1X}/*.png
	rm -f ${RES_PATH_IMAGES_1X}/*.jpg
	rm -f ${RES_PATH_IMAGES_1X}/*.pvr
	rm -f ${RES_PATH_IMAGES_1X}/uiview/*.png
	rm -f ${RES_PATH_IMAGES_1X}/uiview/*.jpg
    	rm -f ${RES_PATH_IMAGES_1X}/openfeint/*.png
	rm -f ${RES_PATH_IMAGES_1X}/openfeint/*.jpg
	rm -f ${RES_PATH_FONTS_1X}/*.fnt
	
	# 2x
	rm -f ${OUT_PATH_2X}/*.xml
	rm -f ${OUT_PATH_2X}/*.pvr.gz
	rm -f ${OUT_PATH_2X}/*.png
	rm -f ${OUT_PATH_2X}/*.jpg

	# rm -f ${OUT_PATH_2X}/railings/*.xml
	# rm -f ${OUT_PATH_2X}/railings/*.pvr.gz
	# rm -f ${OUT_PATH_2X}/railings/*.png
	# rm -f ${OUT_PATH_2X}/railings/*.jpg
	
	rm -f ${RES_PATH_IMAGES_2X}/*.png
	rm -f ${RES_PATH_IMAGES_2X}/*.jpg
	rm -f ${RES_PATH_IMAGES_2X}/*.pvr
	rm -f ${RES_PATH_IMAGES_2X}/uiview/*.png
	rm -f ${RES_PATH_IMAGES_2X}/uiview/*.jpg
    	rm -f ${RES_PATH_IMAGES_2X}/openfeint/*.png
	rm -f ${RES_PATH_IMAGES_2X}/openfeint/*.jpg
	rm -f ${RES_PATH_FONTS_2X}/*.fnt
	
	# hd Images
	rm -f ${RES_PATH_IMAGES_HD}/*.png
	rm -f ${RES_PATH_IMAGES_HD}/*.jpg
else
	echo "building..."
	
	# 1x Images and Fonts
	cp ../Graphics/@2x/Images/*.png ${RES_PATH_IMAGES_1X}
	cp ../Graphics/@2x/Images/*.jpg ${RES_PATH_IMAGES_1X}
	cp ../Graphics/@2x/Images/*.pvr ${RES_PATH_IMAGES_1X}
	cp ../Graphics/@2x/Images/uiview/*.png ${RES_PATH_IMAGES_1X}/uiview/
    	cp ../Graphics/@2x/Images/openfeint/*.png ${RES_PATH_IMAGES_1X}/openfeint/
	cp ../Graphics/@1x/Atlases/font/*.fnt ${RES_PATH_FONTS_1X}

	mogrify -scale 50% ${RES_PATH_IMAGES_1X}/*.png
	mogrify -scale 50% ${RES_PATH_IMAGES_1X}/*.jpg
	mogrify -scale 50% ${RES_PATH_IMAGES_1X}/uiview/*.png
    	mogrify -scale 50% ${RES_PATH_IMAGES_1X}/openfeint/*.png


	for i in ${RES_PATH_IMAGES_1X}/*@2x.png
	do
		NEW_PATH=${i/%@2x.png/.png}
		mv $i $NEW_PATH
	done

	for i in ${RES_PATH_IMAGES_1X}/*@2x.jpg
	do
		NEW_PATH=${i/%@2x.jpg/.jpg}
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

	for i in ${RES_PATH_IMAGES_1X}/uiview/*@2x.jpg
	do
		NEW_PATH=${i/%@2x.jpg/.jpg}
		mv $i $NEW_PATH
	done
    
    for i in ${RES_PATH_IMAGES_1X}/openfeint/*@2x.png
	do
		NEW_PATH=${i/%@2x.png/.png}
		mv $i $NEW_PATH
	done

	for i in ${RES_PATH_IMAGES_1X}/openfeint/*@2x.jpg
	do
		NEW_PATH=${i/%@2x.jpg/.jpg}
		mv $i $NEW_PATH
	done
	
	# 2x Images and Fonts
	cp ../Graphics/@2x/Images/*.png ${RES_PATH_IMAGES_2X}
	cp ../Graphics/@2x/Images/*.jpg ${RES_PATH_IMAGES_2X}
	cp ../Graphics/@2x/Images/*.pvr ${RES_PATH_IMAGES_2X}
	cp ../Graphics/@2x/Images/uiview/*.png ${RES_PATH_IMAGES_2X}/uiview/
	cp ../Graphics/@2x/Images/uiview/*.jpg ${RES_PATH_IMAGES_2X}/uiview/
    	cp ../Graphics/@2x/Images/openfeint/*.png ${RES_PATH_IMAGES_2X}/openfeint/
	cp ../Graphics/@2x/Images/openfeint/*.jpg ${RES_PATH_IMAGES_2X}/openfeint/
	cp ../Graphics/@2x/Atlases/font/*.fnt ${RES_PATH_FONTS_2X}

	# hd Images
	cp ../Graphics/@hd/Images/*.png  ${RES_PATH_IMAGES_HD}
	cp ../Graphics/@hd/Images/*.jpg  ${RES_PATH_IMAGES_HD}
	
	
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Lite SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/lite \
			--data ${OUT_PATH_1X}/lite-atlas.xml \
			--sheet ${OUT_PATH_1X}/lite-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Lite HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/lite \
			--data ${OUT_PATH_2X}/lite-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/lite-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Objectives SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/objectives \
			--data ${OUT_PATH_1X}/objectives-atlas.xml \
			--sheet ${OUT_PATH_1X}/objectives-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Objectives HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/objectives \
			--data ${OUT_PATH_2X}/objectives-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/objectives-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA4444 \
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
			--opt RGBA4444 \
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
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
#	# Railings SD
#	for i in ${GFX_PATH_1X}/railings/*.png
#	do
#		RAILING=$(basename $i .png)
#	
#		${TP}	--smart-update \
#			--format sparrow \
#			${GFX_PATH_1X}/railings/$RAILING.png \
#			--data ${OUT_PATH_1X}/railings/$RAILING-atlas.xml \
#			--sheet ${OUT_PATH_1X}/railings/$RAILING-atlas.pvr.gz \
#			--algorithm MaxRects \
#			--maxrects-heuristics best \
#			--scale 0.5 \
#			--border-padding 0 \
#			--shape-padding 0 \
#			--disable-rotation \
#			--opt RGBA4444 \
#			--dither-fs-alpha \
#			--replace .+\/=
#	done

#	# Railings HD
#	for i in ${GFX_PATH_2X}/railings/*.png
#	do
#		RAILING=$(basename $i .png)
#
#		${TP}	--smart-update \
#			--format sparrow \
#			${GFX_PATH_2X}/railings/$RAILING.png \
#			--data ${OUT_PATH_2X}/railings/$RAILING-atlas@2x.xml \
#			--sheet ${OUT_PATH_2X}/railings/$RAILING-atlas@2x.pvr.gz \
#			--algorithm MaxRects \
#			--maxrects-heuristics best \
#			--border-padding 0 \
#			--shape-padding 0 \
#			--disable-rotation \
#			--opt RGBA4444 \
#			--dither-fs-alpha \
#			--replace .+\/=
#	done

	# ---------------------------------------------------------------------------------

	# Rate SD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_1X}/rate \
			--data ${OUT_PATH_1X}/rate-atlas.xml \
			--sheet ${OUT_PATH_1X}/rate-atlas.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--scale 0.5 \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=
			
	# Rate HD
	${TP}	--smart-update \
			--format sparrow \
			${GFX_PATH_2X}/rate \
			--data ${OUT_PATH_2X}/rate-atlas@2x.xml \
			--sheet ${OUT_PATH_2X}/rate-atlas@2x.pvr.gz \
			--algorithm MaxRects \
			--maxrects-heuristics best \
			--shape-padding 1 \
			--disable-rotation \
			--trim \
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=

	# ---------------------------------------------------------------------------------
	
	# Waves SD
	for i in {0..0}
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
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=
	done
	
	# Waves HD
	for i in {0..0}
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
			--opt RGBA4444 \
			--dither-fs-alpha \
			--replace .+\/=
	done
fi
exit 0

