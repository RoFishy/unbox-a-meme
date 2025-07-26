-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Modules/Utils
local FrameModules = script.Parent.Parent.Interface.Frames

local Hud = require("@Interface/Components/Hud")

-- // UI Shit
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local Frames = MainUI:WaitForChild("Frames") :: Frame & { Frame }

-- // local functions
local coreCall
do
	local MAX_RETRIES = 7

	function coreCall(method, ...)
		local result = {}
		for _ = 1, MAX_RETRIES do
			result = { pcall(StarterGui[method], StarterGui, ...) }
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

-- // Start
local InterfaceController = {}

function InterfaceController:Init()
	coreCall("SetCoreGuiEnabled", Enum.CoreGuiType.Backpack, false)
end

function InterfaceController:Start()
	Hud({
		OpenFrame = function(Name: string)
			self:OpenFrame(Name)
		end,
	})
end

function InterfaceController:OpenFrame(FrameName: string)
	local Frame = Frames:FindFirstChild(FrameName) :: Frame

	if Frame then
		if Frame.Visible == true then
			self:CloseAllFrames()
			return
		end
		self:CloseAllFrames()

		local OriginalPosition = Frame:GetAttribute("OriginalPosition")

		if not OriginalPosition then
			OriginalPosition = Frame.Position
			Frame:SetAttribute("OriginalPosition", OriginalPosition)
		end

		Frame.Position = Frame.Position + UDim2.fromScale(0, 0.3)
		Frame.Visible = true
		TweenService:Create(Frame, TweenInfo.new(0.2), { Position = OriginalPosition }):Play()

		local Module = FrameModules:FindFirstChild(Frame.Name)
		if Module and Module:IsA("ModuleScript") then
			local FrameModule = (require)(Module)
			FrameModule:Start()
		end
	end
end

function InterfaceController:CloseAllFrames()
	for _, Frame in Frames:GetChildren() do
		if not Frame:IsA("Frame") then
			return
		end
		if Frame.Visible == true then
			local OriginalPosition = Frame:GetAttribute("OriginalPosition") :: UDim2

			if not OriginalPosition then
				OriginalPosition = Frame.Position
				Frame:SetAttribute("OriginalPosition", OriginalPosition)
			end
			local OutTween = TweenService:Create(
				Frame,
				TweenInfo.new(0.2),
				{ Position = OriginalPosition + UDim2.fromScale(0, 0.5) }
			)

			OutTween:Play()
			task.wait(0.1)
			Frame.Visible = false
			Frame.Position = OriginalPosition

			local FrameModule = FrameModules:FindFirstChild(Frame.Name)
			if FrameModule and FrameModule:IsA("ModuleScript") then
				FrameModule = (require)(FrameModule)
				FrameModule:Stop()
			end
		else
			continue
		end
	end
end

return InterfaceController
