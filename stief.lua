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
   return commands
end

function stief:draw(x,y)
   love.graphics.circle("fill",x,y,20)
   --self.sprites[self.state]:draw(self.x,self.y)
end

function stief:loadSprites(spritepaths)

   for index,sprite in ipairs(spritepaths) do
      self.sprites[#self.sprites+1]=newAnimation(love.graphics.newImage(sprite),104,150,0.1,0)
   end
end


function stief:collision(object)
   if object=="solid" or object=="wall" then
      TEsound.play('sounds/bounce.mp3',"stief")
   end

end