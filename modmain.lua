GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local judge = TUNING.PERISH_FRIDGE_MULT	--获取冰箱回复数值

local function Reperishable(item)	--加新鲜度
    item.components.perishable:ReducePercent(-.05)
end

local function DoReperishable(inst)	--厉遍有perishable组件的物品
	if  inst.components.container ~= nil then
		for k,v in pairs(inst.components.container.slots) do
			if v.components.perishable then
            Reperishable(v)
			end
		end
	end
end

local function modsisturn_R(inst)
	if  inst.components.container ~= nil then
		if not inst:HasTag("fridge") 
			and judge < 0 then	--如果开了回鲜，直接加冰箱标签完事
			inst:AddTag("fridge")
		else	--没有开就这样吧！
			inst:DoPeriodicTask(1, DoReperishable, .05)
		end
	end
end

AddPrefabPostInit("sisturn",modsisturn_R)	--将modsisturn_R传入sisturn这个预制物