local Net = {}
require(game:GetService"ReplicatedStorage":WaitForChild"RxNet").Register(script,Net)

function Net:Fou()
end

function Net:Baz(bar : string)
end

function Net:BarFoo(foo : string) : string

end

return Net