require 'stief'
require 'projectile'
require 'box'
require 'solid'
require 'water'
require 'ball'
require 'utils'
world={
   debug=false,
   objects={},
   dynaObjects={},
   gameworld,
   mapWidth,
   mapHeigth,
   backgrounds={},
   playerindex,
   player=stief:new(),
   drawx=0,
   drawy=0,
   TPtriggers={},
   gameworldstate=1,
   tw,
     }


function world:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function world:update(dt)
   if self.gameworldstate==1 then
      --remove destroyed objects
      for i=#self.objects, 1 ,-1 do--backwards because we are removing stuff
      	 if self.objects[i].destroy then
      	    self.objects[i].body:destroy()
      	    table.remove(self.objects,i)
      	 end 
      end
      --reset index values
      for i=1,#self.objects do
	 self.objects[i].fixture:setUserData(i)
      end 
      --update physics
      self.gameworld:update(dt)
      --update drawing coordinates
      self.drawx=-(self.player.body:getX()-widthscreen/2)
      self.drawy=-(self.player.body:getY()-heigthscreen/2)
      --limit so not outside game world
      if self.drawx>0 then self.drawx=0 end
      if self.drawy>0 then self.drawy=0 end
      if self.drawx<-(self.mapWidth-widthscreen) then self.drawx=-(self.mapWidth-widthscreen) end
      if self.drawy<-(self.mapHeigth-heigthscreen) then self.drawy=-(self.mapHeigth-heigthscreen) end
      --check for typewriterTriggers
      if self.player.body:getX()>=self.TPtriggers[1] then self:triggerTypeWriter() end
      
      --ask for player input from stief object
      self.player:update(dt)
    
      
      --update certain objects
      for i,object in ipairs(self.objects) do
	 if object.type=="projectile" then object:update(dt) end 
      end

      

   elseif self.gameworldstate==2 then
      self.tw:update(dt)
   end
end 

function world:draw()
   --draw background
   local totalwidth=0
   for index=1,#self.backgrounds do
      love.graphics.draw(self.backgrounds[index],self.drawx+totalwidth,self.drawy)
      totalwidth=totalwidth+self.backgrounds[index]:getWidth()
   end
   
   --draw objects
   for i,object in ipairs(self.objects) do
      object:draw(self.drawx,self.drawy) 
   end

   --draw player
   
   self.player:draw(self.drawx,self.drawy) --function requires location of player


   --draw text
   if self.gameworldstate==2 then
      self.tw:print()
   end
   --draw objects outline for debug
   if self.debug then
      --draw collision objects
      for index, object in ipairs(self.objects) do
	 object:debug(self.drawx,self.drawy)
      end

      --draw TPtriggers
      love.graphics.setColor(255,0,0)
      love.graphics.rectangle("fill",self.TPtriggers[1]+self.drawx,self.drawy,2,self.mapHeigth)
      love.graphics.setColor(255,255,255)
   end
end


