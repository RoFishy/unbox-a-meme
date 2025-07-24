local TestService = {}

function TestService:Start()
	game:GetService("Players").PlayerAdded:Connect(function(Player: Player)
		task.wait(5)
		local Crate = require("@ServerClasses/Crate")

		local _Crate = Crate.new("Crate", Vector3.new(64.5, 0.5, 58.7), Player)

		local conn
		conn = Player.Chatted:Connect(function(_: string)
			_Crate:TakeDamage(25)
		end)

		_Crate.Destroying:Connect(function()
			conn:Disconnect()
		end)
	end)
end

return TestService
