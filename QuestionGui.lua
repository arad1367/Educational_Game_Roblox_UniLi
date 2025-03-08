-- QuestionGui.lua
-- Place in StarterGui folder
-- Creates and manages the question UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Get remote events
local remotes = ReplicatedStorage:WaitForChild("DoorGoRemotes", 30)
local questionEvent = remotes:WaitForChild("QuestionEvent")
local answerEvent = remotes:WaitForChild("AnswerEvent")
local timerEvent = remotes:WaitForChild("TimerEvent")
local gameOverEvent = remotes:WaitForChild("GameOverEvent")
local gameWinEvent = remotes:WaitForChild("GameWinEvent")

-- Create UI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DoorGoGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Question frame
local questionFrame = Instance.new("Frame")
questionFrame.Name = "QuestionFrame"
questionFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
questionFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
questionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
questionFrame.BackgroundTransparency = 0.2
questionFrame.Visible = false
questionFrame.Parent = screenGui

-- Question text
local questionText = Instance.new("TextLabel")
questionText.Name = "QuestionText"
questionText.Size = UDim2.new(1, 0, 0.3, 0)
questionText.Position = UDim2.new(0, 0, 0, 0)
questionText.BackgroundTransparency = 1
questionText.TextColor3 = Color3.fromRGB(255, 255, 255)
questionText.TextSize = 24
questionText.TextWrapped = true
questionText.Font = Enum.Font.GothamBold
questionText.Text = "Question will appear here"
questionText.Parent = questionFrame

-- Room timer (separate from question UI)
local roomTimerFrame = Instance.new("Frame")
roomTimerFrame.Name = "RoomTimerFrame"
roomTimerFrame.Size = UDim2.new(0.15, 0, 0.06, 0)
roomTimerFrame.Position = UDim2.new(0.425, 0, 0.02, 0) -- Top center
roomTimerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
roomTimerFrame.BackgroundTransparency = 0.3
roomTimerFrame.Visible = true
roomTimerFrame.Parent = screenGui

local roomTimerText = Instance.new("TextLabel")
roomTimerText.Name = "RoomTimerText"
roomTimerText.Size = UDim2.new(1, 0, 1, 0)
roomTimerText.BackgroundTransparency = 1
roomTimerText.TextColor3 = Color3.fromRGB(255, 255, 255)
roomTimerText.TextSize = 24
roomTimerText.Font = Enum.Font.GothamBold
roomTimerText.Text = "30"
roomTimerText.Parent = roomTimerFrame

-- Answer buttons
local answerButtons = {}
local buttonColors = {
	Color3.fromRGB(50, 100, 200),  -- Blue
	Color3.fromRGB(50, 200, 100),  -- Green
	Color3.fromRGB(200, 100, 50),  -- Orange
	Color3.fromRGB(200, 50, 200)   -- Purple
}

for i = 1, 4 do
	local button = Instance.new("TextButton")
	button.Name = "AnswerButton" .. i
	button.Size = UDim2.new(0.9, 0, 0.1, 0)
	button.Position = UDim2.new(0.05, 0, 0.4 + (i-1) * 0.15, 0)
	button.BackgroundColor3 = buttonColors[i]
	button.BackgroundTransparency = 0.3
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Font = Enum.Font.Gotham
	button.Text = "Answer " .. i
	button.TextWrapped = true
	button.Parent = questionFrame

	answerButtons[i] = button

	-- Add click event
	button.MouseButton1Click:Connect(function()
		selectAnswer(i)
	end)
end

-- Create game over screen
local gameOverFrame = Instance.new("Frame")
gameOverFrame.Name = "GameOverFrame"
gameOverFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
gameOverFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
gameOverFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
gameOverFrame.BackgroundTransparency = 0.2
gameOverFrame.Visible = false
gameOverFrame.ZIndex = 10  -- Ensure it appears above other UI
gameOverFrame.Parent = screenGui

local gameOverText = Instance.new("TextLabel")
gameOverText.Name = "GameOverText"
gameOverText.Size = UDim2.new(1, 0, 0.3, 0)
gameOverText.Position = UDim2.new(0, 0, 0.1, 0)
gameOverText.BackgroundTransparency = 1
gameOverText.TextColor3 = Color3.fromRGB(255, 255, 255)
gameOverText.TextSize = 36
gameOverText.Font = Enum.Font.GothamBold
gameOverText.Text = "Game Over!"
gameOverText.Parent = gameOverFrame

