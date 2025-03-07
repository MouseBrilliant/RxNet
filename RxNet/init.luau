--[[
     ____        _   _      _   
    |  _ \ __  _| \ | | ___| |_ 
    | |_) |\ \/ /  \| |/ _ \ __|
    |  _ <  >  <| |\  |  __/ |_ 
    |_| \_\/_/\_\_| \_|\___|\__|


    An elegant, fast, networking library for roblox

    Author: MouseBrilliant
    Licence: MIT
    Edited: Mar, 1, 2025

]]

--[[

    Provides a high-level API for registering networked modules
    and retrieving the current module-function mappings.

]]

local Tessel = require(script:WaitForChild("Tessel"))
local Promise = require(script:WaitForChild"Promise")

--[[

    RxNet Type Definition

]]

export type RxNet = {
    Register: (ModuleScript, table) -> nil, -- Registers a module for networking.
    GetCurrentTesselMap: () -> Tessel.SyncTesselation, -- Retrieves the current mapped modules.
    Event : Tessel.Event,
    Function: Tessel.Function,
    Unreliable: Tessel.Unreliable,
    Promise : Promise.PromiseModule,
}

export type Promise<T...> = Promise.Promise<T...>

--[[

    RxNet

]]

local RxNet = {
    Event = Tessel.Event,
    Function = Tessel.Function,
    Unreliable = Tessel.Unreliable,
    Promise = Promise
}

function RxNet.Register(module: ModuleScript, net: table)
    --[[

        Registers a module for networking.
        Uses Tessel to establish a structured function map.

    ]]
    Tessel.track(module, net)
end

function RxNet.GetCurrentTesselMap()
    --[[

        Retrieves the current Tessel mapping of all registered modules.
        Uses Mux to fetch the indexed module-function relationships.

    ]]
    return Tessel.GetIndex()
end


--[[

    Finally, Synchronizing Client and Server

]]


return table.freeze(RxNet)
