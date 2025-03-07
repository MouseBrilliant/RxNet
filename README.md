# RxNet

```
 ____        _   _      _   
|  _ \ __  _| \ | | ___| |_ 
| |_) |\ \/ /  \| |/ _ \ __|
|  _ <  >  <| |\  |  __/ |_ 
|_| \_\/_/\_\_| \_|\___|\__|


An elegant, fast, networking library for roblox

Author: MouseBrilliant
Licence: MIT
Edited: Mar, 1, 2025
```

[Documentation](https://mousebrilliant.github.io/RxNet/)


## Key Features

__Hassle-Free Networking__ – Eliminates the need for manually creating, storing, or managing remote events and functions.

__Declarative API__ – Define networked functions as standard Lua functions; RxNet automatically handles their invocation across the network.

__Optimized for Performance__ – Efficient data handling minimizes latency, drawing inspiration from Warp and Red.

__Data Compression__ – Implements compression techniques influenced by ByteNet and Warp to reduce bandwidth usage.

__Zero Configuration__ – Ready to use out of the box with no setup required, yet fully customizable when needed.

__Custom Streaming__ – Supports streaming large amounts of data efficiently, inspired by Madwork's Replica system.
## Show me the code!

### Replicated Storage (or shared directory)

Register the module, define your api.

```lua
--Net.rxn
local RxNet = require(game:GetService("ReplicatedStorage"):WaitForChild("RxNet"))
local Net = {}
RxNet.Register(script,Net)

function Net.Foo() end
function Net.Bar(bar : string) end

return Net
```

### Server

- Calling the function[^1], fires the client.
- Redefining the function, sets up listeners.

[^1]: Last argument is always refrence to player.

```lua
--Server
local Net = require(game.ReplicatedStorage.Shared.Net)

function Net.Foo(player : Player)
    print(player,"ping!")
    Net.Bar("Pong! " ... tostring(math.random(0,10)), player)
end
```

### Client

Same as server, however, calling the function, fires the server.


```lua
--Client
local Net = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"))

function Net.Bar(message : string)
    print(message)
    task.wait(0.5)
    Net.Foo()
end

Net.Foo()
```

### Output

```diff
+ Player ping!
- Pong! 8
+ Player ping!
- Pong! 3
+ Player ping!
- Pong! 4
```


## Installation




## Attribution

