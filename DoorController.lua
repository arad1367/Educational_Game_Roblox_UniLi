-- DoorController.lua
-- Place in ServerScriptService
-- Controls door behavior and interactions

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Global doorTouchInProgress to prevent multiple touch events
local doorTouchInProgress = {}

-- Try multiple ways to get the GameManager module
local GameManager

-- Wait for GameManager to be available in _G
spawn(function()
	local count = 0
	while not _G.GameManager and count < 10 do
		wait(0.5)
		count = count + 1
	end

	if _G.GameManager then
		GameManager = _G.GameManager
		print("GameManager found via _G")
	else
		-- Create a minimal GameManager substitute for testing
		print("Creating substitute GameManager for testing")
		GameManager = {
			OnDoorTouched = function(player, doorNumber)
				print("Door", doorNumber, "touched by", player.Name)
				return true -- Always open doors in test mode
			end,
			GetPlayerCurrentRoom = function(player)
				return 1
			end
		}
	end

	-- Only setup doors after GameManager is available
	setupDoors()
end)

function setupDoors()
	-- Find all doors in the workspace
	local doors = {}
	for i = 1, 3 do
		local success, door = pcall(function()
			return workspace:WaitForChild("Door" .. i, 10) -- Wait up to 10 seconds
		end)

		if success and door then
			doors[i] = door
			print("Found Door" .. i)
		else
			print("Door" .. i .. " not found. Make sure it exists in the workspace!")
		end
	end

	-- Set up door touch detection
	for doorNumber, door in pairs(doors) do
		-- Get the main part of the door
		local doorMain = door:WaitForChild("DoorMain", 5)
		if not doorMain then
			print("WARNING: Door" .. doorNumber .. " does not have a DoorMain part!")
			-- Try to use the door model itself if DoorMain doesn't exist
			doorMain = door
			print("Using door model as touchable part for Door" .. doorNumber)
		end

		-- Initialize door touch debounce for this door
		doorTouchInProgress[doorNumber] = false

		print("Setting up touch detection for Door" .. doorNumber)

		-- Create a touched event for the door
		doorMain.Touched:Connect(function(hit)
			-- Check if a player touched the door
			local humanoid = hit.Parent:FindFirstChild("Humanoid")
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or not humanoid then return end

			-- Get the player's user ID
			local userId = player.UserId

			-- Prevent multiple touches at once
			if doorTouchInProgress[doorNumber] then
				return
			end

			-- Set the debounce to prevent multiple touches
			doorTouchInProgress[doorNumber] = true

			print("Door" .. doorNumber .. " touched by player: " .. player.Name .. " at " .. os.time())
			print("Player current room according to GameManager: " .. GameManager.GetPlayerCurrentRoom(player))

			-- Check with the GameManager if the door should open
			local shouldOpen = false
			local success = pcall(function()
				shouldOpen = GameManager.OnDoorTouched(player, doorNumber)
				print("GameManager.OnDoorTouched returned: " .. tostring(shouldOpen))
			end)

			if not success then
				print("Error calling GameManager.OnDoorTouched")
				-- Reset debounce after error
				doorTouchInProgress[doorNumber] = false
				return
			end

			if shouldOpen then
				print("Opening Door" .. doorNumber .. " for player " .. player.Name)
				openDoor(doorNumber, door)

				-- After player goes through, close and lock the door behind them
				spawn(function()
					wait(2)
					closeDoor(doorNumber, door)
					-- Reset the debounce after door closes
					wait(1)
					doorTouchInProgress[doorNumber] = false
				end)
			else
				print("Not opening Door" .. doorNumber .. " for player " .. player.Name)
				-- Reset the debounce after a short delay
				spawn(function()
					wait(1)
					doorTouchInProgress[doorNumber] = false
				end)
			end
		end)

		print("Touch detection setup complete for Door" .. doorNumber)
	end
end

-- Function to open a door
function openDoor(doorNumber, door)
	if not door then 
		print("Door not found for opening: " .. doorNumber)
		return 
	end

	-- Get door's hinge and set animation
	local doorHinge = door:FindFirstChild("Hinge")
	if doorHinge then
		-- Animate the door opening
		local openAngle = 90
		for i = 0, openAngle, 5 do
			doorHinge.Orientation = Vector3.new(0, i, 0)
			wait(0.01)
		end
	else
		-- If no hinge, just make the door transparent and can collide false
		for _, part in pairs(door:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Transparency = 0.5
			end
		end
	end
end

-- Function to close a door
function closeDoor(doorNumber, door)
	if not door then 
		print("Door not found for closing: " .. doorNumber)
		return 
	end

	-- Get door's hinge and set animation
	local doorHinge = door:FindFirstChild("Hinge")
	if doorHinge then
		-- Animate the door closing
		local openAngle = 90
		for i = openAngle, 0, -5 do
			doorHinge.Orientation = Vector3.new(0, i, 0)
			wait(0.01)
		end
	else
		-- If no hinge, just make the door solid and visible again
		for _, part in pairs(door:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
				part.Transparency = 0
			end
		end
	end
end