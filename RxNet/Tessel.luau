--[[
     ____        _   _      _
    |  _ \ __  _| \ | | ___| |_
    | |_) |\ \/ /  \| |/ _ \ __|
    |  _ <  >  <| |\  |  __/ |_
    |_| \_\/_/\_\_| \_|\___|\__|

    An elegant, fast, networking library for roblox

    Author: MouseBrilliant
    Licence: MIT
    Edited: Mar, 3, 2025

]]

local Promise = require(script.Parent:WaitForChild"Promise")
local Netronaut = require(script.Parent:WaitForChild"Netraunaut")
local IsServer = game:GetService("RunService"):IsServer()

--[[
    _____                  _
    |_   _|__  ___ ___  ___| |
      | |/ _ \/ __/ __|/ _ \ |
      | |  __/\__ \__ \  __/ |
      |_|\___||___/___/\___|_|

    Tracks the structure and functions of modules, mapping them for efficient access.
]]

local Tessel = {}
Tessel.__metatable = "@RxNet/Tessel" -- Prevents modification of metatable.

--[[

    Types

]]
export type Event = {}
export type Function<T...> = {}
export type Unreliable = {}

export type TesselModule = {
    track: (ModuleScript, table) -> nil, -- Constructor for creating a tracked module instance.
    Event : Event,
    Function: Function,
    Unreliable: Unreliable,
    GetIndex: SyncTesselation
}


type ID = number
type CantorID = number
type Location = string
type TesselNet = table -- User provided table used as an index

type EndPointName = string
type EndPointType = "event" | "function" | "unreliable" | nil
type EndPoint = {type : EndPointType,id: CantorID, registered : boolean}
type Outgoing = (any...)->nil

type TesselEndPoints = {[EndPointName] : EndPoint}

type TesselIndex = {
    id : ID,
    EndPoints : TesselEndPoints,
    Outgoing: {[EndPointName] : Outgoing},
    count : number
}

type CantorIndex = {
    [CantorID] : (any...) -> (any...)
}

export type Tesselation =  {[TesselNet] : TesselIndex}
export type SyncTesselation = {[Location] :TesselIndex}


--[[

    Utils

]]

local function getModulePath(module: ModuleScript): string
    --[[

        Resolves the full hierarchical path of a module as a string.
        Example: A module inside "ReplicatedStorage.Modules.MyModule" becomes "/ReplicatedStorage/Modules/MyModule"

    ]]
    local pathParts = {}

    while module and module ~= game do
        table.insert(pathParts, 1, module.Name)
        module = module.Parent
    end

    return "/" .. table.concat(pathParts, "/")
end



--[[

    Tessel

    Some Terms:
        TesselEvent: Remote Event
        TesselFunction: RemoteFunction
        TesselUnreliable: Unreliable Remote Event

        Tessel End Point: Any event, function or unreliable created
            by Tessel.

]]

-- Event Types
local TesselEvent = "event"
local TesselFunction = "function"
local TesselUnreliable = "unreliable"

Tessel.Event = TesselEvent
Tessel.Function = TesselFunction
Tessel.TesselUnreliable = TesselUnreliable

--[[

    Cantor Pairing

]]

local function CantorPair(x, y)
    --[[

        Fix: Using Cantor's Pairing Function to guarantee uniqueness.

        π(x, y) = ((x + y) * (x + y + 1)) / 2 + y

    ]]
    return ((x + y) * (x + y + 1)) // 2 + y
end

--[[

    Tessel State Trackers

]]

local SyncTesselation:{[Location] :TesselIndex} = {}
local Tesselation:{[TesselNet] : TesselIndex} = {}
local CantorRecievingIndex: CantorIndex = {}
local NumTessels = 0

--[[

    Synchronization Layer

]]

local function GetModuleIDFromServer(location: string) : Promise.Promise<number>
    assert(not IsServer,"This cannot be called on server!!!")
    return Promise.new(function(resolve,reject,_)
        local result = Netronaut.CallBootFunction(location)
        if result then
            resolve(result)
        else
            reject()
        end
    end)
end

if IsServer then

    Netronaut.HandleBootFunction(function(player,location: string)
        if not location or typeof(location) ~="string" then
            return nil
        end
        local result  : TesselIndex? = SyncTesselation[location]
        if not result then
            return nil
        end
        return result.id
    end)

end
--[[

    Tessel Implementation

]]

function Tessel.track(module: ModuleScript, net: table)
    assert(typeof(module) == "Instance", "Expected an ModuleScript")
    assert(module:IsA("ModuleScript"), "Expected a ModuleScript.")
    assert(typeof(net) == "table", "Expected a table.")
    assert(not getmetatable(net), "Table must not already have a metatable.")
    if Tesselation[net] then
        return
    end

    --[[

        Generates:

            Server:

                Tesselation: {
                    [table 'net'] : TesselIndex
                }

                SyncTessel: {
                    ['location to module'] : TesselIndex
                }

                TesselIndex = {
                    count = #of functions
                    id = module id,
                    EndPoints = {type, fn, cantor id}
                }

            Client:

                Tesselation and SyncTessel same as server, however,

                TesselIndex.id is retrieved from server,
                    this ensures CantorIndex is generated correctly
                    for synchronizing.
    ]]


    -- Resolve module path
    local location = getModulePath(module)
    -- Setup Index
    local index : TesselIndex

    if IsServer then

        index = {
            id = NumTessels,
            EndPoints = {},
            Outgoing = {},
            count = 0
        }
        NumTessels += 1

    else
        index = {
            EndPoints = {},
            Outgoing = {},
            count = 0
        }

        local p = GetModuleIDFromServer(location)

        assert(Promise.is(p))


        local success, value = p:await()
        if success then
            index.id = value
        else
            error(`network module at {location} is apparently not registered on server!!!`)
        end

    end

    -- Setup Tracking Tables
    SyncTesselation[location] = index
    Tesselation[net] = index

    -- Setup Tessel tracking
    setmetatable(net,{
        __index = index.Outgoing,
        __newindex = Tessel.__newindex,
        __metatable = Tessel.__metatable
    })

    -- forcing tessel to track missed methods
    for key,value in net do
        Tessel.__newindex(net,key,value)
        net[key] = nil
    end
end

Tessel.__newindex = function(net: table, key: string?, fn: ((any...) -> any...?)?)
    assert(typeof(key) == "string", "Function key must be a string.")
    assert(typeof(fn) == "function", "Assigned value must be a function.")
    --[[

        First time a function is declared.
            Where as, second time, functions are implemented.

        In other words, first time we check to see the type of
        endpoint user wants, as in event, function, etc
            and we setup outgoing handlers

        Second time, we are setting up listeners that respond to
        these endpoints (so incoming)

    ]]
    local TesselNet : TesselIndex = Tesselation[net]
    local endPoint : EndPoint = TesselNet.EndPoints[key]
    if endPoint then

        if endPoint.registered then
            warn(`{key} is registered already, skipping...`)
            return
        end

        local cid : CantorID = endPoint.id
        if endPoint.type == TesselEvent then
            endPoint.registered = true
            CantorRecievingIndex[cid] = fn
        elseif endPoint.type == TesselFunction then
            endPoint.registered = true
            CantorRecievingIndex[cid] = fn
        elseif endPoint.type == TesselUnreliable then
            endPoint.registered = true
            CantorRecievingIndex[cid] = fn
        else
            assert(false,"This should not be happening")
        end

        return
    end

    --[[

        -- Ok, so it's being created first time, we figure out,
            what type of endpoint it is.

            Then we setup outgoing endpoints
    ]]
    local t : EndPointType? = fn()
    local cid : CantorID = CantorPair(TesselNet.id,TesselNet.count);
    endPoint = {}
    TesselNet.count += 1;


    if not t or t == TesselEvent then
        endPoint.type = TesselEvent
        TesselNet.Outgoing[key] = function(...)
            Netronaut.SendPacket(cid,...)
        end
    elseif t == TesselFunction then
        endPoint.type = TesselFunction
        if IsServer then
            TesselNet.Outgoing[key] = function()
                error("Functions can only be invoked by clients!!")
            end
        else
            TesselNet.Outgoing[key] = function(...)
                local args = ...
                return Promise.new(function(resolve,reject,_)
                    local results = {Netronaut.CallFunction(cid,args)}
                    if results[1] then
                        resolve(table.unpack(results,2))
                    else
                        reject(table.unpack(results,2))
                    end
                end)
            end
        end
    elseif t == TesselUnreliable then
        endPoint.type = TesselUnreliable
        TesselNet.Outgoing[key] = function(...)
            Netronaut.TossPacket(cid,...)
        end
    else
        error(`Unexpected return value ({t}) from registered function ({key})!`)
    end

    endPoint.id = cid
    TesselNet.EndPoints[key] = endPoint
end

function Tessel.GetIndex()
    return SyncTesselation
end

if IsServer then

    Netronaut.RecievePacket(function(player: Player, cid: CantorID, ...)
        if cid == nil or CantorRecievingIndex[cid] == nil then
            warn(`{player} attempted to call an unregistered or invalid RxNet endpoint`)
            return
        end
        if ... == nil then
            CantorRecievingIndex[cid](player)
        else
            CantorRecievingIndex[cid](...,player)
        end
    end)

    Netronaut.CatchPacket(function(player: Player, cid: CantorID, ...)
        if cid == nil or CantorRecievingIndex[cid] == nil then
            warn(`{player} attempted to call an unregistered or invalid RxNet endpoint`)
            return
        end
        if ... == nil then
            CantorRecievingIndex[cid](player)
        else
            CantorRecievingIndex[cid](...,player)
        end
    end)

    Netronaut.HandleFunction(function(player : Player, cid : CantorID, ...)
        if cid == nil or CantorRecievingIndex[cid] == nil then
            warn(`{player} attempted to call an unregistered or invalid RxNet endpoint`)
            return
        end
        local promise : Promise.Promise<any...> = CantorRecievingIndex[cid](...,player)

        if not Promise.is(promise) then
            return true,...
        end

        local success,results = promise:await()

        if success then
            return true,results
        end

        return false,results
    end)

else

    Netronaut.RecievePacket(function(cid: CantorIndex,...)
        if cid == nil or CantorRecievingIndex[cid] == nil then
            warn(`server attempted to call an unregistered or invalid RxNet endpoint!!!`)
            return
        end
        CantorRecievingIndex[cid](...)
    end)

    Netronaut.CatchPacket(function(cid: CantorIndex,...)
        if cid == nil or CantorRecievingIndex[cid] == nil then
            warn(`server attempted to call an unregistered or invalid RxNet endpoint!!!`)
            return
        end
        CantorRecievingIndex[cid](...)
    end)

end


return Tessel :: TesselModule
