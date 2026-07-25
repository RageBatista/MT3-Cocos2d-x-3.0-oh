bingfengwangzuomanager = {
	schoolRankData = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},
	[11] = {},
	[12] = {}
	},
	inBingfeng = false,
    levelInfo = {
        	instzoneid = 0,
			stage = 0,
            autogo = 0,
            finishstage = 0
    }
}
--[[function FubenCodefManager:ClearData()
	self.mapFubenData = {}
	self.nUpdateSpace = 1
	self.nUpdateSpaceDt = 0
	self.mapFubenTable = {}
	self.bInFuben = false
end--]]
----秘境降妖-门派添加
function bingfengwangzuomanager:loadRankData( list )
	self:clear()
	require "protodef.rpcgen.fire.pb.ranklist.bingfengrankdata"
	local sizeof_list = #list
	for i = 1,sizeof_list do
		local row = BingFengRankData:new()
        local _os_ = FireNet.Marshal.OctetsStream:new(list[i])
		row:unmarshal(_os_)
        _os_:delete()
		table.insert(self.schoolRankData[row.shool - 10], row)
	end
end

function bingfengwangzuomanager:clear(  )
	for i=1,12 do
		self.schoolRankData[i] = {}
	end
end

function bingfengwangzuomanager:getRankDataBySchool( school )
	return self.schoolRankData[school - 10]
end

function bingfengwangzuomanager:getRankData( )
	return self.schoolRankData
end

function bingfengwangzuomanager.isInBingfeng(  )
	return bingfengwangzuomanager.inBingfeng
end

function bingfengwangzuomanager.setInBingfeng( isInBingfeng )
	bingfengwangzuomanager.inBingfeng = isInBingfeng
end

function bingfengwangzuomanager:setBingfengInfo(info)
    self.levelInfo.instzoneid = info.instzoneid
    self.levelInfo.finishstage = info.finishstage 
    self.levelInfo.autogo = info.autogo
    self.levelInfo.stage = info.stage
end

function bingfengwangzuomanager:getBingfengInfo()
    return self.levelInfo
end


return bingfengwangzuomanager
