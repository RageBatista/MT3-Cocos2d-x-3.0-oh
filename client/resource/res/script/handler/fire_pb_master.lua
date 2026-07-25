g_shitu_flag = 0 --0 none  1 tudi  2shifu
local snotifymaster = require "protodef.fire.pb.master.snotifymaster"
function snotifymaster:process()
  LogInfo("snotifymaster process")
  g_shitu_flag = self.flag
end

local sprenticeslist = require "protodef.fire.pb.master.sprenticeslist"
function sprenticeslist:process()
  LogInfo("sprenticeslist process")
  
  local _ins = require "logic.shitu.shitulianxindlg".getInstanceNotCreate()
  if _ins then
    _ins:SetData(self)
  end
end

local stakeachivefresh = require "protodef.fire.pb.master.stakeachivefresh"
function stakeachivefresh:process()
  LogInfo("stakeachivefresh process")
  
  local _ins = require "logic.shitu.shitulianxindlg".getInstanceNotCreate()
  if _ins then
    _ins:SetAchiveFresh(self)
  end
end
