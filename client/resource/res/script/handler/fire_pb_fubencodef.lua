local p = require "protodef.fire.pb.mission.sgetlinestate"
function p:process()
	require "logic.fubencodef.fubencodefmanager":initData(self.instances)
	local dlg = require "logic.fubencodef.fubencodef".getInstance()
end

local p = require "protodef.fire.pb.instancezone.bingfeng.sgetbingfengdetail"
function p:process( )
	local dlg = require "logic.bingfengwangzuo.bingfengwangzuoTips".getInstanceNotCreate()
    if dlg then
	    dlg:refreshData(self.rolename, self.usetime, self.stagestate, self.myusetime)
    end
end

local p = require "protodef.fire.pb.mission.sanswerinstance"
function p:process()
    local dlg = require "logic.fuben.fubenEnterDlg".getInstanceNotCreate()
    if dlg then
        dlg:refreshMemberInfo(self.roleid, self.answer)
    end
end
local p = require "protodef.fire.pb.instancezone.sgonghuifubenlasttime"
function p:process()
    local dlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
    if dlg then
        dlg.m_timeFordungeon = self.lasttime
    end
end

local p = require "protodef.fire.pb.mission.sdefineteam"
function p:process()
    Taskhelperprotocol.sdefineteam_process(self)
end

local p = require "protodef.fire.pb.mission.sdropinstance"
function p:process()
    Taskhelperprotocol.sdropinstance_process(self)
end