local function badSpace(x, y)
   pos = {
      {x = 1, y = 0},
      {x = -1, y = 0},
      {x = 0, y = 1},
      {x = 0, y = -1}
   }
   for i = 1, 4 do
      p = {
         x = mod(pos[i].x + x, field.width),
         y = mod(pos[i].y + y, field.height)
      }
      if containsSnake(p.x, p.y) then
         p.snake = true
      end
   end
   return (pos[1].snake and pos[2].snake and pos[3].snake and pos[4].snake) or containsSnake(x, y)
end
local function update()
   local snake1 = snake.parts[1]
   if snake1.y == food.y then
      if mod(snake1.x - food.x, field.width) > 7.5 and lastMovement.x == 0 then
         movement.y = 0
         movement.x = 1
      elseif mod(snake1.x - food.x, field.width) < 7.5 and lastMovement.x == 0 then
         movement.y = 0
         movement.x = -1
      end
   elseif mod(snake1.y - food.y, field.height) < 7.5 then
      if snake1.x > food.x then
         if lastMovement.x == 1 or lastMovement.x == -1 then
            movement.y = -1
            movement.x = 0
         elseif lastMovement.y == 1 then
            movement.y = 0
            movement.x = -1
         end
      elseif snake1.x < food.x then
         if lastMovement.x == -1 or lastMovement.x == 1 then
            movement.y = -1
            movement.x = 0
         elseif lastMovement.y == 1 then
            movement.y = 0
            movement.x = 1
         end
      else
         if lastMovement.y == 0 then
            movement.y = -1
            movement.x = 0
         end
      end
   elseif mod(snake1.y - food.y, field.height) > 7.5 then
      if snake1.x < food.x then
         if lastMovement.x == -1 or lastMovement.x == 1 then
            movement.y = 1
            movement.x = 0
         elseif lastMovement.y == -1 then
            movement.y = 0
            movement.x = 1
         end
      elseif snake1.x > food.x then
         if lastMovement.x == 1 or lastMovement.x == -1 then
            movement.y = 1
            movement.x = 0
         elseif lastMovement.y == -1 then
            movement.y = 0
            movement.x = -1
         end
      else
         if lastMovement.y == 0 then
            movement.y = 1
            movement.x = 0
         end
      end
   end
   if badSpace(mod(snake1.x + movement.x, field.width), mod(snake1.y + movement.y, field.height)) then
      if lastMovement.x == 0 then
         if not badSpace(snake1.x, mod(snake1.y + lastMovement.y, field.height)) then
            movement.x = 0
            movement.y = lastMovement.y
         elseif mod(snake1.x - food.x, field.height) < 7.5 then
            if not badSpace(mod(snake1.x - 1, field.width), snake1.y) then
               movement.y = 0
               movement.x = -1
            elseif not badSpace(mod(snake1.x + 1, field.width), snake1.y) then
               movement.y = 0
               movement.x = 1
            end
         else
            if not badSpace(mod(snake1.x - 1, field.width), snake1.y) then
               movement.y = 0
               movement.x = -1
            elseif not badSpace(mod(snake1.x + 1, field.width), snake1.y) then
               movement.y = 0
               movement.x = 1
            end
         end
      else
         if not badSpace(mod(snake1.x + lastMovement.x, field.width), snake1.y) then
            movement.y = 0
            movement.x = lastMovement.x
         elseif not badSpace(snake1.x, mod(snake1.y - 1, field.height)) then
            movement.y = -1
            movement.x = 0
         elseif not badSpace(snake1.x, mod(snake1.y + 1, field.height)) then
            movement.y = 1
            movement.x = 0
         else
            movement.y = 0
            movement.x = lastMovement.x
         end
      end
   end
end
return({update = update})