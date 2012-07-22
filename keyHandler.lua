keyHandler={}


function keyHandler.d()
   db:switch()
end


function keyHandler.space()
   if gamestate==1 then
      introducer.stop()
   elseif gamestate==2 then
      menu.space()
   -- elseif gamestate==3 then
   --    tw:push()
   --    world:jump()
   elseif gamestate==4 then
      pause.space()
   end

end

function keyHandler.up()
   if gamestate==2 then
      menu.up()
   elseif gamestate==4 then
      pause.up()
   end


end
-- function keyHandler.upreleased()
--    if gamestate==3 then
--       stief.upreleased()
--    end

-- end

function keyHandler.down()
   if gamestate==2 then
      menu.down()
   elseif gamestate==4 then
      pause.down()
   end

end

-- function keyHandler.left()
--    if gamestate==3 then
--       stief:left()
--    end
-- end

-- function keyHandler.leftR()
--    if gamestate==3 then
--       stief:leftR()
--    end
-- end
-- function keyHandler.right()
--    if gamestate==3 then
--       stief:right()
--    end
-- end
-- function keyHandler.rightR()
--    if gamestate==3 then
--       stief:rightR()
--    end
-- end


function keyHandler.escape()
   if gamestate==3 then
      gamestate=4
   end
end