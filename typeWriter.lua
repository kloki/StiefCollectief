require 'utils'
typeWriter={ 
   texts={},
   colors={},
   outputstring='',
   updatestep=0,
   indexstring=0,
   indexsection=1,
   indexchapter=1,
   typespeed=0.1,
   standardcolor={255,255,255},
   myfont=love.graphics.newFont('fonts/ChronoTrigger.ttf',40),
   width=600,
   x=5,
   y=5
}

function typeWriter:new (o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
    end

function typeWriter:print()
   love.graphics.setColor(self.colors[self.indexchapter][self.indexsection])
   love.graphics.setFont(self.myfont)
   love.graphics.printf(self.outputstring,self.x,self.y,self.width, 'left')
   love.graphics.setColor(255,255,255)
end

function typeWriter:update(dt)
   if self.indexstring < self.texts[self.indexchapter][self.indexsection]:len() then
      self.updatestep=self.updatestep+dt
      if self.updatestep >= self.typespeed then
	 self.updatestep=self.updatestep-self.typespeed
	 self.indexstring=self.indexstring+1
	 self.outputstring=typeWriter.texts[self.indexchapter][self.indexsection]:sub(1,self.indexstring)
	 TEsound.play('sounds/button-19.wav',"typing")
      end
   end
end

function typeWriter:push()
   if self.indexstring < self.texts[self.indexchapter][self.indexsection]:len() then
      self:finish()
   elseif self.indexsection  < table.getn(self.texts[self.indexchapter]) then
      self:pushSection()
   elseif self.indexchapter  < table.getn(self.texts) then
      self:pushChapter()
   end
end

function typeWriter:pushSection()
   self.indexstring= 0
   self.indexsection=self.indexsection+1
   self.outputstring=self.texts[self.indexchapter][self.indexsection]:sub(1,self.indexstring)
   TEsound.play('sounds/button-26.wav')
end

function typeWriter:pushChapter()
   self.indexstring= 0
   self.indexsection=1
   self.indexchapter=indexchapter+1
   self.outputstring=self.texts[self.indexchapter][self.indexsection]:sub(1,self.indexstring)
   TEsound.play('sounds/button-26.wav')
end

function typeWriter:setChapter(x)
   self.indexstring= 0
   self.indexsection=1
   self.indexchapter=x
   self.outputstring=self.texts[self.indexchapter][self.indexsection]:sub(1,self.indexstring)
   TEsound.play('sounds/button-26.wav')
end

function typeWriter:finish()
   self.indexstring= self.texts[self.indexchapter][self.indexsection]:len()
   self.outputstring=self.texts[self.indexchapter][self.indexsection]
   TEsound.play('sounds/button-26.wav')
end

function typeWriter:setFont(fontpath,size)
   self.myfont=love.graphics.newFont(fontpath,size)
end

function typeWriter:setXY(x,y)
   self.x=x
   self.y=y
end

function typeWriter:setWidth(w)
   self.width=w
end

function typeWriter:load(path)
   local text= love.filesystem.newFile(path):read()
   --some formatting
   text = text:strip("\n")

   --split to the profiles from the text
   local dual=text:split("<START>")
   --get the profiles
   local profiles=typeWriter.getProfiles(dual[1])
   
   --build data structures
  
   local chapters=dual[2]:split("<CHAPTER>")
   for i,chapter in ipairs(chapters) do
      if chapter~="" then
	 local sections=chapter:split("<")
	 local temptext={}
	 local tempcolors={}
	 for j,section in ipairs(sections) do
	    local section2 = section:split(">")
	    temptext[#temptext+1]=section2[2]
	    if section2[1]=='SECTION' then
	       tempcolors[#tempcolors+1]=self.standardcolor
	    else
	       tempcolors[#tempcolors+1]=profiles[section2[1]]
	    end
	 end
	 self.texts[#self.texts+1]=temptext
	 self.colors[#self.colors+1]=tempcolors
      end
   end
   --typeWriter.printTextTable(self.texts)
end

--inernal function
--returns a dictionaries of names and their corresponding features for now only a table for the rgb value
function typeWriter.getProfiles(str)
   profiles={}
   list = str:split("#")
   for i,v in ipairs(list) do

      if i ~= 1 then 
	 v2=v:split(" ")
	 profiles[v2[1]]={v2[2],v2[3],v2[4]}
	 end
   end
   return profiles      
end


function typeWriter.printTextTable(x)
   for i,v in ipairs(x) do
      print(i)
      for j,w in ipairs(v) do
	 print(w)
	 print('<SECTION>')
      end
   end
end