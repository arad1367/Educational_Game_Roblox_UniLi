-- PlayerController.lua
-- Place in StarterPlayerScripts
-- Handles player interactions with question parts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Get remote events
local remotes = ReplicatedStorage:WaitForChild("DoorGoRemotes", 30)
local questionEvent = remotes:WaitForChild("QuestionEvent")
local roomChangeEvent = remotes:WaitForChild("RoomChangeEvent")

-- Wait for character to load
local character = player.Character or player.CharacterAdded:Wait()

-- Function to set up proximity prompts for question parts
local function setupQuestionParts()
	for i = 1, 3 do
		-- Try to find the question part
		local success, questionPart = pcall(function()
			return workspace:WaitForChild("QuestionPart" .. i, 10)
		end)

		if success and questionPart then
			print("Found QuestionPart" .. i)

			-- Always create a new prompt (remove existing if any)
			local existingPrompt = questionPart:FindFirstChild("ProximityPrompt")
			if existingPrompt then
				existingPrompt:Destroy()
			end

			local prompt = Instance.new("ProximityPrompt")
			prompt.ObjectText = "Question Station"
			prompt.ActionText = "Press E to get a question"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = 10
			prompt.Enabled = true
			prompt.Parent = questionPart

			print("Created ProximityPrompt for QuestionPart" .. i)

			-- Connect the trigger event
			prompt.Triggered:Connect(function()
				print("QuestionPart" .. i .. " triggered!")

				-- Tell the server which room's question was triggered
				questionEvent:FireServer(i)
			end)
		else
			print("QuestionPart" .. i .. " not found within 10 seconds")
		end
	end
end

-- Listen for room change events
roomChangeEvent.OnClientEvent:Connect(function(newRoomNumber)
	print("Room change event received: Player moved to Room " .. newRoomNumber)

	-- Reset all prompts when changing rooms
	setupQuestionParts()

	-- Add a highlight to make the question part easier to find
	local questionPart = workspace:FindFirstChild("QuestionPart" .. newRoomNumber)
	if questionPart then
		-- Create a highlight effect
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(0, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = questionPart

		-- Remove highlight after 5 seconds
		spawn(function()
			wait(5)
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end)
	end

	-- Show notification to player
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Room " .. newRoomNumber,
		Text = "Find the Question Station!",
		Duration = 5
	})
end)

-- Set up the question parts when the player joins
setupQuestionParts()

-- Also set up again when the player respawns
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	wait(1) -- Wait for the character to fully load
	setupQuestionParts()
end)