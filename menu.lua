require 'TEsound'
menu={
   myFont=love.graphics.newFont('fonts/ChronoTrigger.ttf',40),
   buttonSound='sounds/button-26.wav',
   state=1,
   highlightColor={57,168,100},
   normalColor={255,255,255},
   x=0,
   y=200,
   spacing=40,
   items={"Start","Quit"}
}


function menu.draw()
   love.graphics.setFont(menu.myFont)
   love.graphics.setColor(menu.normalColor)
   for index,item in ipairs(menu.items) do
      if menu.state==index then
	 love.graphics.setColor(menu.highlightColor)
	 love.graphics.printf(item, menu.x,menu.y+menu.spacing*index,widthscreen,"center")
	 love.graphics.setColor(menu.normalColor)
      else
	 love.graphics.printf(item, menu.x,menu.y+menu.spacing*index,widthscreen,"center")
      end
   end

   love.graphics.setColor({255,255,255})

end

function menu.space()
   TEsound.play(menu.buttonSound)
   if menu.state==1 then
      gamestate=3
      --load new world
      theworld=world:new()
      theworld:load(64,"01")
   end
   if menu.state==2 then love.event.push("quit") end

end

function menu.up()
   TEsound.play(menu.buttonSound)
   menu.state=menu.state-1
   if menu.state<1 then menu.state=1 end
end


function menu.down()
   TEsound.play(menu.buttonSound)
   menu.state=menu.state+1
   if menu.state>#menu.items then menu.state=#menu.items end
end