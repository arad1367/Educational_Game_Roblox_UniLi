-- GameManager.lua
-- Place in ServerScriptService
-- Manages the overall game logic, question database, and timer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create remote events for client-server communication
local remotes = Instance.new("Folder")
remotes.Name = "DoorGoRemotes"
remotes.Parent = ReplicatedStorage

local questionEvent = Instance.new("RemoteEvent")
questionEvent.Name = "QuestionEvent"
questionEvent.Parent = remotes

local answerEvent = Instance.new("RemoteEvent")
answerEvent.Name = "AnswerEvent"
answerEvent.Parent = remotes

local timerEvent = Instance.new("RemoteEvent")
timerEvent.Name = "TimerEvent"
timerEvent.Parent = remotes

local gameOverEvent = Instance.new("RemoteEvent")
gameOverEvent.Name = "GameOverEvent"
gameOverEvent.Parent = remotes

local gameWinEvent = Instance.new("RemoteEvent")
gameWinEvent.Name = "GameWinEvent"
gameWinEvent.Parent = remotes

local roomChangeEvent = Instance.new("RemoteEvent")
roomChangeEvent.Name = "RoomChangeEvent"
roomChangeEvent.Parent = remotes

-- Question database (replace with your localized AI questions)
-- Format: {question = "Question text", options = {option1, option2, option3, option4}, answer = correctOptionIndex}
local questionDatabase = {
	Room1 = {
		{question = "What is localized AI?", options = {"AI that only works in specific locations", "AI adapted to regional/cultural contexts", "AI that can only be accessed locally", "AI without internet connectivity"}, answer = 2},
		{question = "Which of these is a benefit of AI localization?", options = {"Lower costs", "Better user experience for global users", "Faster processing speeds", "All developers can use the same models"}, answer = 2},
		{question = "What must be considered when localizing AI?", options = {"Only language translation", "Only cultural norms", "Only legal regulations", "Language, culture, and legal considerations"}, answer = 4},
		{question = "Which challenge is specific to AI localization?", options = {"Hardware compatibility", "Network latency", "Cultural nuance recognition", "Battery consumption"}, answer = 3},
		{question = "What is 'transfer learning' in the context of localized AI?", options = {"Moving AI from one device to another", "Using knowledge from one domain to help in another", "Transferring data between countries", "Learning how to translate content"}, answer = 2},
		{question = "Which approach helps with multilingual AI applications?", options = {"Using only English datasets", "Universal language models", "Training separate models for each language", "Avoiding text entirely"}, answer = 2},
		{question = "Why might a voice assistant need localization?", options = {"To understand different accents", "To comply with varying privacy laws", "To recognize cultural references", "All of the above"}, answer = 4},
		{question = "What is a key challenge in localizing visual recognition AI?", options = {"Camera quality differences", "Different writing systems", "Color preferences", "Screen resolution variations"}, answer = 2},
		{question = "How does localization affect AI training data?", options = {"It requires more diverse datasets", "It makes data collection easier", "It eliminates the need for data annotation", "It has no significant impact"}, answer = 1},
		{question = "What is 'AI alignment' in the context of localization?", options = {"Ensuring AI and human values match", "Properly positioning AI cameras", "Aligning text on the screen", "Setting up proper network connections"}, answer = 1},
	},
	Room2 = {
		{question = "Which factor is most important when localizing AI for healthcare?", options = {"Patient privacy regulations", "Hospital Wi-Fi strength", "Screen sizes of devices", "Office hours"}, answer = 1},
		{question = "What is 'algorithmic bias' in localized AI?", options = {"When AI systems favor certain areas of a city", "When AI prefers certain programming languages", "When AI produces unfair outcomes for specific groups", "When algorithms run slower in certain countries"}, answer = 3},
		{question = "How does localized AI impact customer service?", options = {"It eliminates the need for human agents", "It can provide support in local languages and customs", "It requires customers to learn AI terminology", "It only works during business hours"}, answer = 2},
		{question = "What aspect of speech recognition requires localization?", options = {"Microphone quality", "Accent and dialect understanding", "Speaker volume", "Speech speed only"}, answer = 2},
		{question = "Which technique helps with low-resource language AI?", options = {"Using only English data", "Cross-lingual transfer learning", "Ignoring those languages", "Automatic direct translation"}, answer = 2},
		{question = "What is 'cultural context' in AI localization?", options = {"The physical location of AI servers", "Understanding local traditions, humor, and references", "The time zone settings", "The color of the AI interface"}, answer = 2},
		{question = "Why is ethical AI localization important?", options = {"To increase profits", "To comply with different ethical standards globally", "To make AI run faster", "To reduce development costs"}, answer = 2},
		{question = "What challenge do emoji present for localized AI?", options = {"Too many colors", "Different meanings across cultures", "File size concerns", "Screen compatibility issues"}, answer = 2},
		{question = "How can federated learning help with localized AI?", options = {"By centralizing all data collection", "By training models across distributed devices while keeping data local", "By eliminating the need for any training", "By making models smaller"}, answer = 2},
		{question = "What is an example of regulatory localization for AI?", options = {"Different bandwidth settings", "Adapting to GDPR in Europe vs. other privacy laws", "Different screen brightness", "Using different programming languages"}, answer = 2},
	},
	Room3 = {
		{question = "What is 'natural language understanding' in localized AI?", options = {"Understanding outdoor environments", "Comprehending human language nuances", "Natural selection algorithms", "Understanding wildlife sounds"}, answer = 2},
		{question = "How does localization affect recommendation systems?", options = {"It makes all recommendations global", "It allows for culturally relevant suggestions", "It prevents any personalization", "It has no effect on recommendations"}, answer = 2},
		{question = "What challenge do right-to-left languages present for AI?", options = {"They require special text processing", "They can't be processed by AI", "They require more computing power", "They don't present any challenges"}, answer = 1},
		{question = "Why might sentiment analysis need localization?", options = {"To run faster", "Because expressions of sentiment vary culturally", "To use less memory", "It doesn't need localization"}, answer = 2},
		{question = "What is 'locale-specific data' in AI?", options = {"Data stored on local devices", "Information specific to a region or culture", "Data that can't be shared online", "Large datasets"}, answer = 2},
		{question = "How does localization affect AI deployment strategies?", options = {"It makes deployment unnecessary", "It requires considering local infrastructure and conditions", "It simplifies deployment to one universal approach", "It only affects the UI colors"}, answer = 2},
		{question = "What is a challenge of localizing AI chatbots?", options = {"Understanding local slang and expressions", "Making them type faster", "Creating avatar images", "Keeping conversations short"}, answer = 1},
		{question = "How does AI localization affect financial services?", options = {"It eliminates the need for banks", "It must adapt to different currencies and financial regulations", "It makes financial services more expensive", "It has no effect on financial services"}, answer = 2},
		{question = "What is 'multimodal localization' in AI?", options = {"Using multiple computers", "Localizing across different forms of input/output (text, voice, image)", "Having many different language options", "Running AI in multiple locations"}, answer = 2},
		{question = "Why is continuous feedback important for localized AI?", options = {"To make the AI faster", "To improve adaptation to evolving local contexts", "To reduce server costs", "To comply with regulations only"}, answer = 2},
	}
}

-- Game state tracking
local playerState = {}
-- Structure: playerState[playerId] = {currentRoom = roomNumber, selectedAnswer = answerIndex, correctAnswer = correctAnswer, roomTimeRemaining = seconds}

-- Timer tracking
local playerTimers = {}

-- Forward declarations of functions that need to be used before they're defined
local startRoomTimer

-- Initialize player state when they join
local function setupPlayer(player)
	local userId = player.UserId
	playerState[userId] = {
		currentRoom = 1,
		selectedAnswer = nil,
		correctAnswer = nil,
		roomTimeRemaining = 30
	}

	print("Set up player state for " .. player.Name)

	-- Start room timer for this player
	startRoomTimer(player)
end

-- Select a random question from the database for the player's current room
local function getRandomQuestion(player)
	local userId = player.UserId
	if not playerState[userId] then return nil end

	local currentRoom = playerState[userId].currentRoom
	local roomQuestions = questionDatabase["Room" .. currentRoom]
	local randomIndex = math.random(1, #roomQuestions)
	local questionData = roomQuestions[randomIndex]

	-- Store the correct answer in player state
	playerState[userId].correctAnswer = questionData.answer
	playerState[userId].selectedAnswer = nil

	return questionData
end

-- Start the room timer for a player
startRoomTimer = function(player)
	local userId = player.UserId
	if not playerState[userId] then 
		print("Cannot start timer - player state not found")
		return 
	end

	-- Cancel existing timer if there is one
	if playerTimers[userId] then
		task.cancel(playerTimers[userId])
		playerTimers[userId] = nil
	end

	-- Set the time based on the current room (60 seconds for Room2, 30 seconds for others)
	local timeLimit = 30
	if playerState[userId].currentRoom == 2 then
		timeLimit = 60
		print("Setting 60-second timer for Room2")
	else
		print("Setting 30-second timer for Room" .. playerState[userId].currentRoom)
	end

	playerState[userId].roomTimeRemaining = timeLimit

	-- Update client immediately
	timerEvent:FireClient(player, timeLimit)

	print("Starting room timer for player " .. player.Name .. " with " .. timeLimit .. " seconds")

	-- Start timer countdown in a separate thread
	local timerThread = task.spawn(function()
		local count = timeLimit -- Start with the time limit

		while count > 0 do
			-- Wait 1 second
			task.wait(1)

			-- Check if player still exists
			if not player or not player:IsDescendantOf(game) or not playerState[userId] then
				print("Player no longer exists, stopping timer")
				break
			end

			-- Decrease time
			count = count - 1
			playerState[userId].roomTimeRemaining = count

			-- Send the updated time to client
			timerEvent:FireClient(player, count)
			print("Timer for " .. player.Name .. ": " .. count)

			-- Check if time's up
			if count <= 0 then
				print("Time's up for player " .. player.Name)
				gameOverEvent:FireClient(player, "Time's up!")

				-- Don't kill the player right away - let the client handle it
				-- with the restart/exit buttons
				break
			end
		end
	end)

	-- Store the timer thread reference
	playerTimers[userId] = timerThread
end

-- Handle when a player approaches a question part
local function onQuestionTriggered(player, roomNumber)
	local userId = player.UserId
	if not playerState[userId] then return end

	-- Always send a question regardless of room
	-- This helps debug the question system
	local questionData = getRandomQuestion(player)
	questionEvent:FireClient(player, questionData)
	print("Sent question to " .. player.Name .. " in room " .. playerState[userId].currentRoom)
end

-- Handle when a player submits an answer
local function onAnswerSubmitted(player, answerIndex)
	local userId = player.UserId
	if not playerState[userId] then return end

	playerState[userId].selectedAnswer = answerIndex
	print("Player " .. player.Name .. " selected answer " .. answerIndex)
end

-- Handle when a player touches a door
local function onDoorTouched(player, doorNumber)
	local userId = player.UserId
	if not playerState[userId] then 
		print("Player state not found for: " .. player.Name)
		return false 
	end

	-- Print current room information
	print("Player " .. player.Name .. " is in room " .. playerState[userId].currentRoom .. " and touched door " .. doorNumber)

	-- Check if player is in the correct room
	if playerState[userId].currentRoom ~= doorNumber then
		print("Player is in room " .. playerState[userId].currentRoom .. " but touched door " .. doorNumber)
		return false
	end

	-- Check if player has selected an answer
	if not playerState[userId].selectedAnswer then
		print("Player has not selected an answer yet")
		return false
	end

	-- Print debug info
	print("Player touched door with answer: " .. playerState[userId].selectedAnswer)
	print("Correct answer is: " .. playerState[userId].correctAnswer)

	-- Check if the answer is correct
	if playerState[userId].selectedAnswer == playerState[userId].correctAnswer then
		print("CORRECT ANSWER! Opening door " .. doorNumber)
		-- Correct answer! Move to next room or win
		if doorNumber < 3 then
			-- First, let the door controller know to open the door
			local nextRoom = doorNumber + 1
			print("Moving player to room " .. nextRoom)

			-- Reset player state for the new room
			playerState[userId].currentRoom = nextRoom
			playerState[userId].selectedAnswer = nil
			playerState[userId].correctAnswer = nil

			-- Cancel existing timer
			if playerTimers[userId] then
				task.cancel(playerTimers[userId])
				playerTimers[userId] = nil
			end

			-- Start a new timer for the new room
			startRoomTimer(player)

			-- Tell the client about the room change
			roomChangeEvent:FireClient(player, nextRoom)

			return true
		else
			-- Player finished all rooms, they win!
			gameWinEvent:FireClient(player)

			-- Cancel the timer
			if playerTimers[userId] then
				task.cancel(playerTimers[userId])
				playerTimers[userId] = nil
			end

			return true
		end
	else
		print("WRONG ANSWER! Game over for player")
		-- Wrong answer, game over
		gameOverEvent:FireClient(player, "Wrong answer!")

		-- Cancel the timer
		if playerTimers[userId] then
			task.cancel(playerTimers[userId])
			playerTimers[userId] = nil
		end

		-- Don't kill the player right away - let the client handle it
		-- with the restart/exit buttons
		return false
	end
end

-- Set up event handlers
questionEvent.OnServerEvent:Connect(onQuestionTriggered)
answerEvent.OnServerEvent:Connect(onAnswerSubmitted)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)

	-- Also set up character respawn handling
	player.CharacterAdded:Connect(function(character)
		-- Reset player state on respawn if it exists
		if playerState[player.UserId] then
			playerState[player.UserId].currentRoom = 1
			playerState[player.UserId].selectedAnswer = nil
			playerState[player.UserId].correctAnswer = nil

			-- Restart the room timer
			startRoomTimer(player)
		else
			-- If playerState doesn't exist, create it
			setupPlayer(player)
		end
	end)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId

	-- Cancel the timer
	if playerTimers[userId] then
		task.cancel(playerTimers[userId])
		playerTimers[userId] = nil
	end

	-- Clear player state
	playerState[userId] = nil
end)

-- Create a module to expose functions to other scripts
local GameManagerModule = {}

function GameManagerModule.OnDoorTouched(player, doorNumber)
	return onDoorTouched(player, doorNumber)
end

function GameManagerModule.GetPlayerCurrentRoom(player)
	if player and player.UserId and playerState[player.UserId] then
		return playerState[player.UserId].currentRoom
	end
	return 1
end

-- Make sure to return the module from this script
_G.GameManager = GameManagerModule -- Also expose via _G for easier access
return GameManagerModule