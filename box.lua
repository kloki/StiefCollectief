box={
   length,
   width,
   image,
   type,
}


function box:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function box:load(index,gameworld,x,y,imagepath)
   self.image=love.graphics.newImage("images/objects/".. imagepath)
   self.body = love.physics.newBody(gameworld,x,y,"dynamic")
   self.shape = love.physics.newRectangleShape(self.image:getWidth()-4,self.image:getHeight()-4)
   self.fixture = love.physics.newFixture(self.body,self.shape,1)
   self.fixture:setUserData(index)
   self.fixture:setRestitution(0.1)
   self.type=imagepath:sub(1,-5)
   self.destroy=false

end


function box:draw(drawx,drawy)
   love.graphics.draw(self.image,self.body:getX()+drawx,self.body:getY()+drawy,self.body:getAngle(),1,1,self.image:getWidth()/2,self.image:getHeight()/2)
end