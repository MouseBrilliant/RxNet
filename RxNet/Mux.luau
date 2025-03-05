--[[
     ____        _   _      _   
    |  _ \ __  _| \ | | ___| |_ 
    | |_) |\ \/ /  \| |/ _ \ __|
    |  _ <  >  <| |\  |  __/ |_ 
    |_| \_\/_/\_\_| \_|\___|\__|


    An Elegant, fast, networking library for luau

    Author: MouseBrilliant

]]

--[[


     __  __            
    |  \/  |_   ___  __
    | |\/| | | | \ \/ /
    | |  | | |_| |>  < 
    |_|  |_|\__,_/_/\_\


    Mux manages network function mappings and packet routing.
    It creates unique MuxMaps for each key and ensures efficient function retrieval.
]]

local PacketSize = require(script.Parent:WaitForChild("PacketSize"))
local Netronaut = require(script.Parent:WaitForChild("Netronaut"))
local IsServer = game:GetService("RunService"):IsServer()


--[[

    Cantor.

    Cantor maps numbers to functions.

]]

local __CantorIndex__ = {}

local function CantorPair(x, y)
    --[[

        Fix: Using Cantor's Pairing Function to guarantee uniqueness.

        π(x, y) = ((x + y) * (x + y + 1)) / 2 + y

    ]]
    return ((x + y) * (x + y + 1)) // 2 + y
end


local function AddToCantorIndex(n1 : number, n2 : number, fn : (any...)->any...)
    assert(n1 > -1 and n2 > -1,"Non Negative Numbers Only!!!")
    __CantorIndex__[CantorPair(n1,n2)] = fn
end

local function CantorCall(identifier : number)

end

local function RxAddToCantorMap(identifier : number, fn: (any...)->any...)
    assert(identifier < 0, "ERROR, Identifiers >= 0 are reserved only for user space only!!!")
    __CantorIndex__[identifier] = fn
end


--[[

    Mux

]]

local Mux = {}
local AllMux = {}
local MuxCount = 0

local MuxMap = {}
MuxMap.__index = MuxMap

function Mux.new(key: string): MuxMap
    --[[

        Creates a new MuxMap for the given key.
        Ensures uniqueness to prevent key collisions.

    ]]
    assert(AllMux[key] == nil, "MUX KEY COLLISION DETECTED!!!")

    local map = MuxMap.new(MuxCount)
    AllMux[key] = map
    MuxCount += 1

    return map
end

function Mux.getIndex()
    --[[

        Retrieves the global index of all Mux instances.

    ]]
    return AllMux
end

function Mux.getCantorIndex()
    return __CantorIndex__
end

--[[

    MuxMap Type Definition

]]

export type MuxMap = {
    -- Server
    new: (id: number) -> MuxMap, -- Constructor for creating a new MuxMap.
    id : number,
    count: number, -- Tracks assigned function indices.
    name_map: { [string]: number }, -- Maps function names to their unique indices.

    -- Client
    new: () -> MuxMap, -- Constructor for creating a new MuxMap.
    name_fn_map: { [string]: (any...) -> any... }, -- Stores function references by name.

    -- Common
    Add: (self: MuxMap, key: string, fn: (any...) -> any...) -> nil, -- Adds a function to the MuxMap.
}

if IsServer then

    --[[

        Server-side MuxMap:
        Maps function names to unique indices, ensuring consistent lookup.

        Example:

        MuxMap {
            name_map = {
                "foo" = 0,
                "bar" = 1,
                "baz" = 3
            },
            id = <unique server identifier number>
        }

    ]]

    function MuxMap.new(id : number): MuxMap
        return setmetatable({
            id = id,
            count = 0,
            name_map = {},
            map = {}
        }, MuxMap)
    end

    function MuxMap:Add(key: string, fn: (any...) -> any...)
        --[[

            Adds a function to the MuxMap.
            If the function key already exists, updates the reference.

        ]]
        local count = self.name_map[key] or self.count

        self.name_map[key] = count
        self.map[count] = fn
        AddToCantorIndex(self.id,count,fn)

        if self.count == count then
            self.count += 1
        end
    end

else

    --[[

        Client-side MuxMap:
        Maps function names to function references.

        Example:

        MuxMap {
            name_fn_map = {
                "foo" = fn,
                "bar" = fn,
                "baz" = fn
            }
        }

    ]]

    function MuxMap.new(): MuxMap
        local self = setmetatable({}, MuxMap)
        self.name_fn_map = {}
        return self
    end

    function MuxMap:Add(key: string, fn: (any...)->any)
        self.name_fn_map[key] = fn
    end

end



--[[

    Reconciliation:
    Placeholder for potential synchronization between server and client.

]]

local RECONCILE = -1

if IsServer then

end


return table.freeze(Mux)
