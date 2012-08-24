require 'TEsound'
box={
   length,
   width,
   image,
   type,
   destroy=false,
   destructable=true,
   hp=4,
   jumpable=true
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
   self.destructable=true
end


function box:draw(drawx,drawy)
   love.graphics.draw(self.image,self.body:getX()+drawx,self.body:getY()+drawy,self.body:getAngle(),1,1,self.image:getWidth()/2,self.image:getHeight()/2)
end


function box:debug(drawx,drawy)

   local points={self.body:getWorldPoints(self.shape:getPoints())}
   for index=1, #points,2 do
      points[index]=points[index]+drawx	    
      points[index+1]=points[index+1]+drawy
   end
   love.graphics.polygon("line", points)
   love.graphics.print(self.hp,self.body:getX()+drawx,self.body:getY()+drawy)

end

function box:takeDamage(power)
   self.hp=self.hp - power
   if self.hp <= 0 then
      self.destroy=true
      TEsound.play('sounds/break.wav',"box")
   end

end

function box:bounce()
   TEsound.play('sounds/wood.wav',"box",0.1)
end