GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
local Vale = GetModConfigData("Val")

local judge = TUNING.PERISH_FRIDGE_MULT	--获取冰箱的保鲜数值

local function DoReperishable(inst)	
	if  inst.components.container ~= nil then
		for k,v in pairs(inst.components.container.slots) do	--遍历有perishable组件的物品
			if v.components.perishable then
				v.components.perishable:ReducePercent(-.05)	--加新鲜度
			end
		end
	end
end

local function modsisturn_R(inst)
	if inst.components.container ~= nil then	--检测是否有这个组件
		if not inst:HasTag("fridge")	--检测是否有这个标签，避免报错
			and judge < 0 then	--如果开了回鲜，直接加冰箱标签完事
			inst:AddTag("fridge")
		elseif Vale == true then	--如果需要单独反鲜的话
			inst:DoPeriodicTask(1, DoReperishable, .05)	
		else
			inst:AddComponent("preserver")
			inst.components.preserver:SetPerishRateMultiplier(0)
		end
	end
end

AddPrefabPostInit("sisturn",modsisturn_R)	--将modsisturn_R传入sisturn这个预制物