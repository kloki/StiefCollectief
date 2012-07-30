debugger={
   debug=false,
   myfont = love.graphics.newFont(love._vera_ttf, 14),
   y=10,
   x=10,
   yplus=0,
   callbacks={"-","-","-","-","-","-","-","-"}
}


function debugger:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function debugger:draw()

   if self.debug then
      self.yplus=0
      love.graphics.setColor(255,0,0)
      love.graphics.setFont(self.myfont)
      --FPS
      love.graphics.print("FPS:".. love.timer.getFPS(),self.x,self.y+self.yplus)
      self.yplus=self.yplus+15
      --delta time
      love.graphics.print("dt:" .. love.timer.getDelta(),self.x,self.y+self.yplus)
      self.yplus=self.yplus+15
      --mouse location
      love.graphics.print("mouseX:".. love.mouse.getX()-theworld.drawx,self.x,self.y+self.yplus)
      self.yplus=self.yplus+15
      love.graphics.print("mouseY:".. love.mouse.getY()-theworld.drawy,self.x,self.y+self.yplus)
      self.yplus=self.yplus+15
      --callbacks
      love.graphics.print("CollisionCallbacks",self.x,self.y+self.yplus)
      self.yplus=self.yplus+15
      for i,callback in ipairs(self.callbacks) do
	 love.graphics.print(" ".. callback,self.x,self.y+self.yplus)
	 self.yplus=self.yplus+15
      end
      
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
   table.remove(self.callbacks,#self.callbacks)
   table.insert(self.callbacks,1,callback)
end