require "utils.tableutil"
SGetRecruitAward = {}
SGetRecruitAward.__index = SGetRecruitAward



SGetRecruitAward.PROTOCOL_TYPE = 806663

function SGetRecruitAward.Create()
	print("enter SGetRecruitAward create")
	return SGetRecruitAward:new()
end
function SGetRecruitAward:new()
	local self = {}
	setmetatable(self, SGetRecruitAward)
	self.type = self.PROTOCOL_TYPE
	self.result = 0
	self.awardtype = 0
	self.awardid = 0
	self.recruitrole = 0
	self.recruitserver = "" 

	return self
end
function SGetRecruitAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetRecruitAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	_os_:marshal_int32(self.awardtype)
	_os_:marshal_int32(self.awardid)
	_os_:marshal_int64(self.recruitrole)
	_os_:marshal_wstring(self.recruitserver)
	return _os_
end

function SGetRecruitAward:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	self.awardtype = _os_:unmarshal_int32()
	self.awardid = _os_:unmarshal_int32()
	self.recruitrole = _os_:unmarshal_int64()
	self.recruitserver = _os_:unmarshal_wstring(self.recruitserver)
	return _os_
end

return SGetRecruitAward
