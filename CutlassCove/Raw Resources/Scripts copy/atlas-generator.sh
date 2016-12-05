#!/bin/bash

rm ../../Art/Graphics/@1x/Images/*.png
rm ../../Art/Graphics/@1x/Images/uiview/*.png
rm ../../Art/Graphics/@1x/Fonts/*.fnt
cp ../Graphics/@1x/Images/*.png ../../Art/Graphics/@1x/Images/
cp ../Graphics/@1x/Images/uiview/*.png ../../Art/Graphics/@1x/Images/uiview/
cp ../Graphics/@1x/Atlases/font/*.fnt ../../Art/Graphics/@1x/Fonts/
rm ../../Art/Graphics/@1x/Atlases/*.png
rm ../../Art/Graphics/@1x/Atlases/*.xml

./generate_atlas.rb --maxsize 256x128 ../Graphics/@1x/Atlases/font/CheekyMammoth.png ../../Art/Graphics/@1x/Atlases/font-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/playfield/*.png ../Graphics/@1x/Atlases/playfield/deck/cannons/*.png ../Graphics/@1x/Atlases/playfield/deck/extras/*.png ../Graphics/@1x/Atlases/playfield/deck/helms/*.png ../Graphics/@1x/Atlases/playfield/deck/railings/*.png ../Graphics/@1x/Atlases/playfield/deck/dutchman/*.png ../Graphics/@1x/Atlases/font/CheekyMammoth.png ../Graphics/@1x/Atlases/playfield/ships/*.png ../Graphics/@1x/Atlases/playfield/gadgets/*.png ../Graphics/@1x/Atlases/playfield/voodoo/*.png ../../Art/Graphics/@1x/Atlases/playfield-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/entrance/*.png ../../Art/Graphics/@1x/Atlases/cove2-entrance-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/common/*.png ../../Art/Graphics/@1x/Atlases/cove-common-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/tavernVenue/*.png ../../Art/Graphics/@1x/Atlases/tavern-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/merchantVenue/*.png ../../Art/Graphics/@1x/Atlases/merchant-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/shipyardVenue/*.png ../../Art/Graphics/@1x/Atlases/shipyard-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/scumPrisonVenue/*.png ../../Art/Graphics/@1x/Atlases/scum-prison-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/etherealsHauntVenue/*.png ../../Art/Graphics/@1x/Atlases/ethereals-haunt-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/villainsDenVenue/*.png ../../Art/Graphics/@1x/Atlases/villains-den-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/cove2/parlorVenue/*.png ../../Art/Graphics/@1x/Atlases/parlor-venue-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/tavern/*.png ../../Art/Graphics/@1x/Atlases/tavern-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/title/*.png ../Graphics/@1x/Atlases/title/buttons/*.png ../Graphics/@1x/Atlases/font/*.png ../../Art/Graphics/@1x/Atlases/title-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/handbook/*.png ../../Art/Graphics/@1x/Atlases/handbook-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/splash/*.png ../../Art/Graphics/@1x/Atlases/splash-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/swindlers-alley/*.png ../Graphics/@1x/Atlases/swindlers-alley/cannons/*.png ../Graphics/@1x/Atlases/swindlers-alley/gadgets/*.png ../Graphics/@1x/Atlases/swindlers-alley/ships/*.png ../Graphics/@1x/Atlases/swindlers-alley/voodoo/*.png ../../Art/Graphics/@1x/Atlases/swindlers-alley-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/swindlers-alley/cabin/*.png ../../Art/Graphics/@1x/Atlases/cabin-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/swindlers-alley/gadget-shop/*.png ../../Art/Graphics/@1x/Atlases/gadget-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/swindlers-alley/shipyard/*.png ../../Art/Graphics/@1x/Atlases/shipyard-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/swindlers-alley/voodoo-shop/*.png ../../Art/Graphics/@1x/Atlases/voodoo-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/achievements/*.png ../../Art/Graphics/@1x/Atlases/achievements-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/gameover/*.png ../../Art/Graphics/@1x/Atlases/gameover-atlas.xml
./generate_atlas.rb --maxsize 1024x1024 ../Graphics/@1x/Atlases/help/*.png ../../Art/Graphics/@1x/Atlases/help-atlas.xml
