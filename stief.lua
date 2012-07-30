require 'animator'
require 'TEsound'
stief={ 
   sprites={},
   state=2,
   x=300,
   y=300,
   debug=false
}

function stief:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function stief:load(gameworld)
   
   self.body = love.physics.newBody(gameworld,self.x,self.y,"dynamic")
   self.shape = love.physics.newRectangleShape(32,64)
   self.fixture = love.physics.newFixture(self.body,self.shape,1)
   self.fixture:setUserData("player")
   self.body:setFixedRotation( true )  
   self.fixture:setRestitution(0.1)
   

   --foot sensor
   self.footShape = love.physics.newRectangleShape( 0, 32, 28,2, 0 )
   self.footFixture = love.physics.newFixture(self.body,self.footShape,1)
   self.footFixture:setUserData("playerfoot")
   
end

function stief:update(dt)
   local commands={0,0}
   if love.keyboard.isDown("right","left") then
      if love.keyboard.isDown("right") then commands[1]=commands[1]+400 end --walk left
      if love.keyboard.isDown("left") then commands[1]=commands[1]-400 end --walk right
   else
      commands[1]= - self.body:getLinearVelocity()*2--automatically slow down is player is not walking needs work
   end
   self.body:applyForce(commands[1], commands[2])
   if self.state==1 then --the player is standing on the ground
      if love.keyboard.isDown(" ") then 
	 self.body:applyLinearImpulse(0,-300)
	 self.state=2   
	 TEsound.play('sounds/bounce.mp3',"stief")
 end
   end
end

function stief:draw(drawx,drawy)
   local points={self.body:getWorldPoints(self.shape:getPoints())}
   for index=1, #points,2 do
      points[index]=points[index]+drawx	    
      points[index+1]=points[index+1]+drawy
   end
   
   love.graphics.polygon("fill", points)
   if self.debug then
      --footsensor
      points={self.body:getWorldPoints(self.footShape:getPoints())}
      for index=1, #points,2 do
	 points[index]=points[index]+drawx	    
	 points[index+1]=points[index+1]+drawy
      end
      love.graphics.setColor(255,0,0)
      love.graphics.polygon("line",points)
      love.graphics.setColor(255,255,255)
   end
   
end

function stief:loadSprites(spritepaths)

   for index,sprite in ipairs(spritepaths) do
      self.sprites[#self.sprites+1]=newAnimation(love.graphics.newImage(sprite),104,150,0.1,0)
   end
end


function stief:collisionSolid()
   self.state=1

end

function stief:leaveSolid()
   self.state=2

end

