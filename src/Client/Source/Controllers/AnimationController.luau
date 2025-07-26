-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- // obj
local Animations = ReplicatedStorage:WaitForChild("Animations") :: Folder & { Animation }

-- // Init
local AnimationController = {}

function AnimationController:Start()
	LocalPlayer:GetAttributeChangedSignal("Animation"):Connect(function()
		local Animation = Animations:FindFirstChild(LocalPlayer:GetAttribute("Animation")) :: Animation
		if Animation then
			local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local Animator: Animator = Character.Humanoid.Animator

			local LoadedAnimation = Animator:LoadAnimation(Animation)
			LoadedAnimation:Play()
		end
	end)
end

return AnimationController
