-- SimpleConfetti.lua
-- Place this directly in StarterGui as a LocalScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Wait for remotes to be available
local remotes = ReplicatedStorage:WaitForChild("DoorGoRemotes", 30)
local gameWinEvent = remotes:WaitForChild("GameWinEvent")

-- Function to create a single confetti piece
local function createConfettiPiece(container, x, y)
	local colors = {
		Color3.fromRGB(255, 0, 0),    -- Red
		Color3.fromRGB(0, 255, 0),    -- Green
		Color3.fromRGB(0, 0, 255),    -- Blue
		Color3.fromRGB(255, 255, 0),  -- Yellow
		Color3.fromRGB(255, 0, 255),  -- Pink
		Color3.fromRGB(0, 255, 255),  -- Cyan
	}

	local confetti = Instance.new("Frame")
	confetti.Size = UDim2.new(0, math.random(5, 15), 0, math.random(5, 15))
	confetti.Position = UDim2.new(x, 0, y, 0)
	confetti.BackgroundColor3 = colors[math.random(1, #colors)]
	confetti.BorderSizePixel = 0
	confetti.Rotation = math.random(0, 360)
	confetti.ZIndex = 10
	confetti.Parent = container

	return confetti
end

-- Function to create confetti effect
local function showConfetti()
	print("Creating confetti effect")

	-- Create a container for all confetti
	local container = Instance.new("Frame")
	container.Name = "ConfettiContainer"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = PlayerGui

	-- Create 100 pieces of confetti
	for i = 1, 100 do
		local x = math.random() -- Random position across screen
		local y = -0.1 -- Start above the screen

		local piece = createConfettiPiece(container, x, y)

		-- Animate this piece
		spawn(function()
			local startY = y
			local speed = math.random(5, 10) / 100
			local swayAmount = (math.random(-5, 5) / 100)
			local xPos = x

			for t = 0, 100 do
				-- Update position - falling with slight sway
				xPos = xPos + swayAmount
				local yPos = startY + (t * speed)
				piece.Position = UDim2.new(xPos, 0, yPos, 0)

				-- Add some rotation
				piece.Rotation = piece.Rotation + math.random(-5, 5)

				wait(0.05)

				-- If it's gone below the screen, destroy it
				if yPos > 1.1 then
					piece:Destroy()
					break
				end
			end
		end)
	end

	-- Clean up after animation finishes
	spawn(function()
		wait(10)
		if container and container.Parent then
			container:Destroy()
		end
	end)
end

-- Connect to win event
gameWinEvent.OnClientEvent:Connect(function()
	print("Game win event received!")
	showConfetti()
end)

print("Simple confetti script loaded")