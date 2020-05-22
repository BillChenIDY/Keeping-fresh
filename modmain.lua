GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

--[[
local isWorldDay = TheWorld.state.isday or TheWorld.state.iscaveday	--白天
local isWorldNight = TheWorld.state.isnight or TheWorld.state.iscavenight	--夜晚
local isWorldWinter = TheWorld.state.iswinter	--冬
local isWorldSummer = TheWorld.state.summer	--夏
local isWorldRaining = TheWorld.state.israining	--雨天
local isWorldSnowing = TheWorld.state.issnowing	--下雪
local isWorldFullmoon = TheWorld.state.isfullmoon or TheWorld.state.cavephase	--满月
local isWorldNewmoon = TheWorld.state.isnewmoon	--新月
]]
local evliGarden = GetModConfigData("evliGarden")
local evilDifficulty = GetModConfigData("Difficulty")
local containers = require "containers"
local params = {}
PrefabFiles = {
	"newsisturnfx"
}

Assets = {
	Asset("ANIM", "anim/new_sisturn_build.zip"),
	Asset("ANIM", "anim/new_shadowhandfx.zip"),
}

if evliGarden then
	params.sisturn =
	{
		widget =
		{
			slotpos =
			{
				Vector3(-37.5, 32 + 4, 0), 
				Vector3(37.5, 32 + 4, 0),
				Vector3(-37.5, -(32 + 4), 0), 
				Vector3(37.5, -(32 + 4), 0),
			},
			slotbg =
			{
				{ image = "sisturn_slot_petals.tex" },
				{ image = "sisturn_slot_petals.tex" },
				{ image = "sisturn_slot_petals.tex" },
				{ image = "sisturn_slot_petals.tex" },
			},
			animbank = "ui_chest_2x2",
			animbuild = "ui_chest_2x2",
			pos = Vector3(200, 0, 0),
			side_align_tip = 120,
		},
		acceptsstacks = false,
		type = "cooker",
	}

	function params.sisturn.itemtestfn(container, item, slot)
		if evilDifficulty then
			return item.prefab == "petals" or item.prefab == "petals_evil" or item.prefab == "nightmarefuel" or item.prefab == "purplegem" or item.prefab == "shadowheart"
		else
			return item.prefab == "petals" or item.prefab == "petals_evil" or item.prefab == "nightmarefuel" or item.prefab == "ghostflower"
		end
	end
end

------------------------------------------------------

-----------------谢谢恒子大佬的指导！-----------------

if evliGarden then
	containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.sisturn.widget.slotpos ~= nil and #params.sisturn.widget.slotpos or 0)

	local containers_widgetsetup = containers.widgetsetup

	function containers.widgetsetup(container, prefab, data)
		local t = prefab or container.inst.prefab
		if t=="sisturn" then
			local t = params[t]
			if t ~= nil then
				for k, v in pairs(t) do
					container[k] = v
				end
				container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
			end
		else
			return containers_widgetsetup(container, prefab, data)
		end
	end
end

--------------------------------------------------------------------------------------

local function newIsFullOfFlowers(inst)	--是否满了
	if inst ~= nil then
		return inst.components.container ~= nil and inst.components.container:IsFull()
	else
		return false
	end
end

local function newIsEmptyOfFlowers(inst)	--是否空了
	if inst ~= nil then
		return inst.components.container ~= nil and inst.components.container:IsEmpty()
	else
		return false
	end
end

local function checkSisturnItem(inst)	--检查内容物
	if inst.components.container ~= nil and evilDifficulty then
		return inst.components.container:Has("nightmarefuel", 2) and inst.components.container:Has("purplegem", 1) and inst.components.container:Has("shadowheart", 1)
	elseif inst.components.container ~= nil and not evilDifficulty then
		return inst.components.container:Has("nightmarefuel", 2) and  inst.components.container:Has("ghostflower", 2)
	else
		return false
	end
end

local function inWorldNightFn(isnt)	--世界是晚上
	return TheWorld.state.isnight
end

local function inWorldDay(inst)	--世界不在晚上
	return TheWorld.state.isday
end

local function expendMaterial(inst)	--消耗物品
	if evilDifficulty then
		inst.components.container:ConsumeByName("purplegem", 1)
		inst.components.container:ConsumeByName("nightmarefuel", 2)
	else
		inst.components.container:DestroyContents()
	end
end

local function resetAnim(inst)	--重新设置build
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:SetBuild("new_sisturn_build")
	inst:DoTaskInTime(1, inst.AnimState:PushAnimation("on", true))
end

local function setSisturnAnimState(inst)
	if newIsFullOfFlowers and checkSisturnItem then
		local getPos = inst:GetPosition()
		local fx = SpawnPrefab("newsisturnfx")
		if getPos ~= nil then
			fx.Transform:SetPosition(getPos:Get())
			inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
			inst.components.container:Close()
			inst:DoTaskInTime(1.5, resetAnim)
		end
		if not inst:HasTag("sisturnfull") then
				inst:AddTag("sisturnfull")
		end
	end
end

local function returnVal(inst)	--设置数据
	if inst.components.container:Has("petals", 4) then
		return 1
	elseif inst.components.container:Has("petals_evil", 4) then
		setSisturnAnimState(inst)
		return -1
	elseif inst.components.container:Has("nightmarefuel", 4) or checkSisturnItem(inst) then
		setSisturnAnimState(inst)
		return -2
	elseif inst.components.container:Has("shadowheart", 4) or inst.components.container:Has("ghostflower", 4) then
		setSisturnAnimState(inst)
		return -4
	else 
		return 0
	end
end

local function stopSpawn(inst)	--停止生成
	if newIsFullOfFlowers(inst) and checkSisturnItem(inst) and not inst.components.container.canbeopened and not inst:HasTag("burnt") then
		expendMaterial(inst)	--消耗物品
		inst.AnimState:PlayAnimation("on_pst")
		inst.AnimState:PushAnimation("idle", false)
		inst.SoundEmitter:KillSound("sisturn_on")
		if inst.components.workable == nil then	--添加组件
			inst:AddComponent("workable")
			inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
			inst.components.workable:SetWorkLeft(4)
			--
			inst.components.workable:SetOnFinishCallback(function ()
				inst.components.lootdropper:DropLoot()
				if inst.components.container ~= nil then
					inst.components.container:DropEverything()
				end
				
				local fx = SpawnPrefab("collapse_small")
				fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
				fx:SetMaterial("wood")
				inst:Remove()
			end)
			--
			inst.components.workable:SetOnWorkCallback(function (inst, worker, workleft)
				if workleft > 0 and not inst:HasTag("burnt") then
				inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/hit")
				inst.AnimState:PlayAnimation("hit")
				inst.AnimState:PushAnimation("idle")
					if inst.components.container ~= nil then
						inst.components.container:DropEverything()
					end
				end
			end)
			--
		end
		if inst.components.container ~= nil then
			inst.components.container.canbeopened = true
		end--容器可开启
		
	end
	--inst:RemoveEventCallback("isSisturnNight", isSisturnNight)
	inst:CancelAllPendingTasks()
	--print("执行stopSpawn")
	return false
end

local function addNightmarefuel(inst)	--生成恶魔花
	if newIsFullOfFlowers(inst) and checkSisturnItem(inst) and inWorldNightFn(inst) and not inWorldDay(inst) and not inst:HasTag("burnt") then
		local sisturnPos = inst:GetPosition()
		local theta = math.random() * 2 * PI
        local radius = math.random(1.5, 6)
		local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                        local pos = sisturnPos + offset
                        --NOTE: The first search includes invisible entities
                        return #TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, { "INLIMBO", "FX" }) <= 0
                            and TheWorld.Map:IsPassableAtPoint(pos:Get())
							and TheWorld.Map:IsDeployPointClear(pos, nil, 1)
                    end)
		if result_offset ~= nil then
            local x, z = sisturnPos.x + result_offset.x, sisturnPos.z + result_offset.z
			if math.random() < .05 and evilDifficulty then
				local nightmare = SpawnPrefab(math.random() < .5 and "crawlingnightmare" or "nightmarebeak")
				nightmare.Transform:SetPosition(x, 0, z)
				SpawnPrefab("explode_reskin").Transform:SetPosition(x, 0, z)
			else
				local nFuel = SpawnPrefab("flower_evil")
				nFuel.Transform:SetPosition(x, 0, z)
				--SpawnPrefab("sand_puff").Transform:SetPosition(x, 0, z)
				SpawnPrefab("shadow_puff").Transform:SetPosition(x, 0, z)
			end
		end
		return true
	else
		if checkSisturnItem(inst) and not inst.components.container.canbeopened then
			stopSpawn(inst)
		end
		return false
	end
end

local function starSpawnEvilFn(inst)	--控制生成恶魔花的函数
	if checkSisturnItem(inst) and TheWorld.state.isnight and not inst:HasTag("burnt") then
		if evilDifficulty then
			inst:DoPeriodicTask(3, addNightmarefuel, 3)	--满足条件执行
			else
			inst:DoPeriodicTask(1, addNightmarefuel, 1)
		end
		inst:DoTaskInTime(480, stopSpawn)
		if inst.components.container ~= nil then
			inst.components.container.canbeopened = false	--无法开启箱子
			inst.components.container:Close()	--如果有玩家正在使用将会强行关闭
			--print("执行无法打开成功")
		end
		if inst.components.workable ~= nil then	--移除工作组件，避免玩家在快要天亮时敲击建筑来刷相应物品，这样就算下流星雨也没事（滑稽）
			inst:RemoveComponent("workable")
			--print("执行去除组件成功")
		end
		--print("执行isSisturnNight成功")
	--else
		--print("执行isSisturnNight失败")
	end
end

local function isSisturnNight(inst)
	starSpawnEvilFn(inst)
	TheWorld:PushEvent("ms_isSisturnNight", {inst = inst,  is_night = newIsFullOfFlowers(inst)})
end

local function updateEvilSaityaura(inst)
	if newIsFullOfFlowers(inst) then
		local val = returnVal(inst)
		local constant= TUNING.SANITYAURA_SMALL
		if inst.components.sanityaura == nil then
			inst:AddComponent("sanityaura")
		end
		if checkSisturnItem(inst) then
			inst:ListenForEvent("isSisturnNight", isSisturnNight)
		end
		if val ~= 0 and not val == 1 then 
			setSisturnAnimState(inst)
		end
		if val ~= nil then
			inst.components.sanityaura.aura = constant * val
		end
		--print(val)
	end
end

local function loseItem(inst)
	updateEvilSaityaura(inst)
	if inst:HasTag("sisturnfull") then
		inst:RemoveTag("sisturnfull")
		inst.AnimState:SetBuild("sisturn")
		--inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
		local getPos = inst:GetPosition()
		local fx = SpawnPrefab("attune_ghost_in_fx")
		fx.Transform:SetPosition(getPos:Get())
	end
	TheWorld:PushEvent("ms_itemCheckIsFull", {inst = inst, is_active = newIsFullOfFlowers(inst)})
	--print("执行loseItem")
end

local function addItem(inst)
	updateEvilSaityaura(inst)
	if checkSisturnItem(inst) then	--尝试执行
		starSpawnEvilFn(inst)
	end
	TheWorld:PushEvent("ms_itemCheckIsFull", {inst = inst, is_active = newIsFullOfFlowers(inst)})
end

local function watchStateNight(inst)
	inst:WatchWorldState("isnight", isSisturnNight)
end

local function watchWorldState(inst)
	watchStateNight(inst)
	inst:ListenForEvent("itemget", addItem)
	inst:ListenForEvent("itemlose", loseItem)
end
--------------------------------------------------------------------------

local function refreshesModSisturn(inst)	--保鲜及反鲜
	if GetModConfigData("Val") == true then	--如果需要单独反鲜的话
		if inst.components.preserver == nil and not inst:HasTag("burnt") then
			inst:AddComponent("preserver")
				if TUNING.PERISH_FRIDGE_MULT < 0 then
					inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_FRIDGE_MULT)
				else
					inst.components.preserver:SetPerishRateMultiplier(-TUNING.PERISH_FRIDGE_MULT)
				end
		end
	else
		if inst.components.preserver == nil and not inst:HasTag("burnt") then
			inst:AddComponent("preserver")
			inst.components.preserver:SetPerishRateMultiplier(0)
		end
	end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
		end
    end
end

local function newSisturn(inst)
	refreshesModSisturn(inst)
	if evliGarden then
		watchWorldState(inst)
	end
	inst.OnSave = onsave
    inst.OnLoad = onload
end

AddPrefabPostInit("sisturn", newSisturn)