require 'stief'
require 'utils'
world={
   debug=false,
   objects={},
   gameworld,
   background,
   playerindex,
   player=stief:new(),
   drawx=0,
   drawy=0
     }


function world:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function world:update(dt)
   --update physics
   self.gameworld:update(dt)
   --update drawing coordinates
   self.drawx=-(self.objects[self.playerindex].body:getX()-widthscreen/2)
   self.drawy=-(self.objects[self.playerindex].body:getY()-heigthscreen/2)
   if self.drawx>0 then self.drawx=0 end
   if self.drawy>0 then self.drawy=0 end
   if self.drawx<-(self.background:getWidth()-widthscreen) then self.drawx=-(self.background:getWidth()-widthscreen) end
   if self.drawy<-(self.background:getHeight()-heigthscreen) then self.drawy=-(self.background:getHeight()-heigthscreen) end
   

   local commands={}
   commands=self.player:update(dt)
   self.objects[self.playerindex].body:applyForce(commands[1], commands[2])

end 

function world:draw()
   --draw background
   
   love.graphics.draw(self.background,self.drawx,self.drawy)
   love.graphics.circle("fill", self.drawx + self.objects[self.playerindex].body:getX(), self.drawy + self.objects[self.playerindex].body:getY(), self.objects[self.playerindex].shape:getRadius())
   --draw player
   
   self.player:draw(self.drawx + self.objects[self.playerindex].body:getX(),self.drawy + self.objects[self.playerindex].body:getY()) --function requires location of player

   --draw objects outline for debug
   if self.debug then
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
   end
end


function world:load(meter,level)
   love.physics.setMeter(meter)
   self.gameworld=love.physics.newWorld(0,9.81*meter,true)
   self.gameworld:setCallbacks( beginContact, endContact, preSolve, postSolve )
   self.background=love.graphics.newImage("levels/".. level .. "/background.png")
   self.objects={}


   --add player
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,300,300,"dynamic")
   self.objects[#self.objects].shape = love.physics.newCircleShape(20)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape,1)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="player"
   self.playerindex=#self.objects  --store index
   
   self.objects[#self.objects].fixture:setRestitution(0.9)
   --automatically add boundries around level
   --left
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,-1,self.background:getHeight()/2)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(2,self.background:getHeight())
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="wall"
   --right
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,self.background:getWidth()+1,self.background:getHeight()/2)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(2,self.background:getHeight())
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="wall"
   --top
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,self.background:getWidth()/2,-1)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(self.background:getWidth(),2)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="wall"
   --bottom
   self.objects[#self.objects+1]={}
   self.objects[#self.objects].body = love.physics.newBody(self.gameworld,self.background:getWidth()/2,self.background:getHeight()+1)
   self.objects[#self.objects].shape = love.physics.newRectangleShape(self.background:getWidth(),2)
   self.objects[#self.objects].fixture = love.physics.newFixture(self.objects[#self.objects].body,self.objects[#self.objects].shape)
   self.objects[#self.objects].fixture:setUserData(#self.objects)
   self.objects[#self.objects].type="wall"

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
      end
      
   end
   objectfile:close()



   
end


--collision callback functions

function world:beginContact(a,b,coll)
   local object1=a:getUserData()
   local object2=b:getUserData()
   
   if object1==self.platerindex then
      self.player:collision(self.objects[object2].type)
   elseif object2==self.playerindex then
      self.player:collision(self.objects[object1].type)
   end
  
   if self.debug then
      db:pushCallback(self.objects[object1].type .." collides with ".. self.objects[object2].type) 
   end
end


function beginContact(a, b, coll)--push the call back to world object
   world:beginContact(a,b,coll)

end

function endContact(a, b, coll)
    
end

function preSolve(a, b, coll)
    
end

function postSolve(a, b, coll)
    
end