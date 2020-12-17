Custom Weather Mod for Teardown by Andrew Pratt (andrewpratt64)
A module to add customizable snow to your map
 
License info in LICENSE.txt

Use the "custom_weather" folder to add this mod to your map
Use the "custom_weather_example_map" folder for an example of how to use this mod


IMPORTANT: This mod is for the experimental 0.5.0 build!
Support for pre-0.5.0 versions MIGHT happen, but not guaranteed

 
Feel free to use this in any of your maps, and change the files any way you like.
If you upload any maps/mods with this mod in them, please give credit on your mod page/readme/etc.
 
 
Options can be changed in custom_weather.lua
Hopefully these can be configured in your map xml file in the future


=HOW TO USE EXPERIMENTAL VERSION FOR TEARDOWN=
	1) Navigate to Teardown in your steam libraray
	2) Either click the gear icon and hit "Properties..." or right-click Teardown on the left side
		of the screen and hit properties from the drop-down list
	3) A properties window should now have opened. Click the "Betas" tab
	4) Click under where it says, "Select the beta you would like to opt into:"
	5) Select experimental in the drop-down menu
	6) Close the properties window and start Teardown
 
 
=LINKS=
	Github:			https://github.com/andrewpratt64/TeardownCustomWeather
	Teardownmods.com:	https://teardownmods.com/index.php?/file/836-custom-weather-mod/
	

=INSTALLATION INSTRUCTIONS=
For the mod:
	1) Copy the contents of the "custom_weather" folder to your map folder (snow_debug.png is optional, it's only there for debugging)
	2) To customize the mod, change the "SNOW_" variables in custom_weather.lua
	3) In your lua code, include custom_weather.lua
	4) Initialize the mod by calling ()
	5) Call CustomWeatherModTick() each frame (use tick() not update()!)
	
	Example file directory:
		\Documents\Teardown\mods\my_map
			map\my_map.vox
			info.txt
			main.lua
			main.xml
			snow.png
			snow_debug.png
			custom_weather.lua
			
	Example main.lua:
	
		=TOP OF FILE=
		
		#include "custom_weather.lua"
		
		function init()
			CustomWeatherModInit();
		end
		
		function tick()
			CustomWeatherModTick();
		end
		
		=BOTTOM OF FILE=
		
For the example map:
	1) Copy the "custom_weather_example_map" folder into your mods directory (\Documents\Teardown\mods\)
	2) From the main menu in-game, click Play->Mods, scroll to "custom_weather" under Local files, then click Play
