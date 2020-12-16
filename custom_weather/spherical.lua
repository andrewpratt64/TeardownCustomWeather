-- Andrew Pratt 2020
-- Spherical Coordinate System as a class with public members

Spherical = {};
Spherical.__index = Spherical;

setmetatable(Spherical, {
	__call = function(cls, ...) return cls.new(...); end
});

-- Static constants
-- Pi multiplied by 2, 0.5, and 0.25 respectively. Put these here
--   so that they aren't re-calculated every tick
Spherical.PI_2		= math.pi * 2;
Spherical.PI_0_5	= math.pi * 0.5;
Spherical.PI_0_25	= math.pi * 0.25;

-- Constructor
function Spherical.new(r, incline, azimuth)
	local self = setmetatable({}, Spherical);
	-- Radial distance in meters
	self.r = r or 0;
	-- Inclination angle from the positive y axis in radians, should be between 0 and pi
	self.incline = incline or 0;
	-- Azimuthal angle in radians, should be between 0 and 2pi
	self.azimuth = azimuth or 0;
	
	return self;
end


-- Returns Spherical coordinates as a Vec in Cartesian coordinates
function Spherical:AsCartesianVec()
	return Vec(
		self.r * math.cos(self.azimuth) * math.sin(self.incline),
		self.r * math.cos(self.incline),
		self.r * math.sin(self.azimuth) * math.sin(self.incline)
	);
end

-- Note: I never actually ended up using this in main.lua, so it might not work great
--   since I haven't really tested it
-- Returns Spherical coordinates as a Transform in Cartesian coordinates
-- tRot is the rotation of the Transform as a Quat; optional
function Spherical:AsCartesianTransform(tRot)
	tRot = tRot or Quat();
	return Transform( self:AsCartesianVec(), tRot );
end