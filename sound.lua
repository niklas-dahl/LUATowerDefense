sounds = {}
mute = false

function playSound(name)
	sound = love.audio.newSource("res/" .. name ..".wav", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound effects
	sound:play()

	table.insert(sounds, sound)
end

function playMusic(name)
	music = love.audio.newSource("res/" .. name ..".wav") -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
	music:setLooping(true)
	music:play()


	table.insert(sounds, music)
end

function toggleMute()
	if mute then
		mute = false
		unmuteAll()
	else
		mute = true
		muteAll()
	end
end

function muteAll()
	love.audio.setVolume(0)
end

function unmuteAll()
	love.audio.setVolume(1)
end