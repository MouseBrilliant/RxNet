# RxNet 

An Elegant, Fast, Roblox Networking Framework.

!!! note
    RxNet is still experimental. Do not use in production.


## Key Features

__Hassle-Free Networking__ – Eliminates the need for manually creating, storing, or managing remote events and functions.

__Declarative API__ – Define networked functions as standard Lua functions; RxNet automatically handles their invocation across the network.

__Optimized for Performance__ – Efficient data handling minimizes latency, drawing inspiration from Warp and Red.

__Data Compression__ – Implements compression techniques influenced by ByteNet and Warp to reduce bandwidth usage.

__Zero Configuration__ – Ready to use out of the box with no setup required, yet fully customizable when needed.

__Custom Streaming__ – Supports streaming large amounts of data efficiently, inspired by Madwork's Replica system.
## Show me the code!

Note the structure for the files:


- :material-folder-open: ReplicatedStorage
    - :octicons-file-code-16: RxNet (the module)
    - :octicons-file-code-16: Net.rxn
- :material-folder-open: ServerScriptService
    - :octicons-file-code-16: Server
- :material-folder-open: StarterPlayer
    - :material-folder-open: StarterPlayerScripts
        - :octicons-file-code-16: Client

__ReplicatedStorage__

Register the module. Define your API.

```lua
--Net.rxn
local Net = {}
require(script.Parent:WaitForChild("RxNet")).Register(script,Net)

function Net.Foo() 
end

function Net.Bar(bar : string) 
end

return Net
```

__Server__

Calling the function[^1], fires the client.
Redefining the function, sets up listeners.

[^1]: Last argument should always refrence to a player.

```lua
--Server
local Net = require(game.ReplicatedStorage.Net)

function Net.Foo(player : Player)
    print(player,"ping!")
    Net.Bar("Pong! " ... tostring(math.random(0,10)), player)
end
```

__Client__

Same as server, however, calling the function, fires the server.


```lua
--Client
local Net = require(game.ReplicatedStorage:WaitForChild("Net"))

function Net.Bar(message : string)
    print(message)
    task.wait(0.5)
    Net.Foo()
end

Net.Foo()
```

__Output__

```diff
+ Player ping!
- Pong! 8
+ Player ping!
- Pong! 3
+ Player ping!
- Pong! 4
```

