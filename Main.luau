--!native

--Types--

export type Class = {
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
	
	Signal[SignalInfo.Name] = {}
	
	local self = setmetatable(Signal[SignalInfo.Name], Signal)

	assert(Signal[SignalInfo.Name], `Already found a signal named {SignalInfo.Name}, try it naming something else`)

	self.Name = SignalInfo.Name
	self.MaximumSignals = SignalInfo.MaximumSignals
	self.MaxSignalsFunction = if self.MaximumSignals then self.MaxSignalsFunction else nil

	self.Signals = {}

	setmetatable(self, {__index = Signal})

	return self
end


--Fires the signal
function Signal:Fire(...)
	for _, Connection in self.Signals do
		coroutine.resume(Connection)
	end
end


function Signal:Connect(FunctionToConnect:(any) -> (any))

	if self.MaximumSignals and #self.Signals >= self.MaximumSignals then self.MaxSignalsFunction() return end

	local Connection = {
		Function = FunctionToConnect,
	}

	function Connection:Disconnect()
		table.remove(self.Signals, table.find(self.Signals, Connection))
		table.clear(Connection)
		Connection = nil
	end

	table.insert(self.Signals, coroutine.create(Connection.Function))

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

	table.insert(self.Signals, coroutine.create(Connection))

	return Connection
end


return Signal
