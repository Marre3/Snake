--[[
Copyright (c) 2016 Mauritz Sverredal

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
]]--

function love.load()
   utf8 = require("utf8")
   love.window.setTitle("Snake!")
   typing = false
   typingMode = nil
   snake = {
      colorR = 85 ,
      colorG = 255,
      colorB = 0
   }
   field = {
      width = 15,
      height = 15
   }
   if pcall(require, "ai") then
      ai = require("ai")
      aiLoaded = true
   else
      aiLoaded = false
   end
   useAI = false
   t = 0
   border = true
   love.graphics.setBackgroundColor(127, 127, 127)
   w = {}
   if love.graphics.getWidth() / field.width > love.graphics.getHeight() / field.height then
      squareSize = love.graphics.getHeight() / field.height
      love.window.setMode(squareSize * (field.width), love.graphics.getHeight(),{resizable=true, vsync=true, msaa=1})
   else
      squareSize = love.graphics.getWidth() / field.width
      love.window.setMode(love.graphics.getWidth(), squareSize * field.height,{resizable=true, vsync=true, msaa=1})
   end
   love.graphics.setNewFont(squareSize)
   newGame()
end
function newGame()
   t = 0
   gameOver = false
   pause = false
   snake.parts = {
      {x=1, y=1},
      {x=1, y=2},
      {x=1, y=3}
   }
   movement = {x=1, y=0}
   lastMovement = {x=0, y=-1}
   food = {}
   setFood()
end
function move()
   if food.x == mod(snake.parts[1].x + movement.x, field.width) and food.y == mod(snake.parts[1].y + movement.y, field.height) then
      table.insert(snake.parts, {x=snake.parts[#snake.parts].x, y=snake.parts[#snake.parts].y})
      setFood()
   end
   if #snake.parts > 1 then
      snake.parts[#snake.parts].x = snake.parts[#snake.parts-1].x
      snake.parts[#snake.parts].y = snake.parts[#snake.parts-1].y
   end
   if containsSnake(mod(snake.parts[1].x + movement.x, field.width), mod(snake.parts[1].y + movement.y, field.height)) then
      gameOver = true
   end   
   for i = 1, #snake.parts - 2 do
      snake.parts[#snake.parts-i].x = snake.parts[#snake.parts-i-1].x
      snake.parts[#snake.parts-i].y = snake.parts[#snake.parts-i-1].y
   end
   snake.parts[1].x = mod(snake.parts[1].x + movement.x, field.width)
   snake.parts[1].y = mod(snake.parts[1].y + movement.y, field.height)
   lastMovement.x = movement.x
   lastMovement.y = movement.y
end
function containsSnake(x, y)
   for _,s in pairs(snake.parts) do
      if x == s.x and y == s.y then
         return true
      end
   end
   return false
end
function setFood()
   while true do
      if #snake.parts > field.width * field.height - 1 then
         food.x = 0
         food.y = 0
         return
      end
      food.colorR = (love.math.random(2) - 1) * 255
      food.colorG = (love.math.random(2) - 1) * 255
      food.colorB = (love.math.random(2) - 1) * 255
      x = love.math.random(1, field.width)
      y = love.math.random(1, field.height)
      if not containsSnake(x, y) then
         food.x = x
         food.y = y
         if food.colorB == food.colorG and food.colorG == food.colorR then
            food.colorR = 255
            food.colorG = 128
            food.colorB = 0
         end
         return
      end
   end
end
function mod(a, b)
   if a % b == 0 then
      return b
   else
      return a % b
   end
end
function love.resize() 
   if love.graphics.getWidth() / field.width > love.graphics.getHeight() / field.height then
      squareSize = love.graphics.getHeight() / field.height
   else
      squareSize = love.graphics.getWidth() / field.width
   end
   love.graphics.setNewFont(squareSize)
end
function love.textinput(text)
   if typingMode == "setWidth" or typingMode == "setHeight" or typingMode == "setColorR" or typingMode == "setColorG" or typingMode == "setColorB" then
      if tonumber(text) ~= nil then
         textBuffer = textBuffer .. text
      end
   end
end
function love.update(dt)
   if gameOver == false and pause == false then
      if t > 0.33 or (t > 0.083 and love.keyboard.isDown("space")) or (love.keyboard.isDown("space") and love.keyboard.isDown("escape")) then
         move()
         if useAI then
            ai.update()
         end
         if love.keyboard.isDown("return") and love.keyboard.isDown("space") and love.keyboard.isDown("escape") then
            for i = 1, 100 do
               if gameOver == false then
                  move()
                  if useAI then
                     ai.update()
                  end
               end
            end
         end
         t = 0
      end
      t = t + dt
   elseif typing == false then
      love.timer.sleep(0.5)
   end
end
function squareWindow()
   w.x, w.y = love.window.getPosition()
   w.x = w.x + love.graphics.getWidth() / 2
   w.y = w.y + love.graphics.getHeight() / 2
   if love.graphics.getWidth() / field.width > love.graphics.getHeight() / field.height then
      squareSize = love.graphics.getHeight() / field.height
      love.window.setMode(squareSize * (field.width), love.graphics.getHeight(),{resizable=true, vsync=true, msaa=1, borderless=(not border)})
   else
      squareSize = love.graphics.getWidth() / field.width
      love.window.setMode(love.graphics.getWidth(), squareSize * field.height,{resizable=true, vsync=true, msaa=1, borderless=(not border)})
   end
   love.window.setPosition(w.x - love.graphics.getWidth() / 2, w.y - love.graphics.getHeight() / 2)
   love.graphics.setNewFont(squareSize)
end
function love.keypressed(key)
   if typing == false then
      if key == "s" then  
         squareWindow()
      elseif key == "w" then
         pause = true
         typingMode = "setWidth"
         typing = true
         textBuffer = ""
      elseif key == "h" then
         pause = true
         typingMode = "setHeight"
         typing = true
         textBuffer = ""
      elseif key == "c" then
         pause = true
         typingMode = "setColorR"
         typing = true
         textBuffer = ""
      elseif key == "a" and aiLoaded then
         useAI = not useAI
      elseif key == "f" then
         border = not border
         squareWindow()
         squareWindow()
      elseif key == "r" then
         newGame()
      elseif key == "+" then
         border = false
         squareWindow()
         love.window.maximize()
         squareWindow()
      end
      if gameOver == false then
         if key == "p" then
            pause = not pause
         end
         if pause == false then
            if movement.y == 0 then
               if key == "up" and not (lastMovement.y == 1) then
                  movement.x = 0
                  movement.y = -1
               elseif key == "down" and not (lastMovement.y == -1) then
                  movement.x = 0
                  movement.y = 1
               end
            end
            if movement.x == 0 then
               if key == "left" and not (lastMovement.x == 1) then
                  movement.x = -1
                  movement.y = 0
               elseif key == "right" and not (lastMovement.x == -1) then
                  movement.x = 1
                  movement.y = 0
               end
            end
         end
      end
   else
      if key == "escape" then
          typing = false
          typingMode = nil
      elseif key == "backspace" then
         offset = utf8.offset(textBuffer, -1)
         if offset then
            textBuffer = string.sub(textBuffer, 1, offset - 1)
         end
      elseif key == "return" then
         if #textBuffer > 0 then
            if typingMode == "setWidth" then
               field.width = tonumber(textBuffer)
               love.window.maximize()
               squareWindow()
               newGame()
               typing = false
            elseif typingMode == "setHeight" then
               field.height = tonumber(textBuffer)
               love.window.maximize()
               squareWindow()
               newGame()
               typing = false
            elseif typingMode == "setColorR" then
               snake.colorR = tonumber(textBuffer)
               typingMode = "setColorG"
            elseif typingMode == "setColorG" then
               snake.colorG = tonumber(textBuffer)
               typingMode = "setColorB"
            elseif typingMode == "setColorB" then
               snake.colorB = tonumber(textBuffer)
               typing = false
            end
         end
         textBuffer = ""
      end
   end
end
function drawSnake(part)
   s = snake.parts[part]
   love.graphics.setColor(snake.colorR, snake.colorG, snake.colorB)
   love.graphics.circle("fill", (s.x - 1) * squareSize + 0.5 * squareSize, (s.y - 1) * squareSize + 0.5 * squareSize, squareSize * 0.4, squareSize + 50)
   if #snake.parts > 1 then
      if part == 1 then
         if snake.parts[part + 1].x == mod(s.x - 1, field.width) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize, (s.y - 1) * squareSize + squareSize * 0.1, squareSize * 0.5, squareSize * 0.8)
         end
         if snake.parts[part + 1].x == mod(s.x + 1, field.width) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.5, (s.y - 1) * squareSize + squareSize * 0.1, squareSize * 0.5, squareSize * 0.8)
         end
         if snake.parts[part + 1].y == mod(s.y - 1, field.height) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.1, (s.y - 1) * squareSize, squareSize * 0.8, squareSize * 0.5)
         end
         if snake.parts[part + 1].y == mod(s.y + 1, field.height) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.1, (s.y - 1) * squareSize + squareSize * 0.5, squareSize * 0.8, squareSize * 0.5)
         end
      elseif part == #snake.parts then
         if snake.parts[part - 1].x == mod(s.x - 1, field.width) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize, (s.y - 1) * squareSize + squareSize * 0.1, squareSize * 0.5, squareSize * 0.8)
         end
         if snake.parts[part - 1].x == mod(s.x + 1, field.width) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.5, (s.y - 1) * squareSize + squareSize * 0.1, squareSize * 0.5, squareSize * 0.8)
         end
         if snake.parts[part - 1].y == mod(s.y - 1, field.height) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.1, (s.y - 1) * squareSize, squareSize * 0.8, squareSize * 0.5)
         end
         if snake.parts[part - 1].y == mod(s.y + 1, field.height) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.1, (s.y - 1) * squareSize + squareSize * 0.5, squareSize * 0.8, squareSize * 0.5)
         end
      else
         if snake.parts[part + 1].x == mod(s.x - 1, field.width) or snake.parts[part - 1].x == mod(s.x - 1, field.width) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize, (s.y - 1) * squareSize + squareSize * 0.1, squareSize * 0.5, squareSize * 0.8)
         end
         if snake.parts[part + 1].x == mod(s.x + 1, field.width) or snake.parts[part - 1].x == mod(s.x + 1, field.width) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.5, (s.y - 1) * squareSize + squareSize * 0.1, squareSize * 0.5, squareSize * 0.8)
         end
         if snake.parts[part + 1].y == mod(s.y - 1, field.height) or snake.parts[part - 1].y == mod(s.y - 1, field.height) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.1, (s.y - 1) * squareSize, squareSize * 0.8, squareSize * 0.5)
         end
         if snake.parts[part + 1].y == mod(s.y + 1, field.height) or snake.parts[part - 1].y == mod(s.y + 1, field.height) then
            love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.1, (s.y - 1) * squareSize + squareSize * 0.5, squareSize * 0.8, squareSize * 0.5)
         end
      end
   end
   if part == 1 then
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.25, (s.y - 1) * squareSize + squareSize * 0.2, math.floor(squareSize * 0.1), squareSize * 0.4)
      love.graphics.rectangle("fill", (s.x - 1) * squareSize + squareSize * 0.65, (s.y - 1) * squareSize + squareSize * 0.2, math.floor(squareSize * 0.1), squareSize * 0.4)
   end
end
function love.focus(focus)
   if not (pause or focus) then
      pause = true
   end
end
function love.draw()
   love.graphics.translate((love.graphics.getWidth() - squareSize * field.width) * 0.5, (love.graphics.getHeight() - squareSize * field.height) * 0.5)
   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 0, 0, field.width * squareSize, field.height * squareSize)
   if containsSnake(food.x, food.y) then
      setFood()
   else
      love.graphics.setColor(food.colorR, food.colorG, food.colorB)
      love.graphics.rectangle("fill", (food.x - 1) * squareSize, (food.y - 1) * squareSize, squareSize, squareSize)
   end
   i = #snake.parts
   while i > 0 do
      drawSnake(i)
      i = i - 1
   end
   love.graphics.setColor(255, 0, 170)
   love.graphics.print(#snake.parts, 0, 0)
   if typing == true then
      if typingMode == "setWidth" then
         love.graphics.print("Width: "..textBuffer, 0, squareSize)
      elseif typingMode == "setHeight" then
         love.graphics.print("Height: "..textBuffer, 0, squareSize)
      elseif typingMode == "setColorR" then
         love.graphics.print("Red: " .. textBuffer .. " (0-255)", 0, squareSize)
      elseif typingMode == "setColorG" then
         love.graphics.print("Green: " .. textBuffer .. " (0-255)", 0, squareSize)
      elseif typingMode == "setColorB" then
         love.graphics.print("Blue: " .. textBuffer .. " (0-255)", 0, squareSize)
      end
   end
end