io.stdout:setvbuf("no")

g_dt = 0
g_direction = "none"
g_focus = false
g_hamester = nil -- hamster image
g_speed = 100
g_hamster_x = 100
g_hamster_y = 100
g_hamster_vx = 250
g_hamster_vy = 250
g_hamster_width = 0
g_hamster_height = 0

g_racket_old_x = 0
g_racket_old_y = 0
g_racket_vx = 0
g_racket_vy = 0
g_game_time = 2*60+34-3  -- song duration
g_racket_last_hit_time = 0

g_racket_hit = 0
g_racket_hit_x = 0
g_racket_hit_y = 0

g_tennis_hit = nil
g_tennis_hit_hard = nil
g_tennis_bounce = nil
g_max_score = 500
g_score = 0
g_ended = false
g_victory = false
g_final_score = 0

g_ft_x = 400
g_ft_y = 400
g_ft_life = 0.0 -- sec
g_ft_text = "5"

-------------------------------------------------------------------------------
function love.load()
	love.graphics.setBackgroundColor(0xFF, 0xCC, 0x00, 0xFF)
	g_dt = 1.0 / 60.0
	g_hamster = love.graphics.newImage("hamster.png")
	g_hamster_width = g_hamster:getWidth()
	g_hamster_height = g_hamster:getHeight()
	g_racket = love.graphics.newImage("racket_300.png")
	g_speed = 300
	love.mouse.setVisible(false)

	g_tennis_hit = love.audio.newSource("tennis_hit.mp3", "static")
	g_tennis_hit_hard = love.audio.newSource("tennis_serve.mp3", "static")
	g_tennis_bounce = love.audio.newSource("tennis_bounce.mp3", "static")
	g_tennis_bounce:setVolume(0.5)

	music = love.audio.newSource("Musopen_-_In_the_Hall_Of_The_Mountain_King.ogg", "stream")
	music:play()
	local font = love.graphics.newFont("ufonts.com_courier-new.ttf", 100)
	love.graphics.setFont(font)
	g_snd_defeat = love.audio.newSource("Frogs-Lisa_Redfern-1150052170.wav", "stream")
	g_snd_victory = love.audio.newSource("Ta Da-SoundBible.com-1884170640.wav", "stream")
end

-------------------------------------------------------------------------------
function love.update(dt)
	g_ft_life = g_ft_life - dt
	g_ft_y = g_ft_y - 70*dt
	g_game_time = g_game_time - dt
	if g_game_time < 0  and g_ended == false then
		g_ended = true
		love.audio.stop()
		g_snd_defeat:play()
		g_final_score = g_score
	end
	g_dt = g_dt * 0.99 + dt * 0.01
	g_hamster_x = g_hamster_x + g_hamster_vx * dt
	g_hamster_y = g_hamster_y + g_hamster_vy * dt
	if g_hamster_y + g_hamster_height/2 > love.graphics.getHeight() then
		g_hamster_vy = -g_hamster_vy
		g_hamster_y = love.graphics.getHeight() - g_hamster_height/2
		--g_tennis_bounce:play()
	end 
	if g_hamster_x + g_hamster_width/2 > love.graphics.getWidth() then
		g_hamster_vx = -g_hamster_vx
		g_hamster_x = love.graphics.getWidth() - g_hamster_width/2
		--g_tennis_bounce:play()
	end 	
	if g_hamster_y - g_hamster_height/2 < 0 then 
		g_hamster_vy = -g_hamster_vy
		g_hamster_y = g_hamster_height/2
		--g_tennis_bounce:play()
	end
	if g_hamster_x - g_hamster_width/2 < 0 then 
		g_hamster_vx = -g_hamster_vx
		g_hamster_x = g_hamster_width/2
		--g_tennis_bounce:play()
	end

	local x = love.mouse.getX()
	local y = love.mouse.getY()
	g_racket_vx = g_racket_vx * 0.75 + (x-g_racket_old_x)/dt * 0.25 
	g_racket_vy = g_racket_vy * 0.75 + (y-g_racket_old_y)/dt * 0.25 
	g_racket_old_x = x
	g_racket_old_y = y

	-- 55 adjusts y for racket picture not centered on hit area
	if racket_hit(x, y-55, g_hamster_x, g_hamster_y) then
	--if math.abs(g_racket_vx) > 120 or math.abs(g_racket_vy) > 120 then
		g_hamster_vx = g_racket_vx*0.75 - g_hamster_vx*0.25
		g_hamster_vx = absminmax(g_hamster_vx, 100, 1024)
		g_hamster_vy = g_racket_vy*0.75 - g_hamster_vy*0.25
		g_hamster_vy = absminmax(g_hamster_vy, 100, 1024)
		g_racket_hit = 10
		g_racket_hit_x = g_hamster_x
		g_racket_hit_y = g_hamster_y
		local speed = math.sqrt(g_racket_vx*g_racket_vx + g_racket_vy*g_racket_vy)
		speed = 1 + math.floor(math.pow(speed, 1.3)/10000)
		if  speed >= 5 then
			g_tennis_hit_hard:play()
		else
			g_tennis_hit:play()
		end
		g_score = g_score + speed
		g_ft_x = g_hamster_x
		g_ft_y = g_hamster_y
		g_ft_life = 1.0 -- sec
		g_ft_text = "" .. speed

		if g_score >= g_max_score and g_ended == false then
			g_ended = true
			g_victory = true
			love.audio.stop()
			g_snd_victory:play()
		end
	--end
	end
end

-------------------------------------------------------------------------------
function racket_hit(racket_x, racket_y, hamster_x, hamster_y)
	if math.abs(g_racket_last_hit_time - g_game_time) < 0.4 then
		return false
	end
	local dx = racket_x - hamster_x
	local dy = racket_y - hamster_y
	if dx*dx + dy*dy < 65*65 then
		g_racket_last_hit_time = g_game_time
		return true
	end
	return false
end 

-------------------------------------------------------------------------------
function love.keyreleased(key)
	if key == "up" or key == "down" then 
		g_direction = key
	end
	if key == "escape" then
		love.event.push("quit")
	end
end

-------------------------------------------------------------------------------
function love.draw()
	--love.graphics.print("FPS: " .. math.floor(1.0 / g_dt * 10) / 10, 400 ,300)
	--love.graphics.print("Direction: " .. g_direction, 400, 400)
	if g_ended then
		if g_victory then
			love.graphics.print("VICTORY", 400 ,50)
		else
			love.graphics.print("DEFEAT: " .. g_final_score, 400 ,50)
		end
	else
		love.graphics.print("" .. g_score .. "/" .. g_max_score .. "  (time: " .. math.floor(g_game_time) .. ")", 400 ,50)
	end
	local x = love.mouse.getX()
	local y = love.mouse.getY()
	--love.graphics.print("Mouse: x=" .. x .. ", y=" .. y, 400, 450)
	--love.graphics.print("Racket: vx=" .. math.floor(g_racket_vx) .. ", vy=" .. math.floor(g_racket_vy), 400, 500)
	local w = g_racket:getWidth()
	local h = g_racket:getHeight()
	love.graphics.draw(g_racket, x-(w/2), y-(h/2))
	love.graphics.draw(g_hamster, g_hamster_x-g_hamster_width/2, g_hamster_y-g_hamster_height/2)
	if g_racket_hit > 0 then
		g_racket_hit = g_racket_hit - 1
		love.graphics.circle("fill", g_racket_hit_x, g_racket_hit_y, 30, 10)
	end
	if g_ft_life > 0 then
		love.graphics.setColor(0xE0, 0x00, 0x00)
		love.graphics.print(g_ft_text, g_ft_x, g_ft_y)
		love.graphics.setColor(0xFF, 0xFF, 0xFF)
	end 
end

-------------------------------------------------------------------------------
function love.focus(f)
	g_focus = f
	if g_focus then
		love.graphics.setBackgroundColor(0xFF, 0xCC, 0x00, 0xFF)
	else
		love.graphics.setBackgroundColor(0xCC, 0xCC, 0xCC, 0xFF)
	end
end

-------------------------------------------------------------------------------
function love.quit()
	print("asta la vista baby")
end

-------------------------------------------------------------------------------
function absminmax(value, min_value_abs, max_value_abs)
	if value >= 0 then
		if value < min_value_abs then
			return min_value_abs
		elseif value > max_value_abs then
		    return max_value_abs
		end
	else
		if -value < min_value_abs then
			return -min_value_abs
		elseif -value > max_value_abs then
		    return -max_value_abs
		end
	end
	return value
end 
