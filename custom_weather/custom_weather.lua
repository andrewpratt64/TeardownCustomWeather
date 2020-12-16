-- Andrew Pratt 2020
-- Custom Weather

-- TODO: Optimize math, if possible
-- TODO: Make snow look better when looking straight up/down
-- TODO: Make farther layers less jittery when player is moving

#include "spherical.lua"


-- Draw a sprite facing cameraPos
local function DrawBillboardSprite(cameraPos, handle, pos, width, height, r, g, b, a, depthTest, additive)
	r = r or 1;
	g = g or 1;
	b = b or 1;
	a = a or 1;
	depthTest = depthTest or false;
	additive = additive or false;

	DrawSprite( handle, Transform( pos, QuatLookAt( pos, cameraPos ) ), width, height, r, g, b, a, depthTest, additive );
end
-- Draw a sprite facing cameraPos, but only on the x and z axis
local function DrawHorizBillboardSprite(cameraPos, handle, pos, width, height, r, g, b, a, depthTest, additive)
	r = r or 1;
	g = g or 1;
	b = b or 1;
	a = a or 1;
	depthTest = depthTest or false;
	additive = additive or false;

	local plyPos = GetPlayerTransform().pos;

	DrawSprite( handle, Transform( pos, QuatLookAt( Vec(pos[1], cameraPos[2], pos[3]), cameraPos ) ), width, height, r, g, b, a, depthTest, additive );
end


function CustomWeatherModInit()

	--	>===> SET OPTIONS HERE <===<

	-- 		Notes:
	-- Snow is drawn using sprites that face the player
	-- A spherecast (or raycast) is done from the top of the sprite to the bottom to check if it has room to draw or not.
	-- Sprites are drawn in columns, each column may be moving down at a different speed.
	-- Columns are drawn in layers, which are circles around the player. Each layer may rotate at a different speed.
	
	-- Seed for the rng
	-- Don't set crazy high/low or it could overflow
	SNOW_SEED = 8305809474;
	-- Image file to use for snow.
	-- "snow.png" is default
	-- "snow_debug.png" is a rectangle texture for debugging
	--SNOW_IMG = GetStringParam("snow_img", "snow.png");
	SNOW_IMG = "snow.png";
	-- Min/max speed each column of sprites will fall in m/s
	SNOW_FALL_SPEED_MIN = 0.4;
	SNOW_FALL_SPEED_MAX = 2.0;
	-- Maximum magnitude of rotation speed for each column of sprites
	SNOW_ROT_SPEED_MAX = 0.03;
	-- Alpha value of the farthest layer.
	-- Closest layer always has an alpha value of 1, and decreases linearly with each farther layer
	SNOW_ALPHA_MIN = 0.5;
	-- Radius of spherecast in meters, used for when sprites decide if they have enough room to draw.
	-- Setting to zero will cause raycasting to be used instead
	SNOW_SPHERECAST_SNOW_RADIUS = 0.25;
	-- Color of sprites in rgb
	SNOW_R = 1;
	SNOW_G = 1;
	SNOW_B = 1;
	-- Set to true for sprites to use additive color blending
	SNOW_ADDITIVE_COLOR = true;
	
	
	-- WARNING: Options below this line can cause serious lag, or cause the snow to just look terrible.
	
	-- Radial distance from the player of the first layer of sprites.
	SNOW_RADIUS = 1;
	-- How many times to place a billboard column in the first layer
	-- Each layer has SNOW_COLS more columns than the previous layer
	SNOW_COLS = 4;
	-- How many rows per column of sprites
	-- Higher values will look better, but run slower
	SNOW_TILE_ROWS = 20;
	-- How many sprite layers to draw
	-- Higher values can cause a huge performance hit
	-- Super low values can look weird
	SNOW_LAYERS = 8;
	
	--	>===> END OF OPTIONS <===<
	
	spriteSnow = LoadSprite(SNOW_IMG);
end
	
	
function CustomWeatherModTick()
	-- Use the same set of random numbers every time
	math.randomseed(SNOW_SEED);
	
	-- Get player position
	local plyPos = GetPlayerTransform().pos;
	-- Get the player's position rounded down to the nearest integer
	local plyFloor = Vec(
		math.floor(plyPos[1]),
		math.floor(plyPos[2]),
		math.floor(plyPos[3])
	);
	
	-- INCLINE is the inclination of each sprite in Spherical coordinates.
	-- It's set to a constant of pi/2, so all sprites stand upright
	local INCLINE = Spherical.PI_0_5;
	
	for layer=0, SNOW_LAYERS do
		-- r is the radial distance from the player to this layer
		local r = SNOW_RADIUS * (layer + 1);
		-- colSize is the azimuthal distance between each column of sprites
		local colSize = Spherical.PI_2 / (SNOW_COLS * (layer + 1));
		local vertexAngle = colSize;
		-- Dimensions of sprite in meters
		local spriteW = (r * math.sin(vertexAngle)) / math.sin(0.5 * (math.pi - vertexAngle));
		local spriteH = 2 * spriteW;
		-- Speed sprite rotates around the player
		local rotateSpeed = math.random() * SNOW_ROT_SPEED_MAX * 2 - SNOW_ROT_SPEED_MAX * 0.5;
		-- Azimuthal distance to offset all sprites in this layer
		local layerAzimuthOffset = math.random() * vertexAngle;
		
		for azimuth=0, Spherical.PI_2, colSize do
			
			-- Speed that this colimn descends in m/s
			local fallSpeed = math.random() * (SNOW_FALL_SPEED_MAX - SNOW_FALL_SPEED_MIN) + SNOW_FALL_SPEED_MIN;
			-- Height in meters of the lowest sprite in this column
			local baseYPos = spriteH * math.floor(plyPos[2] / spriteH) - (SNOW_TILE_ROWS * spriteH * 0.5) - ( (GetTime() * fallSpeed) % spriteH );
		
			for row=SNOW_TILE_ROWS, 0, -1 do
				-- Azimuthal distance to offset this sprite
				local azimuthOffset = layerAzimuthOffset + GetTime() * rotateSpeed;
				
				-- Position of this sprite in worldspace
				-- The player's position is rounded down to the nearest meter so that the snow isn't constantly
				--   moving with the player to give it a better feeling of depth
				local pos = VecAdd(
					Vec(
						plyFloor[1],
						baseYPos + row * spriteH,
						plyFloor[3]
					),
					Spherical(r, INCLINE, azimuth + azimuthOffset):AsCartesianVec()
				);
				
				-- Test if there is anything blocking this sprite
				local bSpotOccluded = QueryRaycast( VecAdd( pos, Vec(0, spriteH, 0) ), Vec(0, -1, 0), spriteH, SNOW_SPHERECAST_SNOW_RADIUS );
				if ( bSpotOccluded ) then
					break;
				end
				
				-- Get alpha of this sprite based on what layer it's in
				local alpha = 1 - ( (1 - SNOW_ALPHA_MIN) * layer ) / SNOW_LAYERS;
				-- Draw the sprite
				DrawHorizBillboardSprite(plyFloor, spriteSnow, pos, spriteW, spriteH, SNOW_R, SNOW_G, SNOW_B, alpha, true, SNOW_ADDITIVE_COLOR);

			end
		end
	end
	
end