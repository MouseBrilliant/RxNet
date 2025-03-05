--[[
     ____        _   _      _
    |  _ \ __  _| \ | | ___| |_
    | |_) |\ \/ /  \| |/ _ \ __|
    |  _ <  >  <| |\  |  __/ |_
    |_| \_\/_/\_\_| \_|\___|\__|

    An elegant, fast, networking library for luau

    Author: MouseBrilliant

]]

local Mux = require(script.Parent:WaitForChild("Mux"))

--[[
    _____                  _
    |_   _|__  ___ ___  ___| |
      | |/ _ \/ __/ __|/ _ \ |
      | |  __/\__ \__ \  __/ |
      |_|\___||___/___/\___|_|

    Tracks the structure and functions of modules, mapping them for efficient access.
]]

local Tessel = {}
Tessel.__metatable = newproxy() -- Prevents modification of metatable.

--[[

    Types

]]
export type Tessel = {
    module_location: string, -- Path reference to the module.
    function_map: { [string]: (any...) -> any... }, -- Stores function mappings for the module.
}

export type TesselModule = {
    new: (ModuleScript, table) -> Tessel, -- Constructor for creating a tracked module instance.
}

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

]]


-- Maps Tessel instances to their corresponding Mux handlers.
local MUX_MAP: { [table]: Mux.MuxMap } = {}


function Tessel.new(module: ModuleScript, net: table): Tessel
    --[[

        Creates a new tracked module instance.
        Ensures the module is valid, assigns a path, and initializes a Mux for function tracking.

    ]]
    assert(typeof(module) == "Instance", "--//1: Expected an Instance.")
    assert(module:IsA("ModuleScript"), "--//2: Expected a ModuleScript.")
    assert(typeof(net) == "table", "--//3: Expected a table.")
    assert(not getmetatable(net), "--//4: Table must not already have a metatable.")

    -- Resolve module path
    local location = getModulePath(module)

    -- Setup Tessel tracking
    setmetatable(net, Tessel)
    MUX_MAP[net] = Mux.new(location)
end


function Tessel.__newindex(net: table, key: string?, fn: ((any...) -> any...?)?)
    --[[

        Handles new function assignments to a tracked module.
        Stores the function and updates the Mux mapping for function lookups.

    ]]
    assert(typeof(key) == "string", "--//5: Function key must be a string.")
    assert(typeof(fn) == "function", "--//6: Assigned value must be a function.")

    rawset(net, key, fn) -- Directly assign function to the table.
    MUX_MAP[net]:Add(key, fn) -- Register function in Mux for tracking.
end

return Tessel :: TesselModule
