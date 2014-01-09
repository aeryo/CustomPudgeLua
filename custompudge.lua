if CustomPudge == nil then
  
  PudgeClass = {}
  PudgeClass.__index = PudgeClass
  
  CustomPudge = {}
  CustomPudge.__index = CustomPudge
  
end

function CustomPudge:new (o)
  o = o or {}
  setmetatable(o, self)
  return o
end

-- ****** PUDGECLASS FUNCTIONS START
function PudgeClass.create(playerId)
  local pudge = {}
  setmetatable(pudge,PudgeClass)
  pudge.playerId = playerId
  pudge.hookdamage = 500
  pudge.hookspeed = 1000
  pudge.hooklength = 1500
  pudge.hookType = ""
  pudge.target = nil
  pudge.keepGoing = false
  return pudge
end

function PudgeClass:AddDamage(dmg)
  self.hookdamage = self.hookdamage + dmg
end

function PudgeClass:AddLength(length)
  self.hooklength = self.hooklength + length
end

-- ****** PUDGECLASS FUNCTIONS END

function CustomPudge:_SetInitialValues()
  print("\n\nTest\n\n")
  self.onThink = nil
--  self.thinkState = Dynamic_Wrap( CustomPudge, '_thinkState_Move' )
--  self._scriptBind:BeginThink( "CustomPudgeThinkMove", Dynamic_Wrap( CustomPudge, 'Think' ), 0.25 )
end

-- Called from the addon in charge to initialize this class
function CustomPudge:InitGameMode()
  print("\n\n Pudgewars \n\n")
  PudgeArray = {}
  for i=0, 9 do
    PudgeArray[i] = {}
    PudgeArray[i] = PudgeClass.create(i)
  end
  print('Control, hookdamage: ' .. PudgeArray[0].hookdamage) -- Control that nothing went wrong.
  CustomPudge:_SetInitialValues();
end

function CustomPudge:_thinkState_Move()
    print("working...")
--[[   if moveUnitGrapple then
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
    end --]]
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
 -- keepGoing = true
  targetUnit = keys.target_entities[1]
  casterUnit = keys.caster
  if targetUnit:GetHealth() > nhookdamage then
    targetUnit:SetHealth( targetUnit:GetHealth() -  nhookdamage)
  else
    targetUnit:ForceKill(false)
  end
  if targetUnit:IsAlive() then
    print("IS ALIVE")
  --  moveUnit = true
    print("Started Think")
  else
    print("\n\n IS NOT ALIVE \n\n")
  end
end

function OnThrowHook( keys )
  print("\n\n THROW \n\n")
end
function OnUpgradeHookLength( keys )
  print("\n\nonupgradehook\n\n")
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:AddLength(100)
end

function OnUpgradeHookDamage( keys )
  print("\n\nonupgradehook damage\n\n")
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:AddDamage(100)
end
--EntityFramework:RegisterScriptClass( CustomPudge )