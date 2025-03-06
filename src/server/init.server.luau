local Net = require(game.ReplicatedStorage.Shared.Net)

function Net.Foo(player : Player)
    print(`{player} : Ping!`)
    Net.Bar(`Pong! {math.random(0,10)}`,player)
end