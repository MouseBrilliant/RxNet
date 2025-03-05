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

    Provides a high-level API for registering networked modules
    and retrieving the current module-function mappings.

]]

local Tessel = require(script:WaitForChild("Tessel"))
local Mux = require(script:WaitForChild("Mux"))

--[[

    RxNet Type Definition

]]

export type RxNet = {
    Register: (ModuleScript, table) -> nil, -- Registers a module for networking.
    GetCurrentTesselMap: () -> { [string]: Tessel.Tessel }, -- Retrieves the current mapped modules.
}

--[[

    RxNet

]]

local RxNet = {}

function RxNet.Register(module: ModuleScript, net: table)
    --[[

        Registers a module for networking.
        Uses Tessel to establish a structured function map.

    ]]
    Tessel.new(module, net)
end

function RxNet.GetCurrentTesselMap()
    --[[

        Retrieves the current Tessel mapping of all registered modules.
        Uses Mux to fetch the indexed module-function relationships.

    ]]
    return Mux.getIndex()
end

function RxNet.GetCurrentCantorIndex()
    return Mux.getCantorIndex()
end

--[[

    Finalizing RxNet:
    Freezes the module to prevent modifications.

]]

return table.freeze(RxNet)
