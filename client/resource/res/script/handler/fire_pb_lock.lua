local p = require "protodef.fire.pb.lock.slockinfo"
function p:process()
	print("slockinfo process".."    " .. self.status)
	require "logic.settingmainframe"
	SettingMainFrame.getInstance():CheckLockHandler(self.status)
end

