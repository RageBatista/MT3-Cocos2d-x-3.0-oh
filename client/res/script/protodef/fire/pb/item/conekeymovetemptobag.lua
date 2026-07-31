require "utils.tableutil"
COneKeyMoveTempToBag = {}
COneKeyMoveTempToBag.__index = COneKeyMoveTempToBag



COneKeyMoveTempToBag.PROTOCOL_TYPE = 787760

function COneKeyMoveTempToBag.Create()
	print("enter COneKeyMoveTempToBag create")
	return COneKeyMoveTempToBag:new()
end
function COneKeyMoveTempToBag:new()
	local self = {}
	setmetatable(self, COneKeyMoveTempToBag)
	self.type = self.PROTOCOL_TYPE
	self.srckey = 0
	self.number = 0
	self.dstpos = 0
	self.npcid = 0

	return self
end
function COneKeyMoveTempToBag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COneKeyMoveTempToBag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srckey)
	_os_:marshal_int32(self.number)
	_os_:marshal_int32(self.dstpos)
	_os_:marshal_int64(self.npcid)
	return _os_
end

function COneKeyMoveTempToBag:unmarshal(_os_)
	self.srckey = _os_:unmarshal_int32()
	self.number = _os_:unmarshal_int32()
	self.dstpos = _os_:unmarshal_int32()
	self.npcid = _os_:unmarshal_int64()
	return _os_
end

return COneKeyMoveTempToBag
