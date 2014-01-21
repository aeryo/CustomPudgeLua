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
  pudge.hooklifesteal = 0
  pudge.lanternpercent = 0
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

function PudgeClass:SetHookLifesteal(lifesteal)
print('running SetLifesteal')
  self.hooklifesteal = lifesteal
 end

function PudgeClass:SetLanternPercent(lantern)
  print('running SetLanternPercent')
  self.lanternpercent = lantern
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

function CustomPudge:_thinkState_Move(frota, dt)
  print("hej" .. dt)
  for i=0, 9 do
    if PudgeArray[i].hookType == 1 then
        local curVec = PudgeArray[i].target:GetOrigin()
        local endVec = PudgeArray[i].caster:GetOrigin()
        if (((curVec.x > endVec.x) and ((curVec.x - 60) <= endVec.x)) or ((curVec.x < endVec.x) and (((curVec.x + 60) >= endVec.x )) and ((curVec.y > endVec.y) and ((curVec.y - 60) <= endVec.y)))) then  
          PudgeArray[i].target:RemoveModifierByName( "modifier_pudge_meat_hook" )
          PudgeArray[i].target:RemoveModifierByName( "change_move_speed" )
          --PudgeArray[i].target:RemoveModifierByName( "modifier_stunned" )
          PudgeArray[i].target:RemoveModifierByName( "modifier_spectre_spectral_dagger_path_phased" )
          PudgeArray[i].target:RemoveModifierByName( "modifier_silence" )
          PudgeArray[i].hookType = 0
        else
          local order =
          {
            UnitIndex =  PudgeArray[i].target:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position =  PudgeArray[i].caster:GetOrigin()
          }
          ExecuteOrderFromTable( order ) 
        end  
    end 
  end
end

function OnHookHit( keys )
  print("\n\n Hook HIT \n\n")
    local targetUnit = keys.target_entities[1]
  local casterUnit = keys.caster
  PudgeArray[ casterUnit:GetPlayerOwnerID() ].caster = casterUnit
  PudgeArray[ casterUnit:GetPlayerOwnerID() ].target = targetUnit
  --targetUnit:SetVelocity(Vec3(200,200,50))  
  
  -- Set move speed to targets move speed.
  local hookab = casterUnit:FindAbilityByName("pudge_meat_hook_holdout")
  print("Name: " .. hookab:GetAbilityName() )
  targetUnit:AddNewModifier( targetUnit, hookab, "modifier_pudge_meat_hook", {} )
  --targetUnit:AddNewModifier( targetUnit, nil, "modifier_stunned", {} )
  targetUnit:AddNewModifier( targetUnit, nil, "modifier_spectre_spectral_dagger_path_phased", {} )
  targetUnit:AddNewModifier( targetUnit, nil, "modifier_silence", {} )
  -- Move the target to pudge
  local order =
  {
    UnitIndex = targetUnit:entindex(),
    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = casterUnit:GetOrigin()
  }
    
  ExecuteOrderFromTable( order )
    
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

function OnUpgradeHookLifesteal1( keys )
  print('running lifesteal upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetHookLifesteal(20)
end
function OnUpgradeHookLifesteal2( keys )
  print('running lifesteal upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetHookLifesteal(25)
end
function OnUpgradeHookLifesteal3( keys )
  print('running lifesteal upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetHookLifesteal(30)
end
function OnUpgradeHookLifesteal4( keys )
  print('running lifesteal upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetHookLifesteal(35)
end
function OnUpgradeHookLifesteal5( keys )
  print('running lifesteal upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetHookLifesteal(40)
end
function OnUpgradeLanternPercentage( keys )
  print('running lantern upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetLanternPercent(25)
end
function OnUpgradeLanternPercentage2( keys )
  print('running lantern upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetLanternPercent(30)
end
function OnUpgradeLanternPercentage3( keys )
  print('running lantern upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetLanternPercent(35)
end
function OnUpgradeLanternPercentage4( keys )
  print('running lantern upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetLanternPercent(40)
end
function OnUpgradeLanternPercentage5( keys )
  print('running lantern upgrade')
  PudgeArray[ keys.caster:GetPlayerOwnerID() ]:SetLanternPercent(45)
end
--EntityFramework:RegisterScriptClass( CustomPudge )