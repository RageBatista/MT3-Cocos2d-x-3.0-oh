require "logic.dialog"

MainRoleExpDlg = {}
setmetatable(MainRoleExpDlg, Dialog)
MainRoleExpDlg.__index = MainRoleExpDlg

local _instance
function MainRoleExpDlg.getInstance()
	if not _instance then
		_instance = MainRoleExpDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function MainRoleExpDlg.getInstanceAndShow()
	if not _instance then
		_instance = MainRoleExpDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MainRoleExpDlg.getInstanceNotCreate()
	return _instance
end

function MainRoleExpDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
        	_instance:ReleaseEffect()
			_instance:OnClose()
            _instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function MainRoleExpDlg.ToggleOpenClose()
	if not _instance then
		_instance = MainRoleExpDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MainRoleExpDlg.GetLayoutFileName()
	return "mainroleexpbar.layout"
end

function MainRoleExpDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MainRoleExpDlg)
	return self
end

function MainRoleExpDlg:OnCreate()
	Dialog.OnCreate(self)

    self.m_bAutoLevelUp = false

	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_pExp = CEGUI.Window.toProgressBar(winMgr:getWindow("MainRoleExpBar/Back/Bar"))
    
    self.m_pExpImg = winMgr:getWindow("MainRoleExpBar/Back/Exp")
    self.m_pExpImg:setMousePassThroughEnabled(true)
    self.m_pExpImg:setAlwaysOnTop(true)
    local namePrefix = "MainRoleExpBar/Segmet"
    local namestream = ""
    self.m_pSegmentation = {}
    for i =0, 10 do 
        namestream = namePrefix .. (i+1)
        self.m_pSegmentation[i] = winMgr:getWindow(namestream)
        self.m_pSegmentation[i]:setMousePassThroughEnabled(true)
        self.m_pSegmentation[i]:setAlwaysOnTop(true)
    end

    self.m_pExpImg:moveToFront()

    self:GetWindow():subscribeEvent("WindowUpdate", MainRoleExpDlg.HandleWindowUpate, self)

    local data = gGetDataManager():GetMainCharacterData()

    if data.nexp == 0 then
    	self.m_pExp:setTooltipText("")
		self.m_pExp:setProgress(0.0)
    else
        local exp = data.exp/data.nexp
        self.m_pExp:setProgress(exp)
    end
end

function MainRoleExpDlg:HandleWindowUpate()
    local data = gGetDataManager():GetMainCharacterData()
    if data.nexp == 0 then
        return
    end

    local curpro = self.m_pExp:getProgress()

    local destpro = 0.0
    if self.m_bAutoLevelUp == false then
        destpro = data.exp / data.nexp
    else 
        destpro = 1.0
        if math.abs(curpro - 1.0) < 0.003 then
            curpro = 0.0
            destpro = data.exp / data.nexp
            self.m_bAutoLevelUp = false
            
            if math.abs(curpro - math.min(1.0,destpro)) <= 0.003 then
				self.m_pExp:setProgress(curpro)
				if self.m_pEffect then
					self.m_pEffect:SetLocation(Nuclear.NuclearPoint(0,0))
				end
			end
        end
    end
    if math.abs(curpro - math.min(1.0,destpro)) > 0.009 then
        curpro = curpro + 0.009
        if curpro > 1.0 then
            curpro = 0.0
        end
        if math.abs(destpro - curpro) < 0.009 then
			curpro = destpro
		end

        self.m_pExp:setProgress(curpro)
        local xPos = math.floor(50+ self.m_pExp:getProgress()* self.m_pExp:getPixelSize().width)
		local yPos = math.floor(self:GetWindow():getParentPixelHeight()-5);

        local effectPos = Nuclear.NuclearPoint(xPos,yPos)

        if self.m_pExpAddEffect == nil and self.m_pExpEffect == nil and destpro>curpro then
        elseif  self.m_pExpAddEffect and self.m_pExpEffect and destpro>curpro then
            self.m_pExpAddEffect:SetLocation(effectPos);
			self.m_pExpEffect:SetLocation(effectPos);
        end
    elseif self.m_pExpAddEffect ~= nil then
        self:ReleaseEffect()
    end
    local xPos = math.floor(19 + self.m_pExp:getProgress() * self.m_pExp:getPixelSize().width);
	local yPos = math.floor(self:GetWindow():getParentPixelHeight()-5)-1;

    local effectPos = Nuclear.NuclearPoint(xPos,yPos)
    if self.m_pEffect then
		self.m_pEffect:SetLocation(effectPos)
	end
	return 
end

function MainRoleExpDlg:ReleaseEffect()
	if self.m_pExpEffect ~= nil then

		Nuclear.GetEngine():ReleaseEffect(self.m_pExpEffect)
		self.m_pExpEffect = nil
	end
	if self.m_pExpAddEffect ~= nil then
	
		Nuclear.GetEngine():ReleaseEffect(self.m_pExpAddEffect);
		self.m_pExpAddEffect = nil
	end
	
end

function MainRoleExpDlg:CreateFullExpEffect()

	self:ReleaseEffect()

	self.m_pExpEffect = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10069));
	self:UpdataEffectLoction()
end

function MainRoleExpDlg:CreateAddExpEffect()

	self:ReleaseEffect()

	self.m_pExpEffect = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10070));
	self.m_pExpAddEffect = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10071));
	
	self:UpdataEffectLoction()
end

function MainRoleExpDlg:UpdataEffectLoction()
	local xPos = math.floor(19 + self.m_pExp:getProgress()* self.m_pExp:getPixelSize().width)
	local yPos = math.floor(self:GetWindow():getParentPixelHeight()-5) -1

	if self.m_pEffect then
	    self.m_pEffect:sSetLocation(Nuclear.NuclearPoint(xPos,yPos))
	end
	
	if self.m_pExpAddEffect and self.m_pExpEffect then
	
		self.m_pExpEffect:SetLocation(Nuclear.NuclearPoint(xPos + 28,yPos +1))
		self.m_pExpAddEffect:SetLocation(Nuclear.NuclearPoint(xPos + 28,yPos +1))
	elseif self.m_pExpAddEffect == nil and self.m_pExpEffect ~= nil then
	
		xPos = math.floor(20 + self.m_pExp:getPixelSize().width/2)
		self.m_pExpEffect:SetLocation(Nuclear.NuclearPoint(xPos,yPos + 1))
	end
end

function MainRoleExpDlg:UpdateSeparatorPos()

	self:UpdataEffectLoction()
	self.m_fLeftOffect = 44 / self:GetWindow():getPixelSize().width;
	local unitw = (1.0 - self.m_fLeftOffect )/10


    for i = 0, 10 do
        if i+ 1 == 11 then
            self.m_pSegmentation[i]:setXPosition(CEGUI.UDim(unitw*i + self.m_fLeftOffect, -2));
        else
            self.m_pSegmentation[i]:setXPosition(CEGUI.UDim(unitw*i + self.m_fLeftOffect, 0));
        end
        self.m_pSegmentation[i]:setWidth(CEGUI.UDim(0,3));
    end
end  

function MainRoleExpDlg:UpdateUserExp()

	local data = gGetDataManager():GetMainCharacterData()
	if data.nexp == 0 then
		self.m_pExp:setTooltipText("")
		self.m_pExp:setProgress(0.0)
		self:ReleaseEffect();
		if self.m_pEffect then
			self.m_pEffect:SetLocation(Nuclear.NuclearPoint(0, math.floor(self:GetWindow():getParentPixelHeight()-6)))
		end
	else
		if data.exp >= data.nexp then
			self:CreateFullExpEffect()
		else
			self:ReleaseEffect()
		end

		local exp = data.exp / data.nexp
    end
end
function MainRoleExpDlg.updateExp()
    local dlg = require "logic.exp.mainroleexpdlg".getInstanceAndShow()
    dlg:UpdateUserExp()
end

return MainRoleExpDlg
