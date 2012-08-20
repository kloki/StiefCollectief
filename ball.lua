require 'TEsound'
ball={
   length,
   width,
   type,
   destroy=false,
   destructable=true,
   hp=4,
   jumpable=true
}


function ball:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function ball:load(index,gameworld,x,y)
   self.body = love.physics.newBody(gameworld,x,y,"dynamic")
   self.shape = love.physics.newCircleShape(30)
   self.fixture = love.physics.newFixture(self.body,self.shape,1)
   self.fixture:setUserData(index)
   self.fixture:setRestitution(0.9)
   self.type="ball"
   self.destroy=false
   self.destructable=true
end


function ball:draw(drawx,drawy)
   love.graphics.setColor(0,100,100)
   love.graphics.circle("fill",self.body:getX()+drawx,self.body:getY()+drawy,30)
   love.graphics.setColor(255,255,255)
end

function ball:takeDamage(power)
   self.hp=self.hp - power
   if self.hp <= 0 then
      self.destroy=true
      TEsound.play('sounds/break.wav',"box")
   end

end

function ball:bounce()
   TEsound.play('sounds/bounce.mp3',"ball",0.1)
end