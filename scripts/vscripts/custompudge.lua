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

function CustomPudge:_thinkState_Move()
  print("working...")
  for i=0, 9 do
    if PudgeArray[i].hookType == 1 then
      if hookChainParticle == nil then
        hookChainParticle = ParticleManager:CreateParticle( "pudge_ambient_chain", PATTACH_RENDERORIGIN_FOLLOW, PudgeArray[i].caster )
      end
        local curVec = PudgeArray[i].target:GetOrigin()
        local endVec = PudgeArray[i].caster:GetOrigin()
        ParticleManager:SetParticleControl( hookChainParticle, 1, Vec3( curVec.x, curVec.y, 0.00 ) )
        ParticleManager:SetParticleControl( hookChainParticle, 2, Vec3( endVec.x, endVec.y, 0.00 ) )
        if (((curVec.x > endVec.x) and ((curVec.x - 110) <= endVec.x)) or ((curVec.x < endVec.x) and (((curVec.x + 110) >= endVec.x )) and ((curVec.y > endVec.y) and ((curVec.y - 110) <= endVec.y)))) then  
        PudgeArray[i].target:RemoveModifierByName( "modifier_pudge_meat_hook" )
        ParticleManager:SetParticleControl( hookChainParticle, 1, Vec3( curVec.x, curVec.y, curVec.z ) )
        ParticleManager:SetParticleControl( hookChainParticle, 2, Vec3( curVec.x, curVec.y, curVec.z ) )
        PudgeArray[i].hookType = 0 
        end  
    end 
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

function HandleOrders(order)
  local unit = nil
  if order.UnitIndex then
    unit = EntIndexToHScript(order.UnitIndex)
  end 
  if unit and unit:HasModifier("modifier_pudge_meat_hook") then
    return false
  else return true
  end
end

ExHook:ExecuteOrders(HandleOrders)

function OnHookHit( keys )
  print("\n\n Normal HIT \n\n")
  local targetUnit = keys.target_entities[1]
  local casterUnit = keys.caster
  PudgeArray[ casterUnit:GetPlayerOwnerID() ].caster = casterUnit
  PudgeArray[ casterUnit:GetPlayerOwnerID() ].target = targetUnit
  --targetUnit:SetVelocity(Vec3(200,200,50))  
  
  -- Move the target to pudge
  local order =
  {
    UnitIndex = targetUnit:entindex(),
    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = casterUnit:GetOrigin()
  }
    ExecuteOrderFromTable( order )
 -- PudgeArray[ casterUnit:GetPlayerOwnerID() ].target:AddNewModifier( PudgeArray[ casterUnit:GetPlayerOwnerID() ].target, nil, "modifier_followthrough", modifierTable )
  
  local hooklanterndmg = (PudgeArray[ casterUnit:GetPlayerOwnerID() ].hookspeed - 700) / 100 * PudgeArray[ casterUnit:GetPlayerOwnerID() ].lanternpercent
  local hookdmg = PudgeArray[ casterUnit:GetPlayerOwnerID() ].hookdamage + hooklanterndmg
  if targetUnit:GetHealth() > hookdmg then
  local lifesteal = PudgeArray[ casterUnit:GetPlayerOwnerID() ].hooklifesteal
  targetUnit:SetHealth( targetUnit:GetHealth() - hookdmg)
	casterUnit:SetHealth( casterUnit:GetHealth() + hookdmg / 100 * lifesteal)
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