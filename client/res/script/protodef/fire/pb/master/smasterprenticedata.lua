require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.masterprenticedata"
SMasterPrenticeData = {}
SMasterPrenticeData.__index = SMasterPrenticeData



SMasterPrenticeData.PROTOCOL_TYPE = 816448

function SMasterPrenticeData.Create()
	print("enter SMasterPrenticeData create")
	return SMasterPrenticeData:new()
end
function SMasterPrenticeData:new()
	local self = {}
	setmetatable(self, SMasterPrenticeData)
	self.type = self.PROTOCOL_TYPE
	self.members = {}

	return self
end
function SMasterPrenticeData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMasterPrenticeData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.members))
	for k,v in ipairs(self.members) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SMasterPrenticeData:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_members=0,_os_null_members
	_os_null_members, sizeof_members = _os_: uncompact_uint32(sizeof_members)
	for k = 1,sizeof_members do
		----------------unmarshal bean
		self.members[k]=MasterPrenticeData:new()

		self.members[k]:unmarshal(_os_)

	end
	return _os_
end

return SMasterPrenticeData
