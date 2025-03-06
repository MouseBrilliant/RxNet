local Net = require(game.ReplicatedStorage:WaitForChild"Shared":WaitForChild"Net")

Net.Foo()
function Net.Bar(message : string)
    print(message)
    task.wait(0.5)
    Net.Foo()
end