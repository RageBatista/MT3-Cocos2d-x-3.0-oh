
LuaBattleUIManager = {}

function LuaBattleUIManager.CreateBattleUI()
	--local TotalDamageDlg = require "logic.battle.totaldamagedlg"
	local RoundCountDlg = require "logic.battle.roundcountdlg"
	local BattlePerCountDownDlg = require "logic.battle.battlepercountdowndlg"
	local UserMiniIconDlg = require "logic.battle.userminiicondlg"
	--TotalDamageDlg.getInstance()
	RoundCountDlg.getInstance()
	BattlePerCountDownDlg.getInstance()
	UserMiniIconDlg:getInstance()
end

function LuaBattleUIManager.DestoryBattleUI()
	--local TotalDamageDlg = require "logic.battle.totaldamagedlg"
	local RoundCountDlg = require "logic.battle.roundcountdlg"
	local BattlePerCountDownDlg = require "logic.battle.battlepercountdowndlg"
	local UserMiniIconDlg = require "logic.battle.userminiicondlg"
	--TotalDamageDlg.DestroyDialog()
	RoundCountDlg.DestroyDialog()
	BattlePerCountDownDlg.DestroyDialog()
	if UserMiniIconDlg:getInstanceOrNot() then
		UserMiniIconDlg:getInstanceOrNot():DestroyDialog()
	end
end

function LuaBattleUIManager.Tick(delta)
	--local TotalDamageDlg = require "logic.battle.totaldamagedlg"
	local RoundCountDlg = require "logic.battle.roundcountdlg"
	local BattlePerCountDownDlg = require "logic.battle.battlepercountdowndlg"
	local UserMiniIconDlg = require "logic.battle.userminiicondlg"
	--if TotalDamageDlg.getInstanceNotCreate() then
		--TotalDamageDlg.getInstanceNotCreate():run(delta)
	--end
	if RoundCountDlg.getInstanceNotCreate() then
		RoundCountDlg.getInstanceNotCreate():run(delta)
	end
	if BattlePerCountDownDlg.getInstanceNotCreate() then
		BattlePerCountDownDlg.getInstanceNotCreate():run(delta)
	end
	if UserMiniIconDlg:getInstanceOrNot() then
		UserMiniIconDlg:getInstanceOrNot():run(delta)
	end

	local BattleAutoFightDlg = require "logic.battleautofightdlg"
	if BattleAutoFightDlg:getInstanceNotCreate() then
		BattleAutoFightDlg:getInstanceNotCreate():run(delta)
	end

	local petOperateDlg = require "logic.pet.petoperatedlg"
	if petOperateDlg.getInstanceNotCreate() then
		petOperateDlg.getInstanceNotCreate():run(delta)
	end
	
    local BattleSkillPanel = require "logic.battle.battleskillpanel"
	if BattleSkillPanel:getInstanceNotCreate() then
		BattleSkillPanel:getInstanceNotCreate():run(delta)
	end
    
    local CharacterOperateDlg = require "logic.battle.characteroperatedlg"
	if CharacterOperateDlg.getInstanceNotCreate() then
		CharacterOperateDlg.getInstanceNotCreate():run(delta)
	end
end

function LuaBattleUIManager.SetTotalDamage(damage)
	--local TotalDamageDlg = require "logic.battle.totaldamagedlg"
	--if TotalDamageDlg.getInstanceNotCreate() then
		--TotalDamageDlg.getInstanceNotCreate():setDamage(damage)
	--end
end

function LuaBattleUIManager.ChangeBattleRound(roundcount)
	local RoundCountDlg = require "logic.battle.roundcountdlg"
	if RoundCountDlg.getInstanceNotCreate() then
		RoundCountDlg.getInstanceNotCreate():changeRoundCount(roundcount)
	end
end

function LuaBattleUIManager.SetOperateTime(time)
	local BattlePerCountDownDlg = require "logic.battle.battlepercountdowndlg"
	if BattlePerCountDownDlg.getInstanceNotCreate() then
		BattlePerCountDownDlg.getInstanceNotCreate():setCount(time)
	end
end

return LuaBattleUIManager
