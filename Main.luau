--!native

--[[

Signal-Minus, an exceptionally minimalistic signal module written in Roblox's Luau.
I'm way too lazy to make a head, tail & :Wait() function
Someone please fork this repo and add them.



]]

--Types--

export type Signal = typeof({
	new = function()
	end,
	Fire = function()
	end,
	Connect = function()
	end,
	Once = function()
	end
})

type Class = {
	Name:string,
	MaximumSignals:number|nil,
	MaxSignalsFunction:(SignalTableName:string, GivenFunction:string) -> (any), --Fires when you attempt to create a signal when #Signals > MaximumSignals
	MaxRuntime:number|nil --Max time the signal can run before it disconnects
}


--Module--

local Signal = {}


--Public Functions--

--[=[

	Name:string,
	MaximumSignals: number|nil,
	MaxSignalsFunction: (SignalTableName:string, GivenFunction:string) -> (any), --Fires when you attempt to create a signal when #Signals > MaximumSignals
	MaxRuntime: number|nil --Max time the signal can run before it disconnects

]=]
function Signal.new(SignalInfo:Class)
	assert(SignalInfo.Name, "No name for signals module provided")
	assert(not Signal[SignalInfo.Name], `Already found a signal named {SignalInfo.Name}, try it naming something else`)

	Signal[SignalInfo.Name] = {}

	local self = setmetatable(Signal[SignalInfo.Name], Signal)

	self.Name = SignalInfo.Name
	self.MaximumSignals = SignalInfo.MaximumSignals
	self.MaxSignalsFunction = self.MaxSignalsFunction

	self.Signals = {}

	setmetatable(self, {__index = Signal})

	return self
end


--Fires the signal
function Signal:Fire(...)

	local Arguments = {...}

	for _, Connection in self.Signals do
		local Coroutine = coroutine.create(function()
			Connection.Function(table.unpack(Arguments))
		end)

		coroutine.resume(Coroutine)
	end
end


function Signal:Connect(FunctionToConnect:(any) -> (any))

	if type(self.MaximumSignals) == "number" and #self.Signals >= self.MaximumSignals then self.MaxSignalsFunction() return end

	local Connection = {
		Function = FunctionToConnect,
	}

	function Connection:Disconnect()
		table.remove(self.Signals, table.find(self.Signals, Connection))
		table.clear(Connection)
		Connection = nil
	end

	table.insert(self.Signals, Connection)

	return Connection
end


function Signal:Once(FunctionToConnect:(any) -> (any))

	local Connection

	Connection = {
		Function = function(...)
			FunctionToConnect(...)
			pcall(function()
				table.remove(self.Signals, table.find(self.Signals, Connection))
				table.clear(Connection)
				Connection = nil
			end)
		end,
	}

	function Connection:Disconnect()
		table.remove(self.Signals, table.find(self.Signals, Connection))
		table.clear(Connection)
		Connection = nil
	end

	table.insert(self.Signals, Connection)

	return Connection
end


return Signal
