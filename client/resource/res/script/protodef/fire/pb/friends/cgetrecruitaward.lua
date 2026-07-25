require "utils.tableutil"
CGetRecruitAward = {}
CGetRecruitAward.__index = CGetRecruitAward



CGetRecruitAward.PROTOCOL_TYPE = 806662

function CGetRecruitAward.Create()
	print("enter CGetRecruitAward create")
	return CGetRecruitAward:new()
end
function CGetRecruitAward:new()
	local self = {}
	setmetatable(self, CGetRecruitAward)
	self.type = self.PROTOCOL_TYPE
	self.awardtype = 0
	self.awardid = 0
	self.recruitrole = 0
	self.recruitserver = "" 

	return self
end
function CGetRecruitAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRecruitAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.awardtype)
	_os_:marshal_int32(self.awardid)
	_os_:marshal_int64(self.recruitrole)
	_os_:marshal_wstring(self.recruitserver)
	return _os_
end

function CGetRecruitAward:unmarshal(_os_)
	self.awardtype = _os_:unmarshal_int32()
	self.awardid = _os_:unmarshal_int32()
	self.recruitrole = _os_:unmarshal_int64()
	self.recruitserver = _os_:unmarshal_wstring(self.recruitserver)
	return _os_
end

return CGetRecruitAward
