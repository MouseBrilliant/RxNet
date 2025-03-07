local Net = {}
local RxNet = require(game:GetService"ReplicatedStorage":WaitForChild"RxNet")
RxNet.Register(script,Net)

function Net.Foo()
end

function Net.Bar(bar : string)
end

function Net.GuessingGame(guess : number) : RxNet.Promise<nil>
    return "function"
end

function Net.SendIt()
    return "unreliable"
end

return Net