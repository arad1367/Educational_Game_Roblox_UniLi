-- FixedDoorWatchAudio.lua
-- Place this as a LocalScript in StarterPlayerScripts
-- This script watches the doors to play room-specific audio

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Audio IDs for each room
local roomAudioIds = {
	[1] = 9045766377,   -- Room 1 Audio
	[2] = 1840020630,   -- Room 2 Audio
	[3] = 7702099063,   -- Room 3 Audio
	[4] = 1848140559    -- Win/Finish Room Audio
}

-- Track current room - start in Room 1
local currentRoom = 1

-- Create sound objects
local sounds = {}
for roomNum, audioId in pairs(roomAudioIds) do
	local sound = Instance.new("Sound")
	sound.Name = "Room" .. roomNum .. "Sound"
	sound.SoundId = "rbxassetid://" .. audioId
	sound.Volume = 0.5
	sound.Looped = true
	sound.Parent = script

	sounds[roomNum] = sound
	print("Created sound for Room " .. roomNum)
end

-- Function to play sound for a specific room
local function playRoomSound(roomNum)
	print("Attempting to play Room " .. roomNum .. " sound")

	-- Stop all other sounds
	for i, sound in pairs(sounds) do
		if sound.IsPlaying then
			sound:Stop()
			print("Stopped sound for Room " .. i)
		end
	end

	-- Play the sound for this room
	if sounds[roomNum] then
		sounds[roomNum]:Play()
		print("Now playing sound for Room " .. roomNum)
		currentRoom = roomNum
	end
end

-- Start with Room 1 audio
playRoomSound(1)

-- Get the DoorGoRemotes folder
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("DoorGoRemotes")
local roomChangeEvent = remotes:WaitForChild("RoomChangeEvent")
local gameWinEvent = remotes:WaitForChild("GameWinEvent")
local gameOverEvent = remotes:WaitForChild("GameOverEvent")

-- Listen for room change events
roomChangeEvent.OnClientEvent:Connect(function(newRoomNum)
	print("Room change event received: " .. newRoomNum)
	playRoomSound(newRoomNum)
end)

-- Listen for win events
gameWinEvent.OnClientEvent:Connect(function()
	print("Win event received")
	playRoomSound(4)
end)

-- Handle respawn and restart
player.CharacterAdded:Connect(function(character)
	print("Character added (player spawned/respawned)")

	-- Reset to Room 1 on character spawn/respawn
	currentRoom = 1
	playRoomSound(1)

	-- Setup door watches after a brief delay
	wait(1)

	-- Set up a door watch for each door
	for doorNum = 1, 3 do
		local door = workspace:FindFirstChild("Door" .. doorNum)
		if door then
			local doorMain = door:FindFirstChild("DoorMain") or door

			-- Store the initial state
			local initialPosition = doorMain.Position
			local initialOrientation = doorMain.Orientation
			local initialTransparency = doorMain.Transparency

			-- Function to check if door has been opened
			local function checkDoorOpened()
				-- Only check if player is in the room this door is in
				if currentRoom == doorNum then
					local nextRoom = doorNum + 1
					if nextRoom > 4 then nextRoom = 4 end

					print("Player went through Door" .. doorNum .. " to Room " .. nextRoom)
					playRoomSound(nextRoom)
				end
			end

			-- Watch for door movement/animation
			doorMain.Changed:Connect(function(property)
				if property == "Position" or property == "Orientation" or property == "Transparency" then
					-- Check if change is significant
					local positionChanged = (doorMain.Position - initialPosition).Magnitude > 0.5
					local orientationChanged = (doorMain.Orientation - initialOrientation).Magnitude > 5
					local transparencyChanged = doorMain.Transparency > initialTransparency + 0.2

					if positionChanged or orientationChanged or transparencyChanged then
						checkDoorOpened()

						-- Update initial values after a delay
						spawn(function()
							wait(3)
							initialPosition = doorMain.Position
							initialOrientation = doorMain.Orientation
							initialTransparency = doorMain.Transparency
						end)
					end
				end
			end)

			print("Now watching Door" .. doorNum)
		end
	end
end)

-- Setup for the case where character already exists
if player.Character then
	-- Reset to Room 1
	currentRoom = 1
	playRoomSound(1)
end

print("Fixed Door Watch Audio system initialized")