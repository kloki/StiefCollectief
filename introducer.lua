introducer = {
   introtime=0,
   logo=love.graphics.newImage("images/Titlelogo.png"),
   introlength=6,
   music=true
} 

function introducer.draw()
   love.graphics.draw(introducer.logo,(widthscreen-introducer.logo:getWidth())/2,(heigthscreen-introducer.logo:getHeight())/2)


end

function introducer.update(dt)
   if introducer.music then TEsound.play('sounds/abcdefg.mp3',"intro") introducer.music=false end
   introducer.introtime=introducer.introtime+dt
   if introducer.introtime>introducer.introlength then introducer.stop() end
end

function introducer.stop()
   gamestate=2
   introducer.introtime=0
   TEsound.stop("intro")
end