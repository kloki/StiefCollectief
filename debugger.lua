debugger={
   debug=false,
   myfont = love.graphics.newFont(love._vera_ttf, 14),
   y=10,
   x=10,
   call1=" ",
   call2=" ",
   call3=" ",
   call4=" ",

}


function debugger:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function debugger:draw()

   if self.debug then
      love.graphics.setColor(255,0,0)
      love.graphics.setFont(self.myfont)
      --FPS
      love.graphics.print("FPS:".. love.timer.getFPS(),self.x,self.y)
      --delta time
      love.graphics.print("dt:" .. love.timer.getDelta(),self.x,self.y+15)
      --mouse location
      love.graphics.print("mouseX:".. love.mouse.getX()-theworld.drawx,self.x,self.y+30)
      love.graphics.print("mouseY:".. love.mouse.getY()-theworld.drawy,self.x,self.y+45)
      --callbacks
      love.graphics.print("CollisionCallbacks",self.x,self.y+60)
      love.graphics.print(" "..self.call1,self.x,self.y+75)
      love.graphics.print(" "..self.call2,self.x,self.y+90)
      love.graphics.print(" "..self.call3,self.x,self.y+105)
      love.graphics.print(" "..self.call4,self.x,self.y+120)
      love.graphics.setColor(255,255,255)
   end
end


function debugger:switch()
   if self.debug then
      self.debug=false
      world.debug=false
      world.player.debug=false
   else
      self.debug=true
      world.debug=true
      world.player.debug=true
     
   end
end


function debugger:on()
   self.debug=true
   world.debug=true
   world.player.debug=true
end

function debugger:pushCallback(callback)
   self.call4=self.call3
   self.call3=self.call2
   self.call2=self.call1
   self.call1=callback
end