local Net = {}
require(game:GetService"ReplicatedStorage":WaitForChild"RxNet").Register(script,Net)

function Net:Foo()
end

function Net:Bar(bar : string)
end

function Net:FooBar(foo : string) : string

end

return Net