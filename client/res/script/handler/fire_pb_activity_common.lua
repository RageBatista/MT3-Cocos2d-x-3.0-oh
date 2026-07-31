

-------------------------------------------------------------------------------
--解析签到
local squeryregdata = require "protodef.fire.pb.activity.reg.squeryregdata"

function squeryregdata:process()
	LogInfo("squeryregdata process ")
	LoginRewardManager.getInstance():SetSignInData(self.month, self.times, self.rewardflag, self.suppregtimes, self.suppregdays, self.cansuppregtimes)
end

