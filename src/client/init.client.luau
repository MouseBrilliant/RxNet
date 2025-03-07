local Net = require(game.ReplicatedStorage:WaitForChild"Shared":WaitForChild"Net")

Net.Foo()
function Net.Bar(message : string)
    print(message)
    task.wait(2)
    Net.Foo()
end

task.spawn(
    function()
        local sent = 0
        while task.wait() do
            Net.SendIt()
            sent += 1
            print(`Sent x{sent}`)
        end
    end
)

while task.wait(0.5) do
    local guess = math.random(0,10)
    Net.GuessingGame(guess):andThen(function()
        print("We guessed right!!", guess)
    end):catch(function()
        print("We guessed wrong!!!", guess)
    end)
end
