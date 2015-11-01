
function playSound(name)
	sound = love.audio.newSource("res/" .. name ..".wav", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound effects
	sound:play()
end

function playMusic(name)
	music = love.audio.newSource("res/" .. name ..".wav") -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
	music:play()
end