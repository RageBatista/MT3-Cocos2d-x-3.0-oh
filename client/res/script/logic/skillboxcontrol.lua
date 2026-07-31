
SkillBoxControl = {}
function SkillBoxControl.GetSkillNamebyID(skillid)
    local skilltype = gGetSkillTypeByID(skillid);

	if skilltype == eSkillType_Normal or skilltype == eSkillType_Other or skilltype == eSkillType_Marry then
		local skillItem = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillid);
		if skillItem == nil then
			return L"";
		else
			return skillItem.skillname;
        end
	elseif skilltype == eSkillType_Pet then
		local skillItem = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid);
		if skillItem == nil then
			return L"";
		else
			return skillItem.skillname;
        end
	elseif skilltype == eSkillType_Life then
		local Lifeskill = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(skillid);
		if Lifeskill == nil then
			return L"";
		else
			return Lifeskill.name;
        end
	elseif skilltype ==  eSkillType_Equip then
		local equipskill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(skillid);
		if equipskill == nil then
			return L"";
		else
			return equipskill.name;
        end
	elseif skilltype == eSkillType_ZaXue then
		return L"";
	end
	return L"";
end

function SkillBoxControl.SetBuffInfo(skillBox, id, duedate)
	if skillBox == nil then
		return
	end

	skillBox:SetSkillID(id)
	skillBox:SetSkillDueDate(duedate)

	local buffconfig = GameTable.buff.GetCBuffConfigTableInstance():getRecorder(id)
	skillBox:SetImage(gGetIconManager():GetBuffIconByID(buffconfig.shapeid))
	skillBox:setTooltipText("")
end


function SkillBoxControl.SetSkillInfo(skillBox, id, duedate)
	if skillBox == nil then
		return
	end

	skillBox:SetSkillID(id)
	skillBox:SetSkillDueDate(duedate)

	local skillicon = RoleSkillManager.GetSkillIconByID(id)
	if skillicon ~= 0 then
		skillBox:SetImage(gGetIconManager():GetSkillIconByID(skillicon))
	end

	skillBox:setTooltipText("")
end

function SkillBoxControl.ClearSkillInfo(skillBox, bLock)
	if skillBox == nil then
		return
	end
	skillBox:SetSkillID(0)
	skillBox:SetSkillDueDate(0)

	if bLock then
		skillBox:SetImage("common", "common_biaoshi_cc")
		skillBox:setTooltipText(GameTable.message.GetCMessageTipTableInstance():getRecorder(142282).msg)
	else
		skillBox:SetImage(0)
		skillBox:setTooltipText("")
	end
end

return ShowHide
