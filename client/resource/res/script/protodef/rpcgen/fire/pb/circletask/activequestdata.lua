require "utils.tableutil"
require "protodef.rpcgen.fire.pb.circletask.rewarditemunit"
ActiveQuestData = {}
ActiveQuestData.__index = ActiveQuestData


function ActiveQuestData:new()
	local self = {}
	setmetatable(self, ActiveQuestData)
	self.questid = 0
	self.queststate = 0
	self.dstnpckey = 0
	self.dstnpcid = 0
	self.dstmapid = 0
	self.dstx = 0
	self.dsty = 0
	self.dstitemid = 0
	self.sumnum = 0
	self.npcname = "" 
	self.rewardexp = 0
	self.rewardmoney = 0
	self.rewardsmoney = 0
	self.rewarditems = {}

	return self
end
function ActiveQuestData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int32(self.queststate)
	_os_:marshal_int64(self.dstnpckey)
	_os_:marshal_int32(self.dstnpcid)
	_os_:marshal_int32(self.dstmapid)
	_os_:marshal_int32(self.dstx)
	_os_:marshal_int32(self.dsty)
	_os_:marshal_int32(self.dstitemid)
	_os_:marshal_int32(self.sumnum)
	_os_:marshal_wstring(self.npcname)
	_os_:marshal_int64(self.rewardexp)
	_os_:marshal_int64(self.rewardmoney)
	_os_:marshal_int64(self.rewardsmoney)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.rewarditems))
	for k,v in ipairs(self.rewarditems) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function ActiveQuestData:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.queststate = _os_:unmarshal_int32()
	self.dstnpckey = _os_:unmarshal_int64()
	self.dstnpcid = _os_:unmarshal_int32()
	self.dstmapid = _os_:unmarshal_int32()
	self.dstx = _os_:unmarshal_int32()
	self.dsty = _os_:unmarshal_int32()
	self.dstitemid = _os_:unmarshal_int32()
	self.sumnum = _os_:unmarshal_int32()
	self.npcname = _os_:unmarshal_wstring(self.npcname)
	self.rewardexp = _os_:unmarshal_int64()
	self.rewardmoney = _os_:unmarshal_int64()
	self.rewardsmoney = _os_:unmarshal_int64()
	----------------unmarshal vector
	local sizeof_rewarditems=0,_os_null_rewarditems
	_os_null_rewarditems, sizeof_rewarditems = _os_: uncompact_uint32(sizeof_rewarditems)
	for k = 1,sizeof_rewarditems do
		----------------unmarshal bean
		self.rewarditems[k]=RewardItemUnit:new()

		self.rewarditems[k]:unmarshal(_os_)

	end
	return _os_
end

return ActiveQuestData
