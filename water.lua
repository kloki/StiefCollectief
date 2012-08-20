require 'TEsound'
water={
   length,
   width,
   type,
   destroy=false,
   destructable=true,
   hp=1,
   jumpable=false
}


function water:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function water:load(index,gameworld,x,y)
   self.body = love.physics.newBody(gameworld,x,y,"dynamic")
   self.shape = love.physics.newCircleShape(4)
   self.fixture = love.physics.newFixture(self.body,self.shape,1)
   self.fixture:setUserData(index)
   self.type="water"
   self.destroy=false
   self.destructable=true
end


function water:draw(drawx,drawy)
   love.graphics.setColor(0,0,255,60)
   love.graphics.circle("fill",self.body:getX()+drawx,self.body:getY()+drawy,7)
   love.graphics.setColor(255,255,255)
end

function water:takeDamage(power)
   self.hp=self.hp - power
   if self.hp <= 0 then
      self.destroy=true

   end

end