local gameOverReason = Instance.new("TextLabel")
gameOverReason.Name = "GameOverReason"
gameOverReason.Size = UDim2.new(1, 0, 0.2, 0)
gameOverReason.Position = UDim2.new(0, 0, 0.3, 0)
gameOverReason.BackgroundTransparency = 1
gameOverReason.TextColor3 = Color3.fromRGB(255, 255, 255)
gameOverReason.TextSize = 20
gameOverReason.Font = Enum.Font.Gotham
gameOverReason.Text = "Wrong answer!"
gameOverReason.Parent = gameOverFrame

local continueText = Instance.new("TextLabel")
continueText.Name = "ContinueText"
continueText.Size = UDim2.new(1, 0, 0.15, 0)
continueText.Position = UDim2.new(0, 0, 0.5, 0)
continueText.BackgroundTransparency = 1
continueText.TextColor3 = Color3.fromRGB(255, 255, 255)
continueText.TextSize = 20
continueText.Font = Enum.Font.GothamBold
continueText.Text = "Would you like to continue?"
continueText.Parent = gameOverFrame

-- Add restart button
local restartButton = Instance.new("TextButton")
restartButton.Name = "RestartButton"
restartButton.Size = UDim2.new(0.4, 0, 0.15, 0)
restartButton.Position = UDim2.new(0.1, 0, 0.7, 0)
restartButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
restartButton.BackgroundTransparency = 0.2
restartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restartButton.TextSize = 22
restartButton.Font = Enum.Font.GothamBold
restartButton.Text = "Restart"
restartButton.Parent = gameOverFrame

-- Add exit button
local exitButton = Instance.new("TextButton")
exitButton.Name = "ExitButton"
exitButton.Size = UDim2.new(0.4, 0, 0.15, 0)
exitButton.Position = UDim2.new(0.5, 0, 0.7, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
exitButton.BackgroundTransparency = 0.2
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 22
exitButton.Font = Enum.Font.GothamBold
exitButton.Text = "Exit"
exitButton.Parent = gameOverFrame

-- Create win screen
local winFrame = Instance.new("Frame")
winFrame.Name = "WinFrame"
winFrame.Size = UDim2.new(0.4, 0, 0.3, 0)
winFrame.Position = UDim2.new(0.3, 0, 0.35, 0)
winFrame.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
winFrame.BackgroundTransparency = 0.2
winFrame.Visible = false
winFrame.Parent = screenGui

local winText = Instance.new("TextLabel")
winText.Name = "WinText"
winText.Size = UDim2.new(1, 0, 0.6, 0)
winText.Position = UDim2.new(0, 0, 0.2, 0)
winText.BackgroundTransparency = 1
winText.TextColor3 = Color3.fromRGB(255, 255, 255)
winText.TextSize = 36
winText.Font = Enum.Font.GothamBold
winText.Text = "Congratulations!\nYou completed the exam!"
winText.TextWrapped = true
winText.Parent = winFrame

-- Variables to track state
local currentQuestion = nil
local selectedAnswerIndex = nil

-- Function to reset answer button appearances
local function resetButtonAppearance()
	for i, button in ipairs(answerButtons) do
		button.BackgroundColor3 = buttonColors[i]
		button.BackgroundTransparency = 0.3
	end
	selectedAnswerIndex = nil
end

-- Function to select an answer
function selectAnswer(index)
	-- Reset previous selection
	resetButtonAppearance()

	-- Highlight selected button
	answerButtons[index].BackgroundTransparency = 0
	selectedAnswerIndex = index

	-- Send selection to server
	answerEvent:FireServer(index)

	-- Show selection confirmation
	local selectionLabel = Instance.new("TextLabel")
	selectionLabel.Size = UDim2.new(1, 0, 0.1, 0)
	selectionLabel.Position = UDim2.new(0, 0, 0.9, 0)
	selectionLabel.BackgroundTransparency = 0.5
	selectionLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	selectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectionLabel.TextSize = 20
	selectionLabel.Font = Enum.Font.GothamBold
	selectionLabel.Text = "You selected: " .. answerButtons[index].Text
	selectionLabel.Parent = questionFrame

	-- Keep the timer visible but hide all answer options after a brief moment
	spawn(function()
		wait(0.5)
		-- Hide answer options but keep the question and timer
		for i, button in ipairs(answerButtons) do
			button.Visible = false
		end

		-- Move the selection confirmation up
		selectionLabel.Position = UDim2.new(0, 0, 0.4, 0)

		-- Add message to touch door
		local doorMessage = Instance.new("TextLabel")
		doorMessage.Size = UDim2.new(1, 0, 0.1, 0)
		doorMessage.Position = UDim2.new(0, 0, 0.5, 0)
		doorMessage.BackgroundTransparency = 0.5
		doorMessage.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
		doorMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
		doorMessage.TextSize = 20
		doorMessage.Font = Enum.Font.GothamBold
		doorMessage.Text = "Now go touch the door!"
		doorMessage.Parent = questionFrame

		-- Then hide the entire frame after 2 seconds
		wait(1.5)
		questionFrame.Visible = false
	end)
end

-- Event handlers
questionEvent.OnClientEvent:Connect(function(questionData)
	currentQuestion = questionData

	-- Make sure any previous selection UI is cleared
	questionFrame.Visible = false
	for _, child in pairs(questionFrame:GetChildren()) do
		if child:IsA("TextLabel") and not (child.Name == "QuestionText") then
			child:Destroy()
		end
	end

	-- Reset all buttons
	for i, button in ipairs(answerButtons) do
		button.Visible = true
		button.BackgroundTransparency = 0.3
	end

	-- Display the question and answers
	questionText.Text = questionData.question

	for i, option in ipairs(questionData.options) do
		answerButtons[i].Text = option
	end

	resetButtonAppearance()
	questionFrame.Visible = true

	print("Displayed question: " .. questionData.question)
end)

timerEvent.OnClientEvent:Connect(function(timeRemaining)
	-- Update the room timer
	roomTimerText.Text = tostring(timeRemaining)
	print("Received timer update: " .. timeRemaining)

	-- Make timer text red when time is running low
	if timeRemaining <= 10 then
		roomTimerText.TextColor3 = Color3.fromRGB(255, 0, 0)
		roomTimerFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	else
		roomTimerText.TextColor3 = Color3.fromRGB(255, 255, 255)
		roomTimerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end
end)

gameOverEvent.OnClientEvent:Connect(function(reason)
	-- Hide question frame
	questionFrame.Visible = false

	-- Show game over screen
	gameOverReason.Text = reason
	gameOverFrame.Visible = true

	-- Set a flag to handle this state
	local isGameOver = true

	-- The buttons will handle closing this screen, so we don't automatically hide it
end)

-- Add button functionality
restartButton.MouseButton1Click:Connect(function()
	-- Immediately hide the game over screen
	gameOverFrame.Visible = false

	-- Make sure it stays hidden by checking again after a short delay
	spawn(function()
		wait(0.1)
		gameOverFrame.Visible = false
	end)

	-- Kill the player to trigger respawn (which will restart the game)
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") then
		wait(0.2) -- Small delay before killing character
		character.Humanoid.Health = 0
	end
end)

exitButton.MouseButton1Click:Connect(function()
	-- Hide the game over screen
	gameOverFrame.Visible = false

	-- Teleport the player back to the game lobby or exit the game
	-- Option 1: Teleport to lobby (if you have a lobby)
	-- game:GetService("TeleportService"):Teleport(gameId, player)

	-- Option 2: Kick the player (will exit them from the game)
	player:Kick("Thanks for playing! You've exited the game.")
end)

gameWinEvent.OnClientEvent:Connect(function()
	-- Hide question frame
	questionFrame.Visible = false

	-- Show win screen
	winFrame.Visible = true

	-- Keep visible for longer
	wait(5)
	winFrame.Visible = false
end)

-- Event when character is added
player.CharacterAdded:Connect(function(newCharacter)
	-- Forcibly hide any UI that might be visible
	questionFrame.Visible = false
	gameOverFrame.Visible = false
	winFrame.Visible = false

	-- Add a character removal watcher to handle deaths
	newCharacter:WaitForChild("Humanoid").Died:Connect(function()
		wait(0.5)
		-- Ensure game over frame is hidden on actual death
		gameOverFrame.Visible = false
	end)
end)

-- Initial character setup
if player.Character then
	player.Character:WaitForChild("Humanoid").Died:Connect(function()
		wait(0.5)
		-- Ensure game over frame is hidden on actual death
		gameOverFrame.Visible = false
	end)
end