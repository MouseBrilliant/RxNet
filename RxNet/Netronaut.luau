--[[
     ____        _   _      _   
    |  _ \ __  _| \ | | ___| |_ 
    | |_) |\ \/ /  \| |/ _ \ __|
    |  _ <  >  <| |\  |  __/ |_ 
    |_| \_\/_/\_\_| \_|\___|\__|


    An elegant, fast, networking library for luau

    Author: MouseBrilliant

]]

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
local Identifier = "@RxNet/Netronaut/NASA" -- Reliable communication channel
local UIdentifier = "@RxNet/Netronaut/SpaceX" -- Unreliable communication channel

--[[

    Netronaut

]]

local Netronaut = {}

--[[

    Netronaut Type Definition

]]

export type Netronaut = {
    -- Server-side methods
    SendPacket: (players: { [number]: Player }?, any...) -> nil, -- Sends a reliable packet.
    TossPacket: (players: { [number]: Player }?, any...) -> nil, -- Sends an unreliable packet.
    RecievePacket: (fn: (Player, any...) -> any...) -> nil, -- Handles incoming packets.

    -- Client-side methods
    SendPacket: (any...) -> nil, -- Sends a reliable packet to the server.
    TossPacket: (any...) -> nil, -- Sends an unreliable packet to the server.
    RecievePacket: (fn: (any...) -> any...) -> nil, -- Handles incoming packets from the server.
}

--[[

    Remote Location Logic

]]

-- Remote Event Instances
local RemoteEvent: RemoteEvent = nil -- Reliable communication
local URemoteEvent: UnreliableRemoteEvent = nil -- Unreliable communication

if game:GetService("RunService"):IsServer() then

    --[[

        Server-Side Initialization:
        Creates RemoteEvents in ReplicatedStorage for packet transmission.

    ]]

    RemoteEvent = Instance.new("RemoteEvent", Storage)
    RemoteEvent.Name = Identifier
    URemoteEvent = Instance.new("UnreliableRemoteEvent", Storage)
    URemoteEvent.Name = UIdentifier

    function Netronaut.SendPacket(players: { [number]: Player }?, ...)
        --[[

            Sends a reliable packet to specified players (or all if none specified).

        ]]
        if players then
            for _, player in players do
                RemoteEvent:FireClient(player, ...)
            end
        else
            RemoteEvent:FireAllClients(...)
        end
    end

    function Netronaut.RecievePacket(fn: (Player, any...) -> any...)
        --[[

            Handles incoming reliable packets from clients.
            If the callback returns a value, it is sent back as a response.

        ]]
        RemoteEvent.OnServerEvent:Connect(function(player, ...)
            local result = fn(player, ...)
            if result then
                Netronaut.SendPacket(result)
            end
        end)
    end

    function Netronaut.TossPacket(players: { [number]: Player }?, ...)
        --[[

            Sends an unreliable packet to specified players (or all if none specified).

        ]]
        if players then
            for _, player in players do
                URemoteEvent:FireClient(player, ...)
            end
        else
            URemoteEvent:FireAllClients(...)
        end
    end

else

    --[[

        Client-Side Initialization:
        Retrieves RemoteEvents from Storage.

    ]]

    RemoteEvent = Storage:WaitForChild(Identifier)
    URemoteEvent = Storage:WaitForChild(UIdentifier)

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
        RemoteEvent.OnClientEvent:Connect(function(...)
            local result = fn(...)
            if result then
                Netronaut.SendPacket(result)
            end
        end)
    end

    function Netronaut.TossPacket(...)
        --[[

            Sends an unreliable packet to the server.

        ]]
        URemoteEvent:FireServer(...)
    end
end

return table.freeze(Netronaut)
