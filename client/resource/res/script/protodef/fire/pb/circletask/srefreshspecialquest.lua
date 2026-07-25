require "utils.tableutil"
SRefreshSpecialQuest = {}
SRefreshSpecialQuest.__index = SRefreshSpecialQuest



SRefreshSpecialQuest.PROTOCOL_TYPE = 807432

function SRefreshSpecialQuest.Create()
	print("enter SRefreshSpecialQuest create")
	return SRefreshSpecialQuest:new()
end
function SRefreshSpecialQuest:new()
	local self = {}
	setmetatable(self, SRefreshSpecialQuest)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.queststate = 0
	self.round = 0
	self.sumnum = 0
	self.questtype = 0
	self.dstmapid = 0
	self.dstnpckey = 0
	self.dstnpcname = "" 
	self.dstnpcid = 0
	self.dstitemid = 0
	self.dstitemnum = 0
	self.dstitemid2 = 0
	self.dstitemidnum2 = 0
	self.dstx = 0
	self.dsty = 0
	self.validtime = 0
	self.islogin = 0

	return self
end
function SRefreshSpecialQuest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshSpecialQuest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int32(self.queststate)
	_os_:marshal_int32(self.round)
	_os_:marshal_int32(self.sumnum)
	_os_:marshal_int32(self.questtype)
	_os_:marshal_int32(self.dstmapid)
	_os_:marshal_int64(self.dstnpckey)
	_os_:marshal_wstring(self.dstnpcname)
	_os_:marshal_int32(self.dstnpcid)
	_os_:marshal_int32(self.dstitemid)
	_os_:marshal_int32(self.dstitemnum)
	_os_:marshal_int32(self.dstitemid2)
	_os_:marshal_int32(self.dstitemidnum2)
	_os_:marshal_int32(self.dstx)
	_os_:marshal_int32(self.dsty)
	_os_:marshal_int64(self.validtime)
	_os_:marshal_int32(self.islogin)
	return _os_
end

function SRefreshSpecialQuest:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.queststate = _os_:unmarshal_int32()
	self.round = _os_:unmarshal_int32()
	self.sumnum = _os_:unmarshal_int32()
	self.questtype = _os_:unmarshal_int32()
	self.dstmapid = _os_:unmarshal_int32()
	self.dstnpckey = _os_:unmarshal_int64()
	self.dstnpcname = _os_:unmarshal_wstring(self.dstnpcname)
	self.dstnpcid = _os_:unmarshal_int32()
	self.dstitemid = _os_:unmarshal_int32()
	self.dstitemnum = _os_:unmarshal_int32()
	self.dstitemid2 = _os_:unmarshal_int32()
	self.dstitemidnum2 = _os_:unmarshal_int32()
	self.dstx = _os_:unmarshal_int32()
	self.dsty = _os_:unmarshal_int32()
	self.validtime = _os_:unmarshal_int64()
	self.islogin = _os_:unmarshal_int32()
	return _os_
end

return SRefreshSpecialQuest
