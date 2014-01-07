--[[
Frostivus Game Mode

Festive game mode for great fun.
]]

local nHookLength = 0
local keepGoing = true
local targetUnit = nil 
local casterUnit = nil
local moveUnit,moveUnitGrapple = false
local nhookdamage = 100


-- Written like this to allow reloading
if FrostivusGameMode == nil then
  FrostivusGameMode = {}
  FrostivusGameMode.szEntityClassName = "frostivus"
  FrostivusGameMode.szNativeClassName = "dota_base_game_mode"
  FrostivusGameMode.__index = FrostivusGameMode

  -- Preserve this across script reloads
  -- How many guys this round are we respawning right now (to avoid ending early)
  FrostivusGameMode.nExecutingRespawns = 0
  -- How many guys this round have already respawned (to update quest text)
  FrostivusGameMode.nExecutedRespawns = 0
  FrostivusGameMode.bQuestTextDirty = false
end

function FrostivusGameMode:new (o)
  o = o or {}
  setmetatable(o, self)
  return o
end

-- Default settings for regular Dota
local minimapHeroScale = 600
local minimapCreepScale = 1

function FrostivusGameMode:_SetInitialValues()
  nHookLength = 1200
  self.thinkState = Dynamic_Wrap( FrostivusGameMode, '_thinkState_Move' )
  self._scriptBind:BeginThink( "FrostivusThinkMove", Dynamic_Wrap( FrostivusGameMode, 'Think' ), 0.001 )
end

-- Called from C++ to Initialize
function FrostivusGameMode:InitGameMode()
  -- Bind "self" in the callback
  print("\n\n Pudgewars \n\n")
  -- Setup rules
  GameRules:SetHeroRespawnEnabled( false )
  GameRules:SetUseUniversalShopMode( true )
  GameRules:SetSameHeroSelectionEnabled( true )
  GameRules:SetHeroSelectionTime( 0.0 )
  GameRules:SetPreGameTime( 10.0 )
  GameRules:SetPostGameTime( 60.0 )
  GameRules:SetTreeRegrowTime( 60.0 )
  GameRules:SetHeroMinimapIconSize( 400 )
  GameRules:SetCreepMinimapIconScale( 0.7 )
  GameRules:SetRuneMinimapIconScale( 0.7 )
  
  -- Hooks
    ListenToGameEvent('player_connect_full', function(self, keys)
        -- Grab the entity index of this player
        local entIndex = keys.index+1
        local ply = EntIndexToHScript(entIndex)

        -- Find the team with the least players
        local teamSize = {
            [DOTA_TEAM_GOODGUYS] = 0,
            [DOTA_TEAM_BADGUYS] = 0
        }

        for i=0, 9 do
            if Players:IsValidPlayer(i) then
                print('valid player '..i)
                local ply = Players:GetPlayer(i)
                if ply then
                    -- Grab the players team
                    local team = ply:GetTeam()

                    -- Increase the number of players on this players team
                    teamSize[team] = (teamSize[team] or 0) + 1
                end
            end
        end

        if teamSize[DOTA_TEAM_GOODGUYS] > teamSize[DOTA_TEAM_BADGUYS] then
            ply:SetTeam(DOTA_TEAM_BADGUYS)
        else
            ply:SetTeam(DOTA_TEAM_GOODGUYS)
        end
        
        CreateHeroForPlayer('npc_dota_hero_pudge', ply)
        assignHero(ply)                  
    end, self)
    self:_SetInitialValues()  
    self:UpgradeHookLength()
end

function FrostivusGameMode:_thinkState_Move( dt )
    if moveUnitGrapple then
      local endVec = targetUnit:GetOrigin()
      local curVec = casterUnit:GetOrigin()
      local distVec = curVec - endVec
      local tempVec = Vec3(0,0,0)
      local tempVec2 = Vec3(0,0,0)
      local counter = 0
      print(string.format( 'Got vDist X=%d,Y=%d,Z=%d', distVec.x,distVec.y,distVec.z) )
      print(string.format( 'Got Caster curVec X=%d,Y=%d,Z=%d', curVec.x,curVec.y,curVec.z) )
      print(string.format( 'Got Target endVec X=%d,Y=%d,Z=%d', endVec.x,endVec.y,endVec.z) )
      
  
      local v_x = distVec.x
      local v_y = distVec.y
      local v_z = distVec.z
      local vectorLength = math.sqrt(v_x * v_x + v_y * v_y + v_z * v_z)
      print( string.format('DistanceV Length: %d',vectorLength) )
      v_x = v_x / vectorLength
      v_y = v_y / vectorLength
      v_z = v_z / vectorLength    
      tempVec = Vec3(v_x,v_y,v_z)
      print( string.format('DistaceV Normalized X: %f', tempVec.x) )
      keepGoing = true
      while keepGoing do 
        --Move the target
        if curVec ~= endVec then --fix curVec.X also
          if not (((curVec.x > endVec.x) and ((curVec.x - 250) <= endVec.x)) or ((curVec.x < endVec.x) and (((curVec.x + 250) >= endVec.x )) and ((curVec.y > endVec.y) and ((curVec.y - 250) <= endVec.y)))) then
            tempVec2 = curVec - tempVec       
            --tempVec = curVec - distVec
            curVec = tempVec2
            print(string.format( 'Got Caster curVec X=%d,Y=%d,Z=%d', curVec.x,curVec.y,curVec.z) )
            counter = counter + 1
            if counter > 30 then
              keepGoing = false
            end
          else
            keepGoing = false 
            moveUnitGrapple = false
            casterUnit:RemoveModifierByName( "modifier_pudge_meat_hook" )
          end
        else
          keepGoing = false 
          moveUnitGrapple = false
          casterUnit:RemoveModifierByName( "modifier_pudge_meat_hook" )
        end
      
        print( string.format('Moved X=%d', curVec.x) )
        --keepGoing = false
        --vdist = curVec - endVec
      end
      --local veloVec = Vec3(2000,2000,0)
      --targetUnit:SetVelocity( veloVec )
      casterUnit:SetOrigin( curVec )
      print("\n\n Moved Unit Grapple\n\n")
    elseif moveUnit then
      local curVec = targetUnit:GetOrigin()
      local endVec = casterUnit:GetOrigin()
      local distVec = curVec - endVec
      local tempVec = Vec3(0,0,0)
      local tempVec2 = Vec3(0,0,0)
      local counter = 0
      print(string.format( 'Got vDist X=%d,Y=%d,Z=%d', distVec.x,distVec.y,distVec.z) )
      print(string.format( 'Got curVec X=%d,Y=%d,Z=%d', curVec.x,curVec.y,curVec.z) )
      print(string.format( 'Got endVec X=%d,Y=%d,Z=%d', endVec.x,endVec.y,endVec.z) )
      
  
      local v_x = distVec.x
      local v_y = distVec.y
      local v_z = distVec.z
      local vectorLength = math.sqrt(v_x * v_x + v_y * v_y + v_z * v_z)
      print( string.format('DistanceV Length: %d',vectorLength) )
      v_x = v_x / vectorLength
      v_y = v_y / vectorLength
      v_z = v_z / vectorLength    
      tempVec = Vec3(v_x,v_y,v_z)
      print( string.format('DistaceV Normalized X: %f', tempVec.x) )
      keepGoing = true
      while keepGoing do 
        --Move the target
        if curVec ~= endVec then --fix curVec.X also
          if not (((curVec.x > endVec.x) and ((curVec.x - 110) <= endVec.x)) or ((curVec.x < endVec.x) and (((curVec.x + 110) >= endVec.x )) and ((curVec.y > endVec.y) and ((curVec.y - 110) <= endVec.y)))) then
            tempVec2 = curVec - tempVec       
            --tempVec = curVec - distVec
            curVec = tempVec2
            print(string.format( 'Got curVec X=%d,Y=%d,Z=%d', curVec.x,curVec.y,curVec.z) )
            counter = counter + 1
            if counter > 30 then
              keepGoing = false
            end
          else
            keepGoing = false 
            moveUnit = false
            targetUnit:RemoveModifierByName( "modifier_pudge_meat_hook" )
          end
        else
          keepGoing = false 
          moveUnit = false
          targetUnit:RemoveModifierByName( "modifier_pudge_meat_hook" )
        end
      
        print( string.format('Moved X=%d', curVec.x) )
        --keepGoing = false
        --vdist = curVec - endVec
      end
      --local veloVec = Vec3(2000,2000,0)
      --targetUnit:SetVelocity( veloVec )
      targetUnit:SetOrigin( curVec )
      print("\n\n Moved Unit\n\n")
    end
end

function OnGrappleHookHit( keys )
  print("\n\n Grapple HIT \n\n")
  keepGoing = true
  targetUnit = keys.target_entities[1] --check if theres something here....
  casterUnit = keys.caster
 -- if targetUnit:IsAlive() then (check if builde)
    print("IS ALIVE")
    moveUnitGrapple = true
    print("Started Think")
 -- else
 --   print("\n\n IS NOT ALIVE \n\n")
 -- end  
end
function OnHookHit( keys )
  print("\n\n Normal HIT \n\n")
  keepGoing = true
  targetUnit = keys.target_entities[1]
  casterUnit = keys.caster
  if targetUnit:GetHealth() > nhookdamage then
    targetUnit:SetHealth( targetUnit:GetHealth() -  nhookdamage)
  else
    targetUnit:ForceKill(false)
  end
  if targetUnit:IsAlive() then
    print("IS ALIVE")
    moveUnit = true
    print("Started Think")
  else
    print("\n\n IS NOT ALIVE \n\n")
  end
end

function OnThrowHook( keys )
  print("\n\n THROW \n\n")
end

function OnUpgradeHookLength()
  print("\n\nonupgradehook\n\n")
  FrostivusGameMode:UpgradeHookLength()
end

function FrostivusGameMode:UpgradeHookLength()
  nHookLength = nHookLength + 200
  print( string.format( '\n\nHooklength %d\n\n', nHookLength ) )
end

function OnUpgradeHookDamage()
  print("\n\nonupgradehook damage\n\n")
  FrostivusGameMode:UpgradeHookDamage() 
end


function FrostivusGameMode:UpgradeHookDamage()
  nhookdamage = nhookdamage + 100
  print( string.format( '\n\nHookdamage %d\n\n', nhookdamage ) )
end

function FrostivusGameMode:_InitCVars()
  if self.bHasSetCVars then
    return
  end
  self.bHasSetCVars = true
  Convars:SetBool( "dota_winter_ambientfx", true )
  Convars:SetBool( "dota_teamscore_enable", false )
end


-- Think function called from C++, every second.
function FrostivusGameMode:Think()
  -- If the game's over, it's over.
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    self._scriptBind:EndThink( "GameThink" )
    return
  end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()
  if self.t0 == nil then
    self.t0 = now
  end
  local dt = now - self.t0
  self.t0 = now

  self:thinkState( dt )

  -- Think any tombstones...
  for i = #self.vTombstones, 1, -1 do
    local item = self.vTombstones[i]
    if item:IsNull() then
      table.remove( self.vTombstones, i )
    elseif item:GetContainedItem() then
      item:GetContainedItem():Think()
    end
  end
    
  self:_updateItemExpiration()

  self:_roundThink( dt )
end
EntityFramework:RegisterScriptClass( FrostivusGameMode )