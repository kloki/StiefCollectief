require 'stief'
require 'box'
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
      if object.type~="solid" then object:draw(self.drawx,self.drawy) end--solids are already in the backgroundv 
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
	 if object.shape:getType()=="circle" then
	    love.graphics.circle("line", self.drawx + object.body:getX(), self.drawy + object.body:getY(), object.shape:getRadius())
	 else
	    local points={object.body:getWorldPoints(object.shape:getPoints())}
	    for index=1, #points,2 do
	       points[index]=points[index]+self.drawx	    
	       points[index+1]=points[index+1]+self.drawy
	    end
	    love.graphics.polygon("line", points)
	 end
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
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,-1,self.mapHeigth/2)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(2,self.mapHeigth)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="solid"
   --right
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,self.mapWidth+1,self.mapHeigth/2)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(2,self.mapHeigth)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="solid"
   --top
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,self.mapWidth/2,-1)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(self.mapWidth,2)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="solid"
   --bottom
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,self.mapWidth/2,self.mapHeigth+1)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(self.mapWidth,2)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="solid"


   --add objects from objects.txt
   local objectfile = love.filesystem.newFile("levels/".. level .. "/objects.txt")
   for object in objectfile:lines() do
      local v=object:split(" ")
      if v[1]=="R" then --object is rectangle
	 self.objects[#self.objects+1]={}
	 self.objects[#self.objects].body = love.physics.newBody(self.gameworld,v[2]+(v[4]-v[2])/2,v[3]+(v[5]-v[3])/2)
	 self.objects[#self.objects].shape = love.physics.newRectangleShape(v[4]-v[2],v[5]-v[3])
	 self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
	 self.objects[#self.objects].fixture:setUserData(#self.objects)
	 self.objects[#self.objects].type="solid"
      elseif v[1]=="P" then--objects is polygon
	 if #v <14 then --polygons can only have 8 vertices
	    --find center
	    local xmin=v[2]
	    local xmax=v[2]
	    local ymin=v[3]
	    local ymax=v[3]
	    for index=4, #v, 2 do
	       if v[index]<xmin then xmin=v[index]
	       elseif v[index]>xmax then xmax=v[index]
	       end
	       if v[index+1]<ymin then ymin=v[index+1]
	       elseif v[index+1]>ymax then ymax=v[index+1]
	       end
	    end
	    local centerx =xmin+(xmax-xmin)/2
	    local centery =ymin+(ymax-ymin)/2
	    table.remove(v,1)
	    for index=1,#v,2 do
	       v[index]=v[index]-centerx
	       v[index+1]=v[index+1]-centery
	    end
	    
	    self.objects[#self.objects+1]={}
	    self.objects[#self.objects].body = love.physics.newBody(self.gameworld,centerx,centery)
	    --this is stupid need to change this but just giving the table as parameter doesn't work
	    if #v==6 then
	       self.objects[#self.objects].shape = love.physics.newPolygonShape(v[1],v[2],v[3],v[4],v[5],v[6])
	    elseif #v==8 then
	       self.objects[#self.objects].shape = love.physics.newPolygonShape(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8])
	    elseif #v==10 then
	       self.objects[#self.objects].shape = love.physics.newPolygonShape(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10])
	    elseif #v==12 then
	       self.objects[#self.objects].shape = love.physics.newPolygonShape(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12])
	    end
	    self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
	    self.objects[#self.objects].fixture:setUserData(#self.objects)
	    self.objects[#self.objects].type="solid"
	 end
      elseif v[1]=="C" then--object is circle
	 self.objects[#self.objects+1]={}
	 self.objects[#self.objects].body = love.physics.newBody(self.gameworld,v[2],v[3])
	 self.objects[#self.objects].shape = love.physics.newCircleShape(v[4])
	 self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
	 self.objects[#self.objects].fixture:setUserData(#self.objects)
 	 self.objects[#self.objects].type="solid"
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
   
   if object2=="player" or object2=="playerfoot" then
      object1, object2= object2,object1
   end
   
   if object1=="playerfoot" then
     self.player:collisionSolid(self.objects[object2].type) 
     
  end
  
   if self.debug then
      if object1=="player"or object1=="playerfoot"then
	 db:pushCallback(object1 .. " collides with ".. self.objects[object2].type) 
      else
	 db:pushCallback(self.objects[object1].type .." collides with  ".. self.objects[object2].type) 
      end
   end
end

function world:endContact(a,b,coll)
   local object1=a:getUserData()
   local object2=b:getUserData()
   
   if object2=="player" or object1=="playerfoot" then
      object1, object2= object2,object1
   end
   
   if object1=="playerfoot" then
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
   end
end



--utility functions

function world:setState(s)
   self.gameworldstate=s
end