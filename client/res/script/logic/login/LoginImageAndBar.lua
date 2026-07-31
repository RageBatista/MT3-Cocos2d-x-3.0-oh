LoginImageAndBar = {
    m_bInited = false,
    m_ImageBack = 0,
    m_ImageRT = nil,
    pFontMan = nil,
    m_ProgessBarBack = 0,
    m_ProgessBarCover = 0,
    m_ProgessBarHighLight = 0,
    m_TextBgImg = 0,
    m_TipHandle = 0,
    m_curPro = 0,
    m_randIndex = 0,
}

local m_WhiteColor = Nuclear.NuclearColor(0xffffffff) 
local m_TipsColor = 0xfffff2df
local INVALID_PICTURE_HANDLE = 0

function LoginImageAndBar.Init()
    if LoginImageAndBar.m_bInited or gIsInBackground() then
        return
    end
    LoginImageAndBar.pFontMan = Nuclear.GetEngine():GetRenderer():GetFontManager()
	if LoginImageAndBar.m_ImageBack ~= INVALID_PICTURE_HANDLE then
		Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_ImageBack)
	end
    --当前地图id
    local nCurMapId = -1
    if gGetScene() then
        nCurMapId = gGetScene():GetMapID()
    end
    local nCurCharacterLevel = -1
    if gGetDataManager() then
        nCurCharacterLevel = gGetDataManager():GetMainCharacterLevel()
    end
    local nCurtaskID = -1
    if GetTaskManager() then
        nCurtaskID = GetTaskManager():GetMainScenarioQuestId() 
    end
    
    if nCurCharacterLevel == -1 then
        LoginImageAndBar.m_randIndex = 1
        --筛选结束用默认第一条
    else
        local imageRecords = {}
        --1、先判断等级把等级满足的挑出来
        local tableAllId = BeanConfigManager.getInstance():GetTableByName("login.cloginimages"):getAllID()
        for _, v in pairs(tableAllId) do
            local record = BeanConfigManager.getInstance():GetTableByName("login.cloginimages"):getRecorder(v)
            if nCurCharacterLevel >= record.minlevel and nCurCharacterLevel <= record.maxlevel then
                table.insert(imageRecords,record)
            end
        end
        if #imageRecords == 0 then
            LoginImageAndBar.m_randIndex = 1
            --筛选结束用默认第一条
        else
            --2、主线任务相同的挑出来
            if nCurtaskID == -1 then
                --3、把地图相同的跳出来，如果没有使用等级进行筛选
                LoginImageAndBar.FindIndexForMap(nCurMapId, imageRecords)
            else
                local res, list = LoginImageAndBar.FindTask(nCurtaskID,imageRecords)
                if res then
                    LoginImageAndBar.m_randIndex = LoginImageAndBar.FindRecordId(list)
                else
                    --3、把地图相同的跳出来，如果没有使用等级进行筛选
                    LoginImageAndBar.FindIndexForMap(nCurMapId, imageRecords)
                end
            end
        end       
    end 
    local imagestable =  BeanConfigManager.getInstance():GetTableByName("login.cloginimages")
    local imagename = imagestable:getRecorder(LoginImageAndBar.m_randIndex)
    local imagepath = "/image/loading/"..imagename.imagefilename
	LoginImageAndBar.m_ImageBack = Nuclear.GetEngine():GetRenderer():LoadPicture(imagepath)

    local m_dismode = gGetGameApplication():gGetDisPlayMode()
    if eDisplayMode_1136640 == m_dismode then
        m_dismode = eDisplayMode_800600
    end
	local mode=Nuclear.GetEngine():GetRenderer():GetDisplayMode()
    
    local screenwith = mode.width
    local screenheight = mode.height
    local imagewidth = imagename.width
    local imageheight = imagename.height
    LoginImageAndBar.m_ImageRT = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
    if ((imagewidth*screenheight)/(imageheight*screenwith)) > 1 then 
        local w = ((imagewidth*screenheight)/imageheight - screenwith)/2 
        LoginImageAndBar.m_ImageRT:Assign(-w, 0.0, screenwith+w, screenheight)
    else
        local h = ((screenwith*imageheight)/imagewidth - screenheight)/2 
        LoginImageAndBar.m_ImageRT:Assign(0.0, -h, screenwith, screenheight+h);
    end
	if LoginImageAndBar.m_ProgessBarBack ~= INVALID_PICTURE_HANDLE then
		if  m_dismode ~= gGetGameApplication():gGetDisPlayMode() then
			Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_ProgessBarBack)
		end
		m_dismode = gGetGameApplication():gGetDisPlayMode()
	end
	if LoginImageAndBar.m_ProgessBarCover == INVALID_PICTURE_HANDLE then
		LoginImageAndBar.m_ProgessBarCover = Nuclear.GetEngine():GetRenderer():LoadPicture("/image/loading/ProgressBarLights.tga")
    end

	if LoginImageAndBar.m_ProgessBarHighLight == INVALID_PICTURE_HANDLE then
		LoginImageAndBar.m_ProgessBarHighLight = Nuclear.GetEngine():GetRenderer():LoadPicture("/image/loading/ProgressBarLightHover.png")
    end

	if LoginImageAndBar.m_TextBgImg == INVALID_PICTURE_HANDLE then
		LoginImageAndBar.m_TextBgImg = Nuclear.GetEngine():GetRenderer():LoadPicture("/image/loading/loadingtiaoban.png")
    end

	if LoginImageAndBar.m_ProgessBarBack == INVALID_PICTURE_HANDLE then
		LoginImageAndBar.m_ProgessBarBack = Nuclear.GetEngine():GetRenderer():LoadPicture("/image/loading/progressbg.png")
    end
    LoginImageAndBar.m_ProgessBackRT = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
	LoginImageAndBar.m_ProgessBackRT:Assign(0.0, screenheight-12.0, screenwith, screenheight);
    LoginImageAndBar.m_ProgessCoverRT = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
    local cover_rate = 0.9*screenheight
	LoginImageAndBar.m_ProgessCoverRT:Assign(0.0, screenheight-12.0, screenwith, screenheight)
    LoginImageAndBar.m_ProgessCoverHighRT = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
    LoginImageAndBar.m_ProgessCoverHighRT:Assign(0.0, LoginImageAndBar.m_ProgessCoverRT.top, 278.0, LoginImageAndBar.m_ProgessCoverRT.bottom)
    LoginImageAndBar.m_TextBgRT = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
	LoginImageAndBar.m_TextBgRT:Assign(0.0, LoginImageAndBar.m_ProgessCoverRT.top-55.0, screenwith, LoginImageAndBar.m_ProgessCoverRT.top)

   
    local clt =  BeanConfigManager.getInstance():GetTableByName(CheckTableName("login.clogintips")):getRecorder(1)
	local num = clt.maxnum
	local index = math.random(1, num)
	clt =  BeanConfigManager.getInstance():GetTableByName(CheckTableName("login.clogintips")):getRecorder(index)
	LoginImageAndBar.m_TipHandle = LoginImageAndBar.pFontMan:NewTextex(clt.tip , 0, m_TipsColor, m_TipsColor)
	local ptb = LoginImageAndBar.pFontMan:GetTextBlock(LoginImageAndBar.m_TipHandle)
	if CEGUI.System:getSingleton():getGUISheet() and ptb then
		local height = ptb:GetTextHeight()
		local width = ptb:GetTextWidth()
		local top = LoginImageAndBar.m_TextBgRT.top+(LoginImageAndBar.m_TextBgRT:Height()-height)*0.5
		local left = 0.0
        left = (CEGUI.System:getSingleton():getGUISheet():getPixelSize().width - width) * 0.5
        LoginImageAndBar.m_TipRT = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
		LoginImageAndBar.m_TipRT:Assign(left,top,left + width,top + height);
	end
    LoginImageAndBar.m_bInited=true;
end

function LoginImageAndBar.FindIndexForMap(nCurMapId, imageRecords)
    if nCurMapId == -1 then
        local imagerecordnew = {}
        for i,v in pairs(imageRecords) do 
            if v.taskid  ==0 and v.mapid == 0 then
                table.insert(imagerecordnew, v)
            end
        end
        LoginImageAndBar.m_randIndex = LoginImageAndBar.FindRecordId(imagerecordnew)
    else
        local res, list = LoginImageAndBar.FindMap(nCurMapId,imageRecords)
        if res then
            LoginImageAndBar.m_randIndex = LoginImageAndBar.FindRecordId(list)
        else
            local imagerecordnew = {}
            for i,v in pairs(imageRecords) do 
                if v.taskid  ==0 and v.mapid == 0 then
                    table.insert(imagerecordnew, v)
                end
            end
            LoginImageAndBar.m_randIndex = LoginImageAndBar.FindRecordId(imagerecordnew)
        end
    end
end

--查找任务
function LoginImageAndBar.FindTask(task,imageRecords)
    local imageRecordsNew = {}
    for _, v in pairs(imageRecords) do
        if task == v.taskid then
            table.insert(imageRecordsNew,v)
        end
    end

    if #imageRecordsNew > 0 then
        return true, imageRecordsNew
    else
        return false, imageRecordsNew
    end
end
--查找地图
function LoginImageAndBar.FindMap(map,imageRecords)
    local imageRecordsNew = {}
    for _, v in pairs(imageRecords) do
        if map == v.mapid then
            table.insert(imageRecordsNew,v)
        end
    end

    if #imageRecordsNew > 0 then
        return true, imageRecordsNew
    else
        return false, imageRecordsNew
    end
end
--选出id
function LoginImageAndBar.FindRecordId(imageRecords)
    local weightAll = 0
    for _, v in pairs(imageRecords) do
        weightAll = weightAll + v.weight
    end
    local weight = math.random(1, weightAll)
    weightAll = 0
    for _, v in pairs(imageRecords) do
        if weight < weightAll + v.weight then
            return v.id
        end
        weightAll = weightAll + v.weight
    end
    return 1
end
function LoginImageAndBar.draw( pro )
    LoginImageAndBar.Init()
    if gIsInBackground() then 
        return
    end
    if pro then
        LoginImageAndBar.m_curPro = pro
    end
	Nuclear.GetEngine():GetRenderer():DrawPicture(LoginImageAndBar.m_ImageBack,LoginImageAndBar.m_ImageRT,  m_WhiteColor)
	Nuclear.GetEngine():GetRenderer():DrawPicture(LoginImageAndBar.m_ProgessBarBack,LoginImageAndBar.m_ProgessBackRT,m_WhiteColor)
    local frt = Nuclear.NuclearFRectt(0.0, 0.0, 0.0, 0.0)
    frt:Assign(LoginImageAndBar.m_ProgessCoverRT.left, LoginImageAndBar.m_ProgessCoverRT.top, LoginImageAndBar.m_ProgessCoverRT.right, LoginImageAndBar.m_ProgessCoverRT.bottom)
	frt.right = (frt.right - frt.left) * LoginImageAndBar.m_curPro  / 100.0 + frt.left
	Nuclear.GetEngine():GetRenderer():DrawPicture(LoginImageAndBar.m_ProgessBarCover,frt,m_WhiteColor);
	local frtLight = LoginImageAndBar.m_ProgessCoverHighRT;
	frtLight.left = frt.right - 278.0;
	frtLight.right = frt.right;
	Nuclear.GetEngine():GetRenderer():DrawPicture(LoginImageAndBar.m_ProgessBarHighLight,frtLight,m_WhiteColor)
    Nuclear.GetEngine():GetRenderer():DrawPicture(LoginImageAndBar.m_TextBgImg, LoginImageAndBar.m_TextBgRT, m_WhiteColor);
	if LoginImageAndBar.m_TipHandle ~= INVALID_PICTURE_HANDLE then
		LoginImageAndBar.pFontMan:DrawText(LoginImageAndBar.m_TipHandle,LoginImageAndBar.m_TipRT.left,LoginImageAndBar.m_TipRT.top,nil)
    end
end

function LoginImageAndBar.unLoad()
    if gIsInBackground() then
        return
    end
	if LoginImageAndBar.m_ImageBack ~= INVALID_PICTURE_HANDLE then
		Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_ImageBack)
		LoginImageAndBar.m_ImageBack = 0
	end
	if LoginImageAndBar.m_ProgessBarBack ~= INVALID_PICTURE_HANDLE then
		Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_ProgessBarBack)
		LoginImageAndBar.m_ProgessBarBack = 0
	end
	if LoginImageAndBar.m_ProgessBarCover ~= INVALID_PICTURE_HANDLE then
		Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_ProgessBarCover)
		LoginImageAndBar.m_ProgessBarCover = 0
	end
	if LoginImageAndBar.m_ProgessBarHighLight ~= INVALID_PICTURE_HANDLE then
		Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_ProgessBarHighLight)
		LoginImageAndBar.m_ProgessBarHighLight = 0
	end
	if LoginImageAndBar.m_TextBgImg ~= INVALID_PICTURE_HANDLE then
		Nuclear.GetEngine():GetRenderer():FreePicture(LoginImageAndBar.m_TextBgImg)
		LoginImageAndBar.m_TextBgImg = 0
	end
	LoginImageAndBar.pFontMan:ReleaseTextBlock(LoginImageAndBar.m_TipHandle)
	LoginImageAndBar.m_TipHandle = INVALID_PICTURE_HANDLE
    LoginImageAndBar.m_bInited = false
end


return LoginImageAndBar
