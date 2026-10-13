function EFFECT:Init(data)
	self.Entity 		= data:GetEntity()		// Entity determines what is creating the dynamic light			//

	self.Pos 		= data:GetOrigin()		// Origin determines the global position of the effect			//

	self.Scale 		= 2		// Scale determines how large the effect is				//
	self.Radius 		= data:GetRadius() or 1		// Radius determines what type of effect to create, default is Concrete	//

	self.DirVec 		= data:GetNormal()		// Normal determines the direction of impact for the effect		//
	self.PenVec 		= data:GetStart()		// PenVec determines the direction of the round for penetrations	//
	self.Particles 		= data:GetMagnitude()		// Particles determines how many puffs to make, primarily for "trails"	//
	self.Angle 		= self.DirVec:Angle()		// Angle is the angle of impact from Normal				//
	self.DebrizzlemyNizzle 	= 10+data:GetScale()		// Debrizzle my Nizzle is how many "trails" to make			//
	self.Size 		= 5*self.Scale			// Size is exclusively for the explosion "trails" size			//

	self.Emitter 		= ParticleEmitter( self.Pos )	// Emitter must be there so you don't get an error			//
	self.Mat=math.ceil(self.Radius)
	self:Particle()
end


function EFFECT:Particle()
    for i = 0, 30 * self.Scale do
        // Create the smoke particle
        local Smoke = self.Emitter:Add("particle/particle_composite", self.Pos)
        if (Smoke) then
			Smoke:SetVelocity(VectorRand() * math.Rand(400,800))

			Smoke:SetLifeTime(0)
			Smoke:SetDieTime(math.Rand(26, 30))

			local rand = math.random(0,8)
			Smoke:SetColor(rand,rand + 55,rand)

			Smoke:SetStartAlpha(math.Rand(242,255))
			Smoke:SetEndAlpha(0)

			local Size = math.Rand(96,128)
			Smoke:SetStartSize(Size)
			Smoke:SetEndSize(Size)

			Smoke:SetRoll(math.Rand(-360, 360))
			Smoke:SetRollDelta(math.Rand(-0.21, 0.21))

			Smoke:SetAirResistance(math.Rand(520,620))

			Smoke:SetGravity( Vector(0, 0, math.Rand(-20, -40)) )

			Smoke:SetCollide(true)
			Smoke:SetBounce(0.42)
        end
    end
end

function EFFECT:Think( )
return false
end


function EFFECT:Render()

end