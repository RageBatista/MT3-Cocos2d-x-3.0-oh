require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.pos1"
require "protodef.rpcgen.fire.pb.team.singlecharacterbasic"
SSendSingleCharacterList = {}
SSendSingleCharacterList.__index = SSendSingleCharacterList



SSendSingleCharacterList.PROTOCOL_TYPE = 794472

function SSendSingleCharacterList.Create()
	print("enter SSendSingleCharacterList create")
	return SSendSingleCharacterList:new()
end
function SSendSingleCharacterList:new()
	local self = {}
	setmetatable(self, SSendSingleCharacterList)
	self.type = self.PROTOCOL_TYPE
	self.singlecharacterlist = {}

	return self
end
function SSendSingleCharacterList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendSingleCharacterList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.singlecharacterlist))
	for k,v in ipairs(self.singlecharacterlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSendSingleCharacterList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_singlecharacterlist=0 ,_os_null_singlecharacterlist
	_os_null_singlecharacterlist, sizeof_singlecharacterlist = _os_: uncompact_uint32(sizeof_singlecharacterlist)
	for k = 1,sizeof_singlecharacterlist do
		----------------unmarshal bean
		self.singlecharacterlist[k]=SingleCharacterBasic:new()

		self.singlecharacterlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SSendSingleCharacterList
