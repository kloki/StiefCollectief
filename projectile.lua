projectile={
   Haxis=0,
   Vaxis=0,
   speed=600,
   power=1,
   destroy=false,
   destructable=false,
   type="projectile",
  
}


function projectile:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function projectile:load(index,gameworld,x,y,H,V)
   self.Haxis=H
   self.Vaxis=V
   self.body = love.physics.newBody(gameworld,x,y,"dynamic")
   self.shape = love.physics.newCircleShape(2)
   self.fixture = love.physics.newFixture(self.body,self.shape,1)
   self.fixture:setUserData(index)
   self.body:setBullet(true)
end


function projectile:draw(drawx,drawy)
   love.graphics.circle("fill",self.body:getX()+drawx,self.body:getY()+drawy,2)
end

function projectile:update(dt)
   self.body:applyForce(self.Haxis*self.speed,self.Vaxis*self.speed)
end

