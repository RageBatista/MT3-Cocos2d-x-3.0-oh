require "utils.tableutil"
ComposeGemInfoBean = {}
ComposeGemInfoBean.__index = ComposeGemInfoBean


function ComposeGemInfoBean:new()
	local self = {}
	setmetatable(self, ComposeGemInfoBean)
	self.itemidorgoodid = 0
	self.num = 0

	return self
end
function ComposeGemInfoBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemidorgoodid)
	_os_:marshal_int32(self.num)
	return _os_
end

function ComposeGemInfoBean:unmarshal(_os_)
	self.itemidorgoodid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return ComposeGemInfoBean
