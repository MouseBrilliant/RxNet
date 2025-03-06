local Net = {}
require(game:GetService"ReplicatedStorage":WaitForChild"RxNet").Register(script,Net)

function Net.Foo()
end

function Net.Bar(bar : string)
end

return Net