local Net = require(game.ReplicatedStorage.Shared.Net)
local Promise = require(game.ReplicatedStorage.RxNet).Promise

function Net.Foo(player : Player)
    print(`{player} : Ping!`)
    Net.Bar(`Pong! {math.random(0,10)}`,player)
end

local randomGuess = math.random(0,10)
function Net.GuessingGame(guess: number,player : Player)
    if guess == randomGuess then
        print(player,"guessed correctly!",randomGuess)
        return Promise.resolve()
    else
        print(player,"guessed wrong!")
        return Promise.reject()
    end
end

local recieved = 0
function Net.SendIt()
    recieved += 1
    print(`recieved: x{recieved}`)
end