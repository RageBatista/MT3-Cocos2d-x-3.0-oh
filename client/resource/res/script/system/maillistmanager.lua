
MailListManager = {}
MailListManager.__index = MailListManager

--For singleton
local _instance;
function MailListManager.getInstance()
	print("enter get MailListManager instance")
	if not _instance then
		_instance = MailListManager:new()
	end
	return _instance
end

function MailListManager.getInstanceNotCreate()
	return _instance
end

function MailListManager.Destroy()
	if _instance then 
		print("destroy MailListManager")
		_instance = nil
	end
end

function MailListManager:new()
	local self = {}
	setmetatable(self, MailListManager)

	self.m_vList = {}

	return self
end

-- 刷新邮件列表
function MailListManager:RefreshMailList(maillist)

	-- 存储邮件列表
	self.m_vList = maillist

	-- 默认设置所有邮件未领取,已领取的邮件服务器不会再发过来
	for i = 1, #self.m_vList do
		self.m_vList[i].getflag = 0 -- 这里添加一个值
	end
end

-- 刷新邮件信息
function MailListManager:RefreshMailInfo(mailInfo)

	-- 有则替换，无则添加

	for i = 1, #self.m_vList do
		local mailInfoRef = self.m_vList[i]
		if mailInfoRef.kind == mailInfo.kind and mailInfoRef.id == mailInfo.id then
			mailInfoRef = mailInfo
			return
		end
	end

	self.m_vList[#self.m_vList + 1] = mailInfo
end

-- 刷新邮件状态
function MailListManager:RefreshMailState(kind, id, statetype, statevalue)

	for i = 1, #self.m_vList do
		local mailInfoRef = self.m_vList[i]
		if mailInfoRef.kind == kind and mailInfoRef.id == id then
			if statetype == 0 then
				-- 刷新读取状态
				mailInfoRef.readflag = statevalue
			elseif statetype == 1 then
				-- 刷新领取状态
				mailInfoRef.getflag = statevalue
			end
			break
		end
	end

end

-- 获取未读邮件数
function MailListManager:GetNotReadNum()

	-- 未读邮件数
	local num = 0
	for i = 1, #self.m_vList do
		if self.m_vList[i].readflag == 0 then
			num = num + 1
		end
	end
	return num
end

function MailListManager:GetMailList()
	return self.m_vList
end

function MailListManager:GetMailSize()
	return #self.m_vList
end

return MailListManager
