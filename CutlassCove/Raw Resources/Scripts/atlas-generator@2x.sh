#!/bin/bash

rm ../../Art/Graphics/@2x/Images/*.png
rm ../../Art/Graphics/@2x/Images/uiview/*.png
rm ../../Art/Graphics/@2x/Fonts/*.fnt
cp ../Graphics/@2x/Images/*.png ../../Art/Graphics/@2x/Images/
cp ../Graphics/@2x/Images/uiview/*.png ../../Art/Graphics/@2x/Images/uiview/
cp ../Graphics/@2x/Atlases/font/*.fnt ../../Art/Graphics/@2x/Fonts/
rm ../../Art/Graphics/@2x/Atlases/*.png
rm ../../Art/Graphics/@2x/Atlases/*.xml
./generate_atlas.rb --maxsize 512x256 ../Graphics/@2x/Atlases/font/CheekyMammoth.png ../../Art/Graphics/@2x/Atlases/font-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/playfield/*.png ../Graphics/@2x/Atlases/font/CheekyMammoth.png ../Graphics/@2x/Atlases/playfield/deck/cannons/*.png ../Graphics/@2x/Atlases/playfield/deck/extras/*.png ../Graphics/@2x/Atlases/playfield/deck/helms/*.png ../Graphics/@2x/Atlases/playfield/deck/railings/*.png ../Graphics/@2x/Atlases/playfield/deck/dutchman/*.png ../Graphics/@2x/Atlases/playfield/ships/*.png ../Graphics/@2x/Atlases/playfield/gadgets/*.png ../Graphics/@2x/Atlases/playfield/voodoo/*.png ../../Art/Graphics/@2x/Atlases/playfield-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/entrance/*.png ../../Art/Graphics/@2x/Atlases/cove2-entrance-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/common/*.png ../../Art/Graphics/@2x/Atlases/cove-common-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/tavernVenue/*.png ../../Art/Graphics/@2x/Atlases/tavern-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/merchantVenue/*.png ../../Art/Graphics/@2x/Atlases/merchant-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/shipyardVenue/*.png ../../Art/Graphics/@2x/Atlases/shipyard-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/scumPrisonVenue/*.png ../../Art/Graphics/@2x/Atlases/scum-prison-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/etherealsHauntVenue/*.png ../../Art/Graphics/@2x/Atlases/ethereals-haunt-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/villainsDenVenue/*.png ../../Art/Graphics/@2x/Atlases/villains-den-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/cove2/parlorVenue/*.png ../../Art/Graphics/@2x/Atlases/parlor-venue-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/tavern/*.png ../../Art/Graphics/@2x/Atlases/tavern-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/title/*.png ../Graphics/@2x/Atlases/title/buttons/*.png ../../Art/Graphics/@2x/Atlases/title-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/handbook/*.png ../../Art/Graphics/@2x/Atlases/handbook-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/splash/*.png ../../Art/Graphics/@2x/Atlases/splash-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/swindlers-alley/*.png ../Graphics/@2x/Atlases/swindlers-alley/cannons/*.png ../Graphics/@2x/Atlases/swindlers-alley/gadgets/*.png ../Graphics/@2x/Atlases/swindlers-alley/ships/*.png ../Graphics/@2x/Atlases/swindlers-alley/voodoo/*.png ../../Art/Graphics/@2x/Atlases/swindlers-alley-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/swindlers-alley/cabin/*.png ../../Art/Graphics/@2x/Atlases/cabin-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/swindlers-alley/gadget-shop/*.png ../../Art/Graphics/@2x/Atlases/gadget-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/swindlers-alley/shipyard/*.png ../../Art/Graphics/@2x/Atlases/shipyard-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/swindlers-alley/voodoo-shop/*.png ../../Art/Graphics/@2x/Atlases/voodoo-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/achievements/*.png ../../Art/Graphics/@2x/Atlases/achievements-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/gameover/*.png ../../Art/Graphics/@2x/Atlases/gameover-atlas@2x.xml
./generate_atlas.rb --maxsize 2048x2048 ../Graphics/@2x/Atlases/help/*.png ../../Art/Graphics/@2x/Atlases/help-atlas@2x.xml
