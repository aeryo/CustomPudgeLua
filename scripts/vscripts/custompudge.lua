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
  pudge.hookType = 0 -- 1 : normal, 2: grappling
  pudge.target = nil
  pudge.caster = nil
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

  --self.thinkState = Dynamic_Wrap( CustomPudge, '_thinkState_Move' )
  --self._scriptBind:BeginThink( "CustomPudgeThinkMove", Dynamic_Wrap( CustomPudge, 'Think' ), 0.25 )
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
  --for i=0, 9 do
  local i = 0
    if PudgeArray[i].hookType == 1 then 
        local curVec = PudgeArray[i].target:GetOrigin()
        local endVec = PudgeArray[i].caster:GetOrigin()
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
        PudgeArray[i].keepGoing = true
        while PudgeArray[i].keepGoing do 
          --Move the target
          if curVec ~= endVec then --fix curVec.X also
            if not (((curVec.x > endVec.x) and ((curVec.x - 110) <= endVec.x)) or ((curVec.x < endVec.x) and (((curVec.x + 110) >= endVec.x )) and ((curVec.y > endVec.y) and ((curVec.y - 110) <= endVec.y)))) then
              tempVec2 = curVec - tempVec       
              --tempVec = curVec - distVec
              curVec = tempVec2
              print(string.format( 'Got curVec X=%d,Y=%d,Z=%d', curVec.x,curVec.y,curVec.z) )
              counter = counter + 1
              if counter > 40 then
                PudgeArray[i].keepGoing = false
              end
            else
              PudgeArray[i].keepGoing = false 
              PudgeArray[i].hookType = 0
              PudgeArray[i].target:RemoveModifierByName( "modifier_pudge_meat_hook" )
            end
          else
            PudgeArray[i].keepGoing = false 
            PudgeArray[i].hookType = 0
            PudgeArray[i].target:RemoveModifierByName( "modifier_pudge_meat_hook" )
          end
        
          print( string.format('Moved X=%d', curVec.x) )
          --keepGoing = false
          --vdist = curVec - endVec
        end
        --local veloVec = Vec3(2000,2000,0)
        --targetUnit:SetVelocity( veloVec )
        PudgeArray[i].target:SetOrigin( curVec )
        print("\n\n Moved Unit\n\n")     
    end 
  --end
  FireGameEvent( "dragtarget", {} )
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
  local targetUnit = keys.target_entities[1]
  local casterUnit = keys.caster
  PudgeArray[ casterUnit:GetPlayerOwnerID() ].caster = casterUnit
  PudgeArray[ casterUnit:GetPlayerOwnerID() ].target = targetUnit
  
  local modifierTable =
  {
    target = "TARGET",
    caster =  "CASTER"
  }
  
 -- PudgeArray[ casterUnit:GetPlayerOwnerID() ].target:AddNewModifier( PudgeArray[ casterUnit:GetPlayerOwnerID() ].target, nil, "modifier_followthrough", modifierTable )
  
  if targetUnit:GetHealth() > PudgeArray[ casterUnit:GetPlayerOwnerID() ].hookdamage then
    targetUnit:SetHealth( targetUnit:GetHealth() -  PudgeArray[ casterUnit:GetPlayerOwnerID() ].hookdamage)
  else
    targetUnit:ForceKill(false)
  end
  if targetUnit:IsAlive() then
    print("IS ALIVE")
    PudgeArray[ casterUnit:GetPlayerOwnerID() ].hookType = 1
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