require 'TEsound'
solid={
   length,
   width,
   image,
   type,
   destroy=false,
   destructable=false,
   jumpable=true
}


function solid:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

function solid:load(index,gameworld,x,y,form,shapeinfo)
   self.form=form
   if form=="rectangle" then
      self.body = love.physics.newBody(gameworld,x,y)
      self.shape = love.physics.newRectangleShape(shapeinfo[1],shapeinfo[2])
      self.fixture = love.physics.newFixture(self.body,self.shape)
      self.fixture:setUserData(index)
      self.type="solid"
      self.destroy=false
      self.destructable=false
   elseif form=="circle" then
      self.body = love.physics.newBody(gameworld,x,y)
      self.shape = love.physics.newCircleShape(shapeinfo[1])
      self.fixture = love.physics.newFixture(self.body,self.shape)
      self.fixture:setUserData(index)
      self.type="solid"
      self.destroy=false
      self.destructable=false
   elseif form=="polygon" then
      --find center
      local xmin=shapeinfo[2]
      local xmax=shapeinfo[2]
      local ymin=shapeinfo[3]
      local ymax=shapeinfo[3]
      for index=4, #shapeinfo, 2 do
	 if shapeinfo[index]<xmin then xmin=shapeinfo[index]
	 elseif shapeinfo[index]>xmax then xmax=shapeinfo[index]
	 end
	 if shapeinfo[index+1]<ymin then ymin=shapeinfo[index+1]
	 elseif shapeinfo[index+1]>ymax then ymax=shapeinfo[index+1]
	 end
      end
      local centerx =xmin+(xmax-xmin)/2
      local centery =ymin+(ymax-ymin)/2
      table.remove(shapeinfo,1)
      for index=1,#shapeinfo,2 do
	 shapeinfo[index]=shapeinfo[index]-centerx
	 shapeinfo[index+1]=shapeinfo[index+1]-centery
      end
      

      self.body = love.physics.newBody(gameworld,centerx,centery)
      --this is stupid need to change this but just giving the table as parameter doesn't work
      if #shapeinfo==6 then
	 self.shape = love.physics.newPolygonShape(shapeinfo[1],shapeinfo[2],shapeinfo[3],shapeinfo[4],shapeinfo[5],shapeinfo[6])
      elseif #shapeinfo==8 then
	 self.shape = love.physics.newPolygonShape(shapeinfo[1],shapeinfo[2],shapeinfo[3],shapeinfo[4],shapeinfo[5],shapeinfo[6],shapeinfo[7],shapeinfo[8])
      elseif #shapeinfo==10 then
	 self.shape = love.physics.newPolygonShape(shapeinfo[1],shapeinfo[2],shapeinfo[3],shapeinfo[4],shapeinfo[5],shapeinfo[6],shapeinfo[7],shapeinfo[8],shapeinfo[9],shapeinfo[10])
      elseif #shapeinfo==12 then
	 self.shape = love.physics.newPolygonShape(shapeinfo[1],shapeinfo[2],shapeinfo[3],shapeinfo[4],shapeinfo[5],shapeinfo[6],shapeinfo[7],shapeinfo[8],shapeinfo[9],shapeinfo[10],shapeinfo[11],shapeinfo[12])
      end
      self.fixture = love.physics.newFixture(self.body,self.shape)
      self.fixture:setUserData(index)
      self.type="solid"
      self.destroy=false
      self.destructable=false
   end

end


function solid:draw(drawx,drawy)
end
