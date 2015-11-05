sounds = {}
mute = false

function playSound(name)
	sound = love.audio.newSource("res/" .. name ..".wav", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound effects
	if mute then sound:setVolume(0) end
	sound:play()

	table.insert(sounds, sound)
end

function playMusic(name)
	music = love.audio.newSource("res/" .. name ..".wav") -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
	if mute then music:setVolume(0) end
	music:play()

	table.insert(sounds, music)
end

function toggleMute()
	if mute then
		mute = false
		unmuteAll();
	else
		mute = true
		muteAll();
	end
end

function muteAll()
	for i = 1, #sounds do
		sound = sounds[i]
		sound:setVolume(0)
	end
end

function unmuteAll()
	for i = 1, #sounds do
		sound = sounds[i]
		sound:setVolume(1)
	end
end