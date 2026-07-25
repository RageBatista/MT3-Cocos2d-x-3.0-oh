local p = require "protodef.fire.pb.item.sallequipscore"
function p:process()
end

p = require "protodef.fire.pb.lock.sneedunlock"
function p:process()
	print("sneedunlock process")
end

p = require "protodef.fire.pb.lock.saddlocksuc"
function p:process()
end

p = require "protodef.fire.pb.lock.sunlocksuc"
function p:process()
	print("SUnlockSuc process")
end

p = require "protodef.fire.pb.lock.scancellocksuc"
function p:process()
	print("SCancelLockSuc process")
end

p = require "protodef.fire.pb.lock.sunlocksuc"
function p:process()
	print("SUnlockSuc process")
end

p = require "protodef.fire.pb.lock.sforceunlocksuc"
function p:process()
	print("SForceUnlockSuc process")
end

p = require "protodef.fire.pb.lock.schangepasswordsuc"
function p:process()
	print("SChangePasswordSuc process")
end

p = require "protodef.fire.pb.lock.supdatelockinfo"
function p:process()
end

p = require "protodef.fire.pb.item.sopenpack"
function p:process()
end

p = require "protodef.fire.pb.master.sevaluate"
function p:process()
end

p = require "protodef.fire.pb.master.snotifydismissmaster"
function p:process()
end

p = require "protodef.fire.pb.master.sdismissapprentces"
function p:process()
end

p = require "protodef.fire.pb.master.snotifyappmaster"
function p:process()
end

p = require "protodef.fire.pb.hook.srefreshrolehookdata"
function p:process()
	require "logic.mapchose.mapchosedlg"
	require "logic.mapchose.hookmanger"
end

p = require "protodef.fire.pb.fushi.srspserverid"
function p:process()
    require "logic.chargedialog"
end

p = require "protodef.fire.pb.pet.spetgossip"
function p:process()
end

p = require "protodef.fire.pb.move.sroleplayaction"
function p:process()
end

p = require "protodef.fire.pb.move.srolechangeshape"
function p:process()
end

p = require "protodef.fire.pb.move.srolemodelchange"
function p:process()
end

p = require "protodef.fire.pb.move.sbeginbaitang"
function p:process()
end

p = require "protodef.fire.pb.move.srolejumpdrawback"
function p:process()
end

p = require "protodef.fire.pb.move.srolestop"
function p:process()
end

p = require "protodef.fire.pb.move.srolejump"
function p:process()
end

p = require "protodef.fire.pb.npc.svisitnpccontainchatmsg"
function p:process()
end

p = require "protodef.fire.pb.skill.supdateassistskill"
function p:process()
end

p = require "protodef.fire.pb.friends.schangebaseconfig"
function p:process()
end

p = require "protodef.fire.pb.gm.sgmcheckroleid"
function p:process()
end

p = require "protodef.fire.pb.gm.scheckgm"
function p:process()
end

p = require "protodef.fire.pb.sretroleprop"
function p:process()
end

p = require "protodef.fire.pb.sbeginnertip"
function p:process()
end

p = require "protodef.fire.pb.sreturnrolelist"
function p:process()
end

p = require "protodef.fire.pb.sroleoffline"
function p:process()
end

p = require "protodef.fire.pb.sfirstdayexitgame"
function p:process()
end

p = require "protodef.fire.pb.ssendloginip"
function p:process()
end

p = require "protodef.fire.pb.master.sregmaster"
function p:process()
end

local p = require "protodef.fire.pb.master.sreadyregmaster"
function p:process()
end

p = require "protodef.fire.pb.master.ssearchmaster"
function p:process()
end

p = require "protodef.fire.pb.master.srequestasapprentice"
function p:process()
end

p = require "protodef.fire.pb.master.srequestprenticesuccess"
function p:process()
end

p = require "protodef.fire.pb.master.scanacceptprentice"
function p:process()
end

p = require "protodef.fire.pb.master.ssearchprentice"
function p:process()
end

p = require "protodef.fire.pb.master.smasterprenticedata"
function p:process()
end

p = require "protodef.fire.pb.master.sdissolverelation"
function p:process()
end

p = require "protodef.fire.pb.master.spreviousmasters"
function p:process()
end

p = require "protodef.fire.pb.master.sprenticelist"
function p:process()
end

p = require "protodef.fire.pb.master.sreceivenewprentice"
function p:process()
end

p = require "protodef.fire.pb.master.srequestasmaster"
function p:process()
end

p = require "protodef.fire.pb.master.sinitprenticelist"
function p:process()
end

p = require "protodef.fire.pb.master.scanrequestasprentice"
function p:process()
end

local p = require "protodef.fire.pb.master.scanrequestasmaster"
function p:process()
end

p = require "protodef.fire.pb.master.scantrequestasprentice"
function p:process()
end

p = require "protodef.fire.pb.master.scantrequestasmaster"
function p:process()
end

p = require "protodef.fire.pb.master.ssendmasterprenticelist"
function p:process()
end

p = require "protodef.fire.pb.master.saddpreprentice"
function p:process()
end

p = require "protodef.fire.pb.master.ssendprenticeonlinestate"
function p:process()
end

local p = require "protodef.fire.pb.move.saddactivitynpc"
function p:process()
end

p = require "protodef.fire.pb.move.sremoveactivitynpc"
function p:process()
end

local p = require "protodef.fire.pb.move.sgmgetaroundroles"
function p:process()
end

p = require "protodef.fire.pb.move.schangeequipeffect"
function p:process()
end

p = require "protodef.fire.pb.npc.sbattletonpcerror"
function p:process()
end

p = require "protodef.fire.pb.pet.sshowpetinfo"
function p:process()
end

p = require "protodef.fire.pb.product.serrorcode"
function p:process()
end

p = require "protodef.fire.pb.ranklist.ssendrankpetdata"
function p:process()
end

p = require "protodef.fire.pb.school.ssendshouxiinfo"
function p:process()
end

p = require "protodef.fire.pb.skill.sskillerror"
function p:process()
end

p = require "protodef.fire.pb.circletask.squestionnairetitleandexp"
function p:process()
end

p = require "protodef.fire.pb.title.stitleerr"
function p:process()
end

p = require "protodef.fire.pb.team.ssetteamstate"
function p:process()
end


p = require "protodef.fire.pb.team.srequestjoinsucc"
function p:process()
end

p = require "protodef.fire.pb.team.ssetteamlevel"
function p:process()
end

p = require "protodef.fire.pb.team.srequestsetleadersucc"
function p:process()
end

p = require "protodef.fire.pb.battle.ssendpetinitattrs"
function p:process()
end

local protoNames = {
"protodef.fire.pb.team.ssendsinglecharacterlist",
}

for _,name in pairs(protoNames) do
	p = require(name)
	p.process = function() end
end