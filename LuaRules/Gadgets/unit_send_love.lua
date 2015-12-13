function gadget:GetInfo()
   return {
      name      = "Send Love",
      desc      = "Send love mechanics (healing friendly trees)",
      author    = "gajop",
      date      = "December 2015", 
      license   = "GNU GPL, v2 or later",
      layer     = 0,
      enabled   = true
   }
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local weaponName = "zap"
local zapWDID = WeaponDefNames[weaponName] and WeaponDefNames[weaponName].id or nil

local watchedProjectiles = {}
local tempUnits = {}

function gadget:Initialize()
    if zapWDID or (not TESTING_MODE) then
        Script.SetWatchWeapon(zapWDID, true)    
    else
        Spring.Echo("Warning: Could not find Zap Weapon")
    end
end

function gadget:Shutdown()
    Script.SetWatchWeapon(zapWDID, false)
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
    if weaponDefID == zapWDID then 
        watchedProjectiles[proID] = true
    end
end

function gadget:ProjectileDestroyed(proID)
    if watchedProjectiles[proID] then
        local px,py,pz = Spring.GetProjectilePosition(proID)
        local gy = Spring.GetGroundHeight(px,pz)
		local frame = Spring.GetGameFrame()
        if math.abs(py-gy)<5 then
			local units = GG.SpawnFlowers(px, pz, 2, 2, 300)
			local units2 = GG.SpawnGrass(px, pz, 2, 2, 300)
			for _, unitID in pairs(units) do
				table.insert(tempUnits, {unitID = unitID, frame = frame + 33*5})
			end
			for _, unitID in pairs(units2) do
				table.insert(tempUnits, {unitID = unitID, frame = frame + 33*5})
			end
        end
    end
end

function gadget:GameFrame(frame)
	for i = #tempUnits, 1, -1 do
		local unit = tempUnits[i]
		if unit.frame <= frame then
			Spring.DestroyUnit(unit.unitID)
			table.remove(tempUnits, i)
		end
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if weaponDefID == zapWDID then
		local unitDef = UnitDefs[unitDefID]
		if not unitDef.customParams.mushroom then
			return -damage, 1.0
		end
	end
    return damage, 1.0
end