--[[
     ____        _   _      _   
    |  _ \ __  _| \ | | ___| |_ 
    | |_) |\ \/ /  \| |/ _ \ __|
    |  _ <  >  <| |\  |  __/ |_ 
    |_| \_\/_/\_\_| \_|\___|\__|


    An elegant, fast, networking library for luau

    Author: MouseBrilliant
    Licence: MIT
    Edited: Mar, 3, 2025

]]

local Promise = require(script.Parent:WaitForChild"Promise")

--[[

    _   _      _                                     _   
    | \ | | ___| |_ _ __ __ _ _   _ _ __   __ _ _   _| |_ 
    |  \| |/ _ \ __| '__/ _` | | | | '_ \ / _` | | | | __|
    | |\  |  __/ |_| | | (_| | |_| | | | | (_| | |_| | |_ 
    |_| \_|\___|\__|_|  \__,_|\__,_|_| |_|\__,_|\__,_|\__|

    Handles packet transmission between client and server using RemoteEvents.
    Provides both reliable (SendPacket) and unreliable (TossPacket) messaging.
]]

--// Configuration Constants
local Storage = game:GetService("ReplicatedStorage")
local Identifier = "@RxNet/Netraunaut/NASA" -- Reliable communication channel
local UIdentifier = "@RxNet/Netraunaut/SpaceX" -- Unreliable communication channel
local FIdentifier = "@RxNet/Netraunaut/SpaceLink" -- Remote Function
local BIdentifier = "@RxNet/Netraunaaut/Boot"

--[[

    Netronaut

]]

local Netronaut = {}

--[[

    Helper Function

]]

type ExtractedPlayers = "ALL" | {Player}

local function extractPlayersFromArgs(...)
    -- Get the number of arguments
    local numArgs = select("#", ...)

    -- Extract the last argument (the player instance)
    local player = select(numArgs, ...)

    if not typeof(player) == "Player" then
        error(`Expected last argument to be a player! Got {player}`)
    end

    -- Now you can use the player instance
    -- For example: player:getName()

    -- If you need the other arguments as well, you can:
    local args = {...}
    -- Remove the player from the args table
    args[numArgs] = nil

    return args, player
end

--[[

    Netronaut Type Definition

]]

export type Netronaut = {
    -- Server-side methods
    SendPacket: (players: { [number]: Player }?, any...) -> nil, -- Sends a reliable packet.
    TossPacket: (players: { [number]: Player }?, any...) -> nil, -- Sends an unreliable packet.
    RecievePacket: (fn: (Player, any...) -> any...) -> nil, -- Handles incoming packets.
    HandleFunction: (fn: (Player, any...) -> any...) -> nil, -- Handles remote function calls.
    HandleBootFunction: (fn: (Player, any...)-> any...)->nil,

    -- Client-side methods
    SendPacket: (any...) -> nil, -- Sends a reliable packet to the server.
    TossPacket: (any...) -> nil, -- Sends an unreliable packet to the server.
    RecievePacket: (fn: (any...) -> any...) -> nil, -- Handles incoming packets from the server.
    CallFunction: (any...) -> Promise.Promise<any...>, -- Calls a server function and returns a promise.
    CallBootFunction: (any...) -> Promise.Promise<any...>
}

--[[

    Remote Location Logic

]]

-- Remote Event Instances
local RemoteEvent: RemoteEvent = nil -- Reliable communication
local URemoteEvent: UnreliableRemoteEvent = nil -- Unreliable communication
local RemoteFunction: RemoteFunction = nil -- Remote function calls
local BootFunction : RemoteFunction = nil

if game:GetService("RunService"):IsServer() then

    --[[

        Server-Side Initialization:
        Creates RemoteEvents in ReplicatedStorage for packet transmission.

    ]]

    RemoteEvent = Instance.new("RemoteEvent", Storage)
    RemoteEvent.Name = Identifier
    URemoteEvent = Instance.new("UnreliableRemoteEvent", Storage)
    URemoteEvent.Name = UIdentifier
    RemoteFunction = Instance.new("RemoteFunction", Storage)
    RemoteFunction.Name = FIdentifier
    BootFunction = Instance.new("RemoteFunction",Storage)
    BootFunction.Name = BIdentifier
    

    function Netronaut.SendPacket(...)
        --[[
            Sends a reliable packet to specified players or all if none specified.
        ]]
        local args, player = extractPlayersFromArgs(...)
        RemoteEvent:FireClient(player, unpack(args))
    end

    function Netronaut.RecievePacket(fn: (Player, any...) -> any...)
        --[[
            Handles incoming reliable packets from clients.
            If the callback returns a value, it is sent back as a response.
        ]]
        RemoteEvent.OnServerEvent:Connect(fn)
    end

    function Netronaut.TossPacket(...)
        --[[
            Sends an unreliable packet to specified players or all if none specified.

        ]]
        local args, player = extractPlayersFromArgs(...)
        URemoteEvent:FireClient(player, unpack(args))
    end

    function Netronaut.HandleFunction(fn: (Player, any...) -> any...)
        --[[
            Sets up handler for remote function calls from clients.
        ]]
        RemoteFunction.OnServerInvoke = fn
    end

    function Netronaut.HandleBootFunction(fn: (Player, any...) -> any...)
        BootFunction.OnServerInvoke = fn
    end

else

    --[[

        Client-Side Initialization:
        Retrieves RemoteEvents from Storage.

    ]]

    RemoteEvent = Storage:WaitForChild(Identifier)
    URemoteEvent = Storage:WaitForChild(UIdentifier)
    RemoteFunction = Storage:WaitForChild(FIdentifier)
    BootFunction = Storage:WaitForChild(BIdentifier)

    function Netronaut.SendPacket(...)
        --[[
            Sends a reliable packet to the server.
        ]]
        RemoteEvent:FireServer(...)
    end

    function Netronaut.RecievePacket(fn: (any...) -> any...)
        --[[
            Handles incoming reliable packets from the server.
            If the callback returns a value, it is sent back as a response.
        ]]
        RemoteEvent.OnClientEvent:Connect(fn)
    end

    function Netronaut.TossPacket(...)
        --[[
            Sends an unreliable packet to the server.
        ]]
        URemoteEvent:FireServer(...)
    end

    function Netronaut.CallFunction(...)
        --[[
            Calls a function on the server and returns the result
        ]]
        return RemoteFunction:InvokeServer(...)
    end

    function Netronaut.CallBootFunction(...)
        return BootFunction:InvokeServer(...)
    end
end

return table.freeze(Netronaut) :: Netronaut