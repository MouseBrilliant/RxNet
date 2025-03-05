local SObject = {}
SObject.__index = SObject
-- RxNet:RegisterSharedObject(script,SObject)

function SObject.new()
    local self = setmetatable({},SObject)



    return self
end

return SObject

