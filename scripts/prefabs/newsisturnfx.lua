local assets =
{
    Asset("ANIM", "anim/scarecrow.zip"),
    Asset("ANIM", "anim/shadow_skinchangefx.zip"),
	Asset("ANIM", "anim/new_shadowhandfx.zip"),
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.AnimState:SetBank("scarecrow")
	inst.AnimState:SetBuild("new_shadowhandfx")
	inst.AnimState:PlayAnimation("transform")
	
	inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
    inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
    inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")
	
	if not TheNet:GetIsServer() then
        return inst
    end
	inst:ListenForEvent("animover", inst.Remove)
	
	return inst
end

return Prefab("newsisturnfx", fn, assets, prefabs)