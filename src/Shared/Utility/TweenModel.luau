-- // Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function TweenPosition(Model: Model, TargetCFrame: CFrame, Info: TweenInfo, Callback: () -> ()?)
	local Value = Instance.new("CFrameValue")
	Value.Value = Model:GetPivot()

	local ValueConnection
	ValueConnection = Value:GetPropertyChangedSignal("Value"):Connect(function()
		Model:PivotTo(Value.Value)
	end)

	local Tween = TweenService:Create(Value, Info, { Value = TargetCFrame })
	Tween:Play()

	Tween.Completed:Connect(function()
		ValueConnection:Disconnect()
		Value:Destroy()
		if Callback then
			Callback()
		end
	end)

	return function()
		if Value then
			Value:Destroy()
		end
		if ValueConnection.Connected then
			ValueConnection:Disconnect()
		end
		if Tween.PlaybackState == Enum.PlaybackState.Playing then
			Tween:Cancel()
		end
	end
end

local function TweenScale(Model: Model, StartScale: number, EndScale: number, TweenInfo: TweenInfo, Callback: () -> ()?)
	local elapsed = 0
	local scale = 0
	local tweenConnection

	local function onStep(deltaTime: number)
		elapsed = math.min(elapsed + deltaTime, TweenInfo.Time)

		local alpha = TweenService:GetValue(elapsed / TweenInfo.Time, TweenInfo.EasingStyle, TweenInfo.EasingDirection)

		scale = StartScale + alpha * (EndScale - StartScale)

		Model:ScaleTo(scale)

		if elapsed == TweenInfo.Time then
			tweenConnection:Disconnect()
			if Callback then
				Callback()
			end
		end
	end

	tweenConnection = RunService.Heartbeat:Connect(onStep)
end

return {
	Position = TweenPosition,
	Scale = TweenScale,
}
