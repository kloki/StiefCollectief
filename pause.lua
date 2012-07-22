pause={
   myFont=love.graphics.newFont('fonts/ChronoTrigger.ttf',40),
   buttonSound='sounds/button-26.wav',
   state=1,
   highlightColor={57,168,100},
   normalColor={255,255,255},
   x=00,
   y=200,
   spacing=40,
   items={"Continue","Main menu","Quit"}
}


function pause.draw()
   love.graphics.setColor(222,115,167)
   love.graphics.rectangle("fill",widthscreen/2-150,180,300,40+pause.spacing*#pause.items)
   love.graphics.setFont(pause.myFont)
   love.graphics.setColor(pause.normalColor)
   for index,item in ipairs(pause.items) do
      if pause.state==index then
	 love.graphics.setColor(pause.highlightColor)
	 love.graphics.printf(item, pause.x,pause.y+pause.spacing*(index-1),widthscreen,"center")
	 love.graphics.setColor(pause.normalColor)
      else
	 love.graphics.printf(item, pause.x,pause.y+pause.spacing*(index-1),widthscreen,"center")
      end
   end
   love.graphics.setColor({255,255,255})

end

function pause.space()
   TEsound.play(pause.buttonSound)
   if pause.state==1 then gamestate=3 
   elseif pause.state==2 then gamestate=2 
   elseif pause.state==3 then love.event.push("quit") 
   end

end

function pause.up()
   TEsound.play(pause.buttonSound)
   pause.state=pause.state-1
   if pause.state<1 then pause.state=1 end
end


function pause.down()
   TEsound.play(pause.buttonSound)
   pause.state=pause.state+1
   if pause.state>#pause.items then pause.state=#pause.items end
end