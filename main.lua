require 'TEsound'
require 'typeWriter'
require 'animator'
require 'debugger'
require 'introducer'
require 'keyHandler'
require 'menu'
require 'pause'
require 'world'

function love.load()
   widthscreen=800
   heigthscreen=600
   theworld={}

   db=debugger:new()
   db:on()

   --load text
   -- 1= intro
   -- 2= game menu
   -- 3= main game
   -- 4= pause
   gamestate=1 

end

function love.draw()
   if gamestate==1 then
      introducer.draw()
   elseif gamestate==2 then
      menu.draw()
   elseif gamestate==3 then

      theworld:draw()
      db:draw()
   elseif gamestate==4 then
      theworld:draw()
      db:draw()
      pause.draw()
   end
end

function love.update(dt)
   if gamestate==1 then
      introducer.update(dt)
   elseif gamestate==3 then
      theworld:update(dt)
   end
   TEsound.cleanup()
end

function love.keypressed(key)

   if key=='escape' then
      keyHandler.escape()
   elseif key==' ' or key=="return"then
      keyHandler.space()
   elseif key=="up" then
      keyHandler.up()
   elseif key=="down" then
      keyHandler.down()
   elseif key=="d" then
      keyHandler.d()
   -- elseif key=="left" then
   --    keyHandler.left()
   -- elseif key=="right" then
   --    keyHandler.right()
   end


end

-- function love.keyreleased(key)
--    if key=="left" then
--       keyHandler.leftR()
--    elseif key=="right" then
--       keyHandler.rightR()
--    end
-- end



function love.quit()
  print("One step closer to world hegemony.")
end




