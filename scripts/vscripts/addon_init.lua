function Dynamic_Wrap( mt, name )
    if Convars:GetFloat( 'developer' ) == 1 then
        local function w(...) return mt[name](...) end
        return w
    else
        return mt[name]
    end
end

-- Json stuff
require('json')
require('util')
require('frota')
require('gamemodes')

-- Include gamemodes
require('gamemodes/tinywars')
require('gamemodes/pudgewars')

--Pudge wars custom class
require('custompudge')

print("\n\nDone Loading!\n\n")
