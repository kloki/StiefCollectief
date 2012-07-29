require 'animator'
require 'TEsound'
stief={ 
   sprites={},
   state=1
}

function stief:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function stief:load(gameworld)
   
   self.body = love.physics.newBody(gameworld,300,300,"dynamic")
   self.shape = love.physics.newRectangleShape(32,64)
   self.fixture = love.physics.newFixture(self.body,self.shape,1)
   self.fixture:setUserData("player")
   self.body:setFixedRotation( true )
   
end

function stief:update(dt)
   local commands={0,0}
   if love.keyboard.isDown("right") then 
      commands[1]=commands[1]+400
   elseif love.keyboard.isDown("left") then 
      commands[1]=commands[1]-400
   elseif love.keyboard.isDown("up") then 
      commands[2]=commands[2]-400
   elseif love.keyboard.isDown("down") then 
      commands[2]=commands[2]+400
   end
   self.body:applyForce(commands[1], commands[2])
end

function stief:draw(drawx,drawy)
   local points={self.body:getWorldPoints(self.shape:getPoints())}
   for index=1, #points,2 do
      points[index]=points[index]+drawx	    
      points[index+1]=points[index+1]+drawy
   end
   
   love.graphics.polygon("fill", points)
   
end

function stief:loadSprites(spritepaths)

   for index,sprite in ipairs(spritepaths) do
      self.sprites[#self.sprites+1]=newAnimation(love.graphics.newImage(sprite),104,150,0.1,0)
   end
end


function stief:collisionSolid(object)
   
   TEsound.play('sounds/bounce.mp3',"stief")

end