function world:load(meter,level)
   love.physics.setMeter(meter)
   self.gameworld=love.physics.newWorld(0,9.81*meter,true)
   self.gameworld:setCallbacks( beginContact, endContact, preSolve, postSolve )
   self.objects={}
   self.TPtriggers={}


   local numberOfLevelTiles=0
   --load conf file
   local conffile = love.filesystem.newFile("levels/".. level .. "/conf.txt")
   for item in conffile:lines() do
      local v=item:split(" ")
      if v[1]=="TPtrigger" then
	 for index=2,#v do
	    self.TPtriggers[#self.TPtriggers+1]=tonumber(v[index])

	 end
	  --put this one at the end so this one never get empty
	 self.TPtriggers[#self.TPtriggers+1]=self.mapWidth+10
      elseif v[1]=="MAPXY" then
	 self.mapWidth=v[2]
	 self.mapHeigth=v[3]
     elseif v[1]=="MAPTILES" then
	 numberOfLevelTiles=v[2]
      end
   end
   conffile:close(self.mapWidth)
   --load game world
   for index=1,numberOfLevelTiles do
      self.backgrounds[index]=love.graphics.newImage("levels/".. level .. "/background".. index ..".png")
   end



   --add player
   self.player:load(self.gameworld)

   
   --load typewriter
   self.tw=typeWriter:new()
   self.tw:load("levels/".. level .. "/typeWriter.txt")
   --automatically add boundries around level
   --left
   self.objects[#self.objects+1]=solid:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,-1,self.mapHeigth/2,"rectangle",{2,self.mapHeigth})
   --right
   self.objects[#self.objects+1]=solid:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,self.mapWidth+1,self.mapHeigth/2,"rectangle",{2,self.mapHeigth})
   --up
   self.objects[#self.objects+1]=solid:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,self.mapWidth/2,-1,"rectangle",{self.mapWidth,2})
   --down
   self.objects[#self.objects+1]=solid:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,self.mapWidth/2,self.mapHeigth+1,"rectangle",{self.mapWidth,2})
      

   --add objects from objects.txt
   local objectfile = love.filesystem.newFile("levels/".. level .. "/objects.txt")
   for object in objectfile:lines() do
      local v=object:split(" ")
      if v[1]=="R" then --object is rectangle
	 self.objects[#self.objects+1]=solid:new()
	 self.objects[#self.objects]:load(#self.objects, self.gameworld,v[2]+(v[4]-v[2])/2,v[3]+(v[5]-v[3])/2,"rectangle",{v[4]-v[2],v[5]-v[3]})
      elseif v[1]=="P" then--objects is polygon
	 if #v>14 then print("polygon cannot have more then 8 vertices") else
	    self.objects[#self.objects+1]=solid:new()
	    self.objects[#self.objects]:load(#self.objects, self.gameworld,v[2],v[3],"polygon",v)
	 end
      elseif v[1]=="C" then--object is circle
	 self.objects[#self.objects+1]=solid:new()
	 self.objects[#self.objects]:load(#self.objects, self.gameworld,v[2],v[3],"circle",{v[4]})
      elseif v[1]=="DB" then --dynamic object using the box object
	 self.objects[#self.objects+1]=box:new()
	 self.objects[#self.objects]:load(#self.objects, self.gameworld,v[2],v[3],v[4])
      end
      
   end
   objectfile:close()

end


--collision callback functions

function world:beginContact(a,b,coll)
   local object1=a:getUserData()
   local object2=b:getUserData()
   
   --always put player objects first
   --if no players but projectiles in front

   if object2=="player" or object2=="playerfoot" or ((object1~="player" and object1~="playerfoot") and self.objects[object2].type=="projectile") then
      object1, object2= object2,object1
   end
   
   
   if object1=="playerfoot"  then
      if self.objects[object2].jumpable then self.player:collisionSolid(self.objects[object2].type) end 
   elseif object1~="player" then
      if self.objects[object1].type=="projectile" then
	 self.objects[object1].destroy=true
	 if self.objects[object2].destructable then
	    self.objects[object2]:takeDamage(self.objects[object1].power)
	 end
      elseif self.objects[object1].type=="box" or self.objects[object1].type=="ball" then
	 self.objects[object1]:bounce()
      elseif self.objects[object2].type=="box" or self.objects[object2].type=="ball" then
	 self.objects[object2]:bounce()
      end
   end
   if self.debug then
      if object1=="player"or object1=="playerfoot"then
	 db:pushCallback(object1 .. " collides with ".. self.objects[object2].type) 
      else
	 db:pushCallback(self.objects[object1].type .." collides with ".. self.objects[object2].type) 
      end
   end
end

function world:endContact(a,b,coll)
   local object1=a:getUserData()
   local object2=b:getUserData()
   
   if object2=="player" or object1=="playerfoot" then
      object1, object2= object2,object1
   end
   
   if object1=="playerfoot" and self.objects[object2].jumpable then
     self.player:leaveSolid()
  end
  
end


function beginContact(a, b, coll)--push the call back to world object everything will be handeled from there
   theworld:beginContact(a,b,coll)

end

function endContact(a, b, coll)
     theworld:endContact(a,b,coll) 
end

function preSolve(a, b, coll)
    
end

function postSolve(a, b, coll)
    
end

-- trigger function
function world:triggerTypeWriter(index)
   table.remove(self.TPtriggers,1)
   self.gameworldstate=2
end


--button functions

function world:space()
   
   if self.gameworldstate==2 then
      self.tw:push()
   elseif self.gameworldstate==1 then
      self.player:jump()
   end
end

function world:x()
   if self.gameworldstate==1 then
      self.player:spawnbox()
   end
end
function world:c()
   if self.gameworldstate==1 then
      self.player:shoot()
   end
end
function world:v()
   if self.gameworldstate==1 then
      self.player:spawnBall()
   end
end



--utility functions

function world:setState(s)
   self.gameworldstate=s
end

function world:addBox(x,y,image)
   self.objects[#self.objects+1]=box:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,x,y,"box.jpg")

end

function world:addProjectile(x,y,H,V)
   self.objects[#self.objects+1]=projectile:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,x,y,H,V)

end

function world:addBall(x,y,H,V)
   self.objects[#self.objects+1]=ball:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,x,y)
   self.objects[#self.objects].body:applyLinearImpulse( 400*H, 400*V)

end


function world:addWater(x,y,H,V)
   self.objects[#self.objects+1]=water:new()
   self.objects[#self.objects]:load(#self.objects, self.gameworld,x,y)
   self.objects[#self.objects].body:applyLinearImpulse( 2*H, 2*V)

end