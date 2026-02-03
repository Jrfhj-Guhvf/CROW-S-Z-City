if CLIENT then
    local isMenuOpen = nil
    zb.availableModes = zb.availableModes or {}
    local availableModes = zb.availableModes
    
    zb.RoundList = zb.RoundList or {}
    zb.nextround = zb.nextround or nil
    local queuePanelInstance = nil 
    local selectedModes = {}

    net.Receive("ZB_SendModesInfo", function()
        zb.availableModes = net.ReadTable()
    end)
    
    net.Receive("ZB_SendRoundList", function()
        zb.RoundList = net.ReadTable()
        zb.nextround = net.ReadString()
        table.insert(zb.RoundList, 1, zb.nextround)
        zb.nextround = nil
        if IsValid(queuePanelInstance) then
            queuePanelInstance:QueueUpdate()
        end
    end)
    
    net.Receive("ZB_NotifyRoundListChange", function()
        local playerName = net.ReadString()
        
        chat.AddText(Color(180, 180, 255), playerName, Color(255, 255, 255), " has modified the game mode queue")
        
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end)

    zb.StatsPanel = nil
    
    net.Receive("zb_xp_get_admin", function()
        if not IsValid(zb.StatsPanel) then return end
        
        local target = net.ReadEntity()
        local skill = net.ReadFloat()
        local exp = net.ReadInt(32)
        local deaths = net.ReadInt(32)
        local kills = net.ReadInt(32)
        local suicides = net.ReadInt(32)
        local bytes = net.ReadInt(32)
        local karma = net.ReadFloat()
        
        if zb.StatsPanel.SelectedPly == target then
             zb.StatsPanel:UpdateFields(skill, exp, deaths, kills, suicides, bytes, karma)
        end
    end)

    local function StyleElement(element, bgColor)
        bgColor = bgColor or Color(40, 40, 40, 200)
        
        element.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            
            if self:IsHovered() and self.Selectable then
                draw.RoundedBox(6, 1, 1, w-2, h-2, Color(60, 60, 60, 100))
                surface.SetDrawColor(255, 165, 0, 150)
                surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
            end
            
            if self.Selected then
                surface.SetDrawColor(0, 255, 0, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end
    end
    
    local function CreateModeItem(parent, mode, queue, index)
        local modePanel = vgui.Create("DPanel", parent)
        modePanel:SetTall(40)
        modePanel:Dock(TOP)
        modePanel:DockMargin(5, 2, 5, 2)
        modePanel.Mode = mode
        modePanel.Index = index 
        modePanel.Selectable = true
        modePanel.Selected = selectedModes[mode.key] or false
        
        StyleElement(modePanel, Color(50, 50, 50, 200))
        
        local title = vgui.Create("DLabel", modePanel)
        title:SetFont("DermaDefaultBold")
        title:SetText(mode.name)
        title:SetTextColor(Color(255, 255, 255))
        title:Dock(LEFT)
        title:DockMargin(10, 0, 0, 0)
        title:SizeToContents()
        
        if queue then
            local posLabel = vgui.Create("DLabel", modePanel)
            posLabel:SetFont("DermaDefault")
            posLabel:SetText("#" .. index)
            posLabel:SetTextColor(Color(180, 180, 180))
            posLabel:Dock(LEFT)
            posLabel:DockMargin(5, 0, 0, 0)
            posLabel:SizeToContents()
            
            local upBtn = vgui.Create("DButton", modePanel)
            upBtn:SetSize(24, 24)
            upBtn:Dock(RIGHT)
            upBtn:DockMargin(2, 8, 5, 8)
            upBtn:SetText("▲")
            upBtn.DoClick = function()
                if index > 1 then
                    local item = table.remove(zb.RoundList, index)
                    table.insert(zb.RoundList, index - 1, item)
                    queue:QueueUpdate()
                    
                    /*net.Start("ZB_UpdateRoundList")
                        net.WriteTable(zb.RoundList)
                        net.WriteBool(false) 
                    net.SendToServer()*/
                end
            end
            
            local downBtn = vgui.Create("DButton", modePanel)
            downBtn:SetSize(24, 24)
            downBtn:Dock(RIGHT)
            downBtn:DockMargin(2, 8, 2, 8)
            downBtn:SetText("▼")
            downBtn.DoClick = function()
                if index < #zb.RoundList then
                    local item = table.remove(zb.RoundList, index)
                    table.insert(zb.RoundList, index + 1, item)
                    queue:QueueUpdate()
                    
                    /*net.Start("ZB_UpdateRoundList")
                        net.WriteTable(zb.RoundList)
                        net.WriteBool(false)
                    net.SendToServer()*/
                end
            end
            
            local removeBtn = vgui.Create("DButton", modePanel)
            removeBtn:SetSize(24, 24)
            removeBtn:Dock(RIGHT)
            removeBtn:DockMargin(2, 8, 2, 8)
            removeBtn:SetText("✕")
            removeBtn.DoClick = function()
                table.remove(zb.RoundList, index)
                queue:QueueUpdate()

                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
            end
        else

            modePanel.OnMousePressed = function()
                modePanel.Selected = not modePanel.Selected
                selectedModes[mode.key] = modePanel.Selected
                
                if modePanel.Selected then
                    surface.PlaySound("buttons/button9.wav")
                else
                    surface.PlaySound("buttons/button17.wav")
                end
            end
        end
        
        return modePanel
    end
    
    local function CreateQueuePanel(frame)
        local queuePanel = vgui.Create("DPanel", frame)
        queuePanel:SetSize(frame:GetWide() / 2 - 10, frame:GetTall())
        queuePanel:Dock(RIGHT)
        queuePanel:DockMargin(5, 5, 5, 5)
        StyleElement(queuePanel, Color(30, 30, 30, 200))
        
        queuePanelInstance = queuePanel
        
        local titleLabel = vgui.Create("DLabel", queuePanel)
        titleLabel:SetText("Game Mode Queue")
        titleLabel:SetFont("HomigradFontBig")
        titleLabel:SetTextColor((hg.theme and hg.theme.c.accent) or Color(95,243,255))
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 5, 0, 5)
        titleLabel:SetContentAlignment(5) 
        
        local queueScroll = vgui.Create("DScrollPanel", queuePanel)
        queueScroll:Dock(FILL)
        queueScroll:DockMargin(5, 5, 5, 5)
        
        local saveBtn = vgui.Create("DButton", queuePanel)
        saveBtn:SetText("Apply Queue")
        saveBtn:Dock(BOTTOM)
        saveBtn:DockMargin(5, 5, 5, 5)
        saveBtn:SetTall(30)
        saveBtn.DoClick = function()
            //if #zb.RoundList > 0 then
                local tbl = table.Copy(zb.RoundList)
                //table.insert(tbl, 1, zb.nextround)
                net.Start("ZB_UpdateRoundList")
                    net.WriteTable(tbl)
                    net.WriteBool(true)
                net.SendToServer()
                
                chat.AddText(Color(0, 255, 0), "Game mode queue has been set!")
            //else
                //chat.AddText(Color(255, 0, 0), "Game mode queue is empty!")
            //end
        end
        
        local clearBtn = vgui.Create("DButton", queuePanel)
        clearBtn:SetText("Clear Queue")
        clearBtn:Dock(BOTTOM)
        clearBtn:DockMargin(5, 5, 5, 5)
        clearBtn:SetTall(30)
        clearBtn.DoClick = function()
            zb.RoundList = {}
            queuePanel:QueueUpdate()
            
            /*net.Start("ZB_UpdateRoundList")
                net.WriteTable({})
                net.WriteBool(false)
            net.SendToServer()*/
            
            chat.AddText(Color(255, 165, 0), "Game mode queue cleared!")
        end
        
        function queuePanel:QueueUpdate()
            queueScroll:Clear()
            
            if zb.nextround and zb.nextround ~= "" then
                local nextRoundLabel = vgui.Create("DLabel", queueScroll)
                nextRoundLabel:SetText("Next Mode: " .. zb.nextround)
                nextRoundLabel:SetFont("HomigradFontMedium")
                local a = hg.theme and hg.theme.c.accent or Color(95,243,255)
                nextRoundLabel:SetTextColor(a)
                nextRoundLabel:Dock(TOP)
                nextRoundLabel:DockMargin(5, 0, 0, 10)
                nextRoundLabel:SizeToContents()
            end
            
            for idx, modeKey in ipairs(zb.RoundList) do
                local mode = nil
                
                for _, availableMode in ipairs(zb.availableModes) do
                    if availableMode.key == modeKey then
                        mode = availableMode
                        break
                    end
                end
                
                if not mode then
                    mode = {key = modeKey, name = modeKey}
                end
                
                CreateModeItem(queueScroll, mode, queuePanel, idx)
            end
        end
        
        queuePanel:QueueUpdate()
        return queuePanel
    end

    local function OpenModeSelection(command)
        local frame = vgui.Create("ZFrame")
        frame:SetSize(700, 500)
        frame:Center()
        frame:SetTitle("Game Mode Manager")
        frame:MakePopup()
        
        selectedModes = {}
        
        local queuePanel = CreateQueuePanel(frame)
        
        local leftPanel = vgui.Create("DPanel", frame)
        leftPanel:SetSize(frame:GetWide() / 2 - 10, frame:GetTall())
        leftPanel:Dock(LEFT)
        leftPanel:DockMargin(5, 5, 5, 5)
        StyleElement(leftPanel, (hg.theme and hg.theme.c.panel) or Color(30, 30, 38, 200))
        
        local titleLabel = vgui.Create("DLabel", leftPanel)
        titleLabel:SetText("Available Game Modes")
        titleLabel:SetFont("HomigradFontBig")
        titleLabel:SetTextColor((hg.theme and hg.theme.c.accent) or Color(95,243,255))
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 5, 0, 5)
        titleLabel:SetContentAlignment(5) 
        
        local searchBar = vgui.Create("DTextEntry", leftPanel)
        searchBar:SetPlaceholderText("Search game modes...")
        searchBar:Dock(TOP)
        searchBar:DockMargin(5, 5, 5, 5)
        searchBar:SetTall(25)
        
        local dscroll = vgui.Create("DScrollPanel", leftPanel)
        dscroll:Dock(FILL)
        dscroll:DockMargin(5, 5, 5, 5)
        
        local modeItems = {}
        
        local function UpdateSearch(filter)
            filter = filter:lower()
            
            for _, item in ipairs(modeItems) do
                local visible = filter == "" or string.find(item.Mode.name:lower(), filter)
                item:SetVisible(visible)
            end
            
            dscroll:InvalidateLayout()
        end
        
        searchBar.OnChange = function(self)
            UpdateSearch(self:GetValue())
        end
        
        for i, mode in SortedPairsByMemberValue(zb.availableModes,"canlaunch",true) do
            local modeBtn = CreateModeItem(dscroll, mode)
            table.insert(modeItems, modeBtn)
            
            modeBtn:SetCursor("hand")
            modeBtn:SetTooltip("Click to select/unselect mode")
            
            local inQueue = false
            for _, queuedModeKey in ipairs(zb.RoundList) do
                if queuedModeKey == mode.key then
                    inQueue = true
                    break
                end
            end

            local indicator = vgui.Create("DPanel", modeBtn)
            indicator:SetSize(16, 7)
            indicator:SetPos(8, 4)
            indicator.IndiColor = Color(0, 0, 0, 0)
            indicator.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, indicator.IndiColor)
            end

            if mode.canlaunch == 1 then
                indicator.IndiColor = Color(0,255,34)
                indicator:SetTooltip("This mode can launch")
            end

            if inQueue then
                indicator.IndiColor = Color(255, 155, 0, 255)
                indicator:SetTooltip("This mode is already in queue")
            end
     
            if mode.canlaunch == 0 then
                indicator.IndiColor = Color(255,0,0,255)
                indicator:SetTooltip("This mode can't launch")
            end
            
            if command == "setmode" or command == "setforcemode" then
                local selectBtn = vgui.Create("DButton", modeBtn)
                selectBtn:SetSize(80, 26)
                selectBtn:Dock(RIGHT)
                selectBtn:DockMargin(5, 7, 5, 7)
                selectBtn:SetText("Select")
                selectBtn.DoClick = function()
                    net.Start("AdminSetGameMode")
                    net.WriteString(command)
                    net.WriteString(mode.key)
                    net.WriteBool(false) 
                    net.SendToServer()
                    frame:Close()
                end
            end
        end
        

        local batchPanel = vgui.Create("DPanel", leftPanel)
        batchPanel:Dock(BOTTOM)
        batchPanel:DockMargin(5, 5, 5, 5)
        StyleElement(batchPanel, Color(40, 40, 40, 200))
        
        local batchTitle = vgui.Create("DLabel", batchPanel)
        batchTitle:SetText("Batch Operations")
        batchTitle:SetFont("HomigradFontMedium")
        batchTitle:SetTextColor((hg.theme and hg.theme.c.text) or Color(229,229,229))
        batchTitle:Dock(TOP)
        batchTitle:DockMargin(0, 5, 0, 5)
        batchTitle:SetContentAlignment(5)
        
        local addToQueueBtn = vgui.Create("DButton", batchPanel)
        addToQueueBtn:SetText("Add Selected to Beginning of Queue")
        addToQueueBtn:Dock(TOP)
        addToQueueBtn:DockMargin(5, 0, 5, 5)
        addToQueueBtn:SetTall(26)
        addToQueueBtn.DoClick = function()
            local selectedCount = 0
            
            local selectedKeys = {}
            for key, selected in pairs(selectedModes) do
                if selected then
                    table.insert(selectedKeys, 1, key) 
                    selectedCount = selectedCount + 1
                end
            end
            
            for i = 1, #selectedKeys do
                table.insert(zb.RoundList, 1, selectedKeys[i])
            end
            
            if selectedCount > 0 then
                queuePanel:QueueUpdate()
                
                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
                
                chat.AddText(Color(0, 255, 0), "Added " .. selectedCount .. " modes to beginning of queue!")
                
                selectedModes = {}
                for _, item in ipairs(modeItems) do
                    item.Selected = false
                end
            else
                chat.AddText(Color(255, 0, 0), "No modes selected!")
            end
        end
        
        local addToEndBtn = vgui.Create("DButton", batchPanel)
        addToEndBtn:SetText("Add Selected to End of Queue")
        addToEndBtn:Dock(TOP)
        addToEndBtn:DockMargin(5, 0, 5, 0)
        addToEndBtn:SetTall(26)
        addToEndBtn.DoClick = function()
            local selectedCount = 0
            
            for key, selected in pairs(selectedModes) do
                if selected then
                    table.insert(zb.RoundList, key)
                    selectedCount = selectedCount + 1
                end
            end
            
            if selectedCount > 0 then
                queuePanel:QueueUpdate()
                
                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
                
                chat.AddText(Color(0, 255, 0), "Added " .. selectedCount .. " modes to end of queue!")
                

                selectedModes = {}
                for _, item in ipairs(modeItems) do
                    item.Selected = false
                end
            else
                chat.AddText(Color(255, 0, 0), "No modes selected!")
            end
        end
        
        local refreshBtn = vgui.Create("DButton", leftPanel)
        refreshBtn:SetText("Refresh Data")
        refreshBtn:Dock(BOTTOM)
        refreshBtn:DockMargin(5, 5, 5, 5)
        refreshBtn:SetTall(30)
        refreshBtn.DoClick = function()
            net.Start("ZB_RequestRoundList")
            net.SendToServer()
        end
        
        timer.Create("QueueAutoRefresh", 5, 0, function()
            if IsValid(frame) then
                //net.Start("ZB_RequestRoundList")
                //net.SendToServer()
            else
                timer.Remove("QueueAutoRefresh")
            end
        end)
        
        frame.OnClose = function()
            timer.Remove("QueueAutoRefresh")
            queuePanelInstance = nil
        end
        
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end

    local function OpenAdminMenu()
        if IsValid(isMenuOpen) then return end

        isMenuOpen = vgui.Create("ZFrame")
        local frame = isMenuOpen
        frame:SetSize(300, 255)
        frame:Center()
        frame:SetTitle("Admin Panel")
        frame:MakePopup()

        local setModeBtn = vgui.Create("DButton", frame)
        setModeBtn:SetText("Set Next Mode")
        setModeBtn:Dock(TOP)
        setModeBtn:DockMargin(5, 10, 5, 2)
        setModeBtn:SetSize(300, 40)
        StyleElement(setModeBtn)
        setModeBtn.DoClick = function()
            OpenModeSelection("setmode") 
        end

        local setForceModeBtn = vgui.Create("DButton", frame)
        setForceModeBtn:SetText("Set Auto Next Mode")
        setForceModeBtn:Dock(TOP)
        setForceModeBtn:DockMargin(5, 2, 5, 2)
        setForceModeBtn:SetSize(300, 40)
        StyleElement(setForceModeBtn)
        setForceModeBtn.DoClick = function()
            OpenModeSelection("setforcemode")
        end
        
        local queueModeBtn = vgui.Create("DButton", frame)
        queueModeBtn:SetText("Manage Game Mode Queue")
        queueModeBtn:Dock(TOP)
        queueModeBtn:DockMargin(5, 2, 5, 2)
        queueModeBtn:SetSize(300, 40)
        StyleElement(queueModeBtn)
        queueModeBtn.DoClick = function()
            OpenModeSelection("queue")
        end

        local function OpenPlayerStatsMenu()
            local psFrame = vgui.Create("ZFrame")
            psFrame:SetSize(600, 400)
            psFrame:Center()
            psFrame:SetTitle("Player Stats Manager")
            psFrame:MakePopup()
            
            zb.StatsPanel = psFrame
            psFrame.SelectedPly = nil

            local container = vgui.Create("DPanel", psFrame)
            container:Dock(FILL)
            container:DockMargin(5,5,5,5)
            StyleElement(container, Color(30,30,30,200))

            local leftPanel = vgui.Create("DPanel", container)
            leftPanel:Dock(LEFT)
            leftPanel:SetWide(200)
            leftPanel:DockMargin(0,0,5,0)
            leftPanel.Paint = nil

            local plyList = vgui.Create("DListView", leftPanel)
            plyList:Dock(FILL)
            plyList:AddColumn("Players")
            plyList:SetMultiSelect(false)

            local rightPanel = vgui.Create("DPanel", container)
            rightPanel:Dock(FILL)
            rightPanel.Paint = nil

            local stats = {
                { name = "Skill", key = "skill" },
                { name = "Experience", key = "exp" },
                { name = "Kills", key = "kills" },
                { name = "Deaths", key = "deaths" },
                { name = "Suicides", key = "suicides" },
                { name = "Bytes", key = "bytes" },
                { name = "Karma", key = "karma" }
            }
            
            local entries = {}
            
            for _, stat in ipairs(stats) do
                local row = vgui.Create("DPanel", rightPanel)
                row:Dock(TOP)
                row:SetTall(30)
                row:DockMargin(0,0,0,5)
                row.Paint = nil
                
                local label = vgui.Create("DLabel", row)
                label:SetText(stat.name)
                label:SetWide(80)
                label:Dock(LEFT)
                label:SetTextColor(Color(255,255,255))
                
                local entry = vgui.Create("DTextEntry", row)
                entry:Dock(FILL)
                entry:SetNumeric(true)
                entries[stat.key] = entry
            end
            
            function psFrame:UpdateFields(skill, exp, deaths, kills, suicides, bytes, karma)
                if IsValid(entries["skill"]) then entries["skill"]:SetValue(skill) end
                if IsValid(entries["exp"]) then entries["exp"]:SetValue(exp) end
                if IsValid(entries["deaths"]) then entries["deaths"]:SetValue(deaths) end
                if IsValid(entries["kills"]) then entries["kills"]:SetValue(kills) end
                if IsValid(entries["suicides"]) then entries["suicides"]:SetValue(suicides) end
                if IsValid(entries["bytes"]) then entries["bytes"]:SetValue(bytes) end
                if IsValid(entries["karma"]) then entries["karma"]:SetValue(karma) end
            end

            local updateBtn = vgui.Create("DButton", rightPanel)
            updateBtn:SetText("Update Stats")
            updateBtn:Dock(TOP)
            updateBtn:SetTall(30)
            updateBtn:DockMargin(0,10,0,0)
            StyleElement(updateBtn)
            updateBtn.DoClick = function()
                if not IsValid(psFrame.SelectedPly) then return end
                
                net.Start("zb_xp_set_admin")
                net.WriteEntity(psFrame.SelectedPly)
                net.WriteFloat(tonumber(entries["skill"]:GetValue()) or 0)
                net.WriteInt(tonumber(entries["exp"]:GetValue()) or 0, 32)
                net.WriteInt(tonumber(entries["deaths"]:GetValue()) or 0, 32)
                net.WriteInt(tonumber(entries["kills"]:GetValue()) or 0, 32)
                net.WriteInt(tonumber(entries["suicides"]:GetValue()) or 0, 32)
                net.WriteInt(tonumber(entries["bytes"]:GetValue()) or 0, 32)
                net.WriteFloat(tonumber(entries["karma"]:GetValue()) or 0)
                net.SendToServer()
                
                chat.AddText(Color(0,255,0), "Stats updated for " .. psFrame.SelectedPly:Nick())
            end

            plyList.OnRowSelected = function(lst, index, pnl)
                psFrame.SelectedPly = pnl.ply
                if IsValid(psFrame.SelectedPly) then
                    net.Start("zb_xp_get_admin")
                    net.WriteEntity(psFrame.SelectedPly)
                    net.SendToServer()
                end
            end
            
            for _, p in ipairs(player.GetAll()) do
                local line = plyList:AddLine(p:Nick())
                line.ply = p
            end
        end

        local function OpenPlayerClassMenu()
            local pcFrame = vgui.Create("ZFrame")
            pcFrame:SetSize(420, 280)
            pcFrame:Center()
            pcFrame:SetTitle("Change Player Class")
            pcFrame:MakePopup()

            local container = vgui.Create("DPanel", pcFrame)
            container:Dock(FILL)
            container:DockMargin(5,5,5,5)
            StyleElement(container, Color(30,30,30,200))

            local classLabel = vgui.Create("DLabel", container)
            classLabel:SetText("Class")
            classLabel:SetFont("HomigradFontMedium")
            classLabel:SetTextColor((hg.theme and hg.theme.c.text) or Color(229,229,229))
            classLabel:Dock(TOP)
            classLabel:DockMargin(5,5,5,0)

            local classCombo = vgui.Create("DComboBox", container)
            classCombo:Dock(TOP)
            classCombo:DockMargin(5,5,5,5)
            classCombo:SetTall(24)
            classCombo:SetValue("Select class")

            for name in pairs(player.classList or {}) do
                classCombo:AddChoice(name, name)
            end

            local listLabel = vgui.Create("DLabel", container)
            listLabel:SetText("Players")
            listLabel:SetFont("HomigradFontMedium")
            listLabel:SetTextColor((hg.theme and hg.theme.c.text) or Color(229,229,229))
            listLabel:Dock(TOP)
            listLabel:DockMargin(5,0,5,0)

            local plyList = vgui.Create("DListView", container)
            plyList:Dock(FILL)
            plyList:DockMargin(5,5,5,5)
            plyList:SetMultiSelect(true)
            plyList:AddColumn("Name")
            plyList:AddColumn("UserID")

            for _, p in ipairs(player.GetAll()) do
                plyList:AddLine(p:Nick(), p:UserID())
            end

            local actions = vgui.Create("DPanel", container)
            actions:SetTall(34)
            actions:Dock(BOTTOM)
            actions:DockMargin(5,5,5,5)
            StyleElement(actions, Color(40,40,40,200))

            local applySel = vgui.Create("DButton", actions)
            applySel:SetText("Apply to Selected")
            applySel:SetTextColor(Color(255,255,255))
            applySel:Dock(LEFT)
            applySel:DockMargin(5,4,5,4)
            applySel:SetWide(160)
            StyleElement(applySel)
            applySel.DoClick = function()
                local _, data = classCombo:GetSelected()
                if not data then return end
                local selected = plyList:GetSelected()
                if #selected == 0 then return end

                net.Start("AdminSetPlayerClass")
                    net.WriteString(data)
                    net.WriteUInt(#selected, 8)
                    for _, line in ipairs(selected) do
                        local uid = tonumber(line:GetColumnText(2)) or 0
                        net.WriteUInt(uid, 16)
                    end
                net.SendToServer()
            end

            local applyMe = vgui.Create("DButton", actions)
            applyMe:SetText("Apply to Me")
            applyMe:SetTextColor(Color(255,255,255))
            applyMe:Dock(RIGHT)
            applyMe:DockMargin(5,4,5,4)
            applyMe:SetWide(120)
            StyleElement(applyMe)
            applyMe.DoClick = function()
                local _, data = classCombo:GetSelected()
                if not data then return end
                net.Start("AdminSetPlayerClass")
                    net.WriteString(data)
                    net.WriteUInt(1, 8)
                    net.WriteUInt(LocalPlayer():UserID(), 16)
                net.SendToServer()
            end
        end

        local playerClassBtn = vgui.Create("DButton", frame)
        playerClassBtn:SetText("Change Player Class")
        playerClassBtn:Dock(TOP)
        playerClassBtn:DockMargin(5, 2, 5, 2)
        playerClassBtn:SetSize(300, 32)
        StyleElement(playerClassBtn)
        playerClassBtn.DoClick = function()
            OpenPlayerClassMenu()
        end

        local statsBtn = vgui.Create("DButton", frame)
        statsBtn:SetText("Manage Player Stats")
        statsBtn:Dock(TOP)
        statsBtn:DockMargin(5, 2, 5, 2)
        statsBtn:SetSize(300, 32)
        StyleElement(statsBtn)
        statsBtn.DoClick = function()
            OpenPlayerStatsMenu()
        end

        local function OpenSpawnpointManager()
            local spFrame = vgui.Create("ZFrame")
            spFrame:SetSize(700, 520)
            spFrame:Center()
            spFrame:SetTitle("Spawnpoint Manager")
            spFrame:MakePopup()

            local leftPanel = vgui.Create("DPanel", spFrame)
            leftPanel:SetSize(spFrame:GetWide() / 2 - 10, spFrame:GetTall())
            leftPanel:Dock(LEFT)
            leftPanel:DockMargin(5, 5, 5, 5)
            StyleElement(leftPanel, Color(30, 30, 30, 200))

            local rightPanel = vgui.Create("DPanel", spFrame)
            rightPanel:SetSize(spFrame:GetWide() / 2 - 10, spFrame:GetTall())
            rightPanel:Dock(RIGHT)
            rightPanel:DockMargin(5, 5, 5, 5)
            StyleElement(rightPanel, Color(30, 30, 30, 200))

            local titleLabel = vgui.Create("DLabel", leftPanel)
            titleLabel:SetText("Select Game Mode")
            titleLabel:SetFont("DermaLarge")
            titleLabel:SetTextColor(Color(255, 200, 0))
            titleLabel:Dock(TOP)
            titleLabel:DockMargin(0, 5, 0, 5)
            titleLabel:SetContentAlignment(5)

            local modeCombo = vgui.Create("DComboBox", leftPanel)
            modeCombo:Dock(TOP)
            modeCombo:DockMargin(5, 5, 5, 5)
            modeCombo:SetTall(25)
            modeCombo:SetValue("Select an option")

            local currentGroupName

            local drawToggle = vgui.Create("DCheckBoxLabel", leftPanel)
            drawToggle:Dock(TOP)
            drawToggle:DockMargin(5, 0, 5, 5)
            drawToggle:SetText("Draw Points")
            drawToggle:SetTextColor(Color(220,220,220))
            drawToggle:SetChecked(false)
            drawToggle.OnChange = function(_, val)
                if val then
                    hook.Add("PostDrawOpaqueRenderables", "RenderPoints", zb.DrawPoints)
                    zb.GetAllPoints()
                else
                    hook.Remove("PostDrawOpaqueRenderables", "RenderPoints")
                end
            end

            local refreshBtn = vgui.Create("DButton", leftPanel)
            refreshBtn:SetText("Refresh Points")
            refreshBtn:Dock(TOP)
            refreshBtn:DockMargin(5, 0, 5, 5)
            refreshBtn:SetTall(26)
            StyleElement(refreshBtn)
            refreshBtn.DoClick = function()
                zb.GetAllPoints()
            end


            local rightTitle = vgui.Create("DLabel", rightPanel)
            rightTitle:SetText("Spawnpoint Groups")
            rightTitle:SetFont("HomigradFontBig")
            rightTitle:SetTextColor((hg.theme and hg.theme.c.text) or Color(229,229,229))
            rightTitle:Dock(TOP)
            rightTitle:DockMargin(5, 5, 5, 0)
            rightTitle:SetContentAlignment(5)

            local groupsScroll = vgui.Create("DScrollPanel", rightPanel)
            groupsScroll:Dock(FILL)
            groupsScroll:DockMargin(5, 5, 5, 5)

            local groupsMap = {
                tdm = {"HMCD_TDM_T", "HMCD_TDM_CT"},
                cstrike = {"HMCD_TDM_T", "HMCD_TDM_CT", "BOMB_ZONE_A", "BOMB_ZONE_B", "HOSTAGE_DELIVERY_ZONE"},
                riot = {"RIOT_TDM_RIOTERS", "RIOT_TDM_LAW"},
                smo = {"HMCD_SWO_AZOV", "HMCD_SWO_WAGNER"},
                criresp = {"HMCD_CRI_T", "HMCD_CRI_CT"},
                sc = {"SC_INTRUDER", "SC_GUARD", "SC_CASE", "SC_ESCAPE"},
                azombie = {"RandomSpawns", "AZSpawn"},
                superfighters = {"RandomSpawns"},
                warfare = {"HMCD_TDM_TEAM_1", "HMCD_TDM_TEAM_2", "HMCD_TDM_TEAM_3", "HMCD_TDM_TEAM_4"},
            }

            local function BuildGroups(modeKey)
                groupsScroll:Clear()
                local groups = groupsMap[modeKey] or {}
                local groupNamesMap = {
                    HMCD_TDM_T = "T Spawnpoint",
                    HMCD_TDM_CT = "CT Spawnpoint",
                    RIOT_TDM_RIOTERS = "Rioters Spawnpoint",
                    RIOT_TDM_LAW = "Law Spawnpoint",
                    HMCD_SWO_AZOV = "AZOV Spawnpoint",
                    HMCD_SWO_WAGNER = "WAGNER Spawnpoint",
                    HMCD_CRI_T = "Suspects Spawnpoint",
                    HMCD_CRI_CT = "SWAT Spawnpoint",
                    SC_INTRUDER = "Intruder Spawnpoint",
                    SC_GUARD = "Guard Spawnpoint",
                    SC_CASE = "Case Point",
                    SC_ESCAPE = "Escape Point",
                    RandomSpawns = "Random Spawns",
                    AZSpawn = "AZ Player Spawn",
                    HMCD_TDM_TEAM_1 = "Team 1 Spawnpoint",
                    HMCD_TDM_TEAM_2 = "Team 2 Spawnpoint",
                    HMCD_TDM_TEAM_3 = "Team 3 Spawnpoint",
                    HMCD_TDM_TEAM_4 = "Team 4 Spawnpoint",
                }

                for _, groupName in ipairs(groups) do
                    local row = vgui.Create("DPanel", groupsScroll)
                    row:SetTall(72)
                    row:Dock(TOP)
                    row:DockMargin(5, 2, 5, 2)
                    StyleElement(row, Color(40, 40, 40, 200))

                    local lbl = vgui.Create("DLabel", row)
                    lbl:SetFont("DermaDefaultBold")
                    lbl:SetText((groupNamesMap[groupName] or groupName) .. " (" .. (zb.ClPoints[groupName] and #zb.ClPoints[groupName] or 0) .. ")")
                    lbl:SetTextColor(Color(255,255,255))
                    lbl:Dock(TOP)
                    lbl:DockMargin(10, 6, 10, 2)
                    lbl:SizeToContents()

                    local buttons = vgui.Create("DPanel", row)
                    buttons:SetTall(30)
                    buttons:Dock(TOP)
                    buttons:DockMargin(10, 2, 10, 6)

                    local addBtn = vgui.Create("DButton", buttons)
                    addBtn:SetText("Add Spawnpoint")
                    addBtn:SetTextColor(Color(255,255,255))
                    addBtn:Dock(LEFT)
                    addBtn:DockMargin(0, 0, 6, 0)
                    addBtn:SetWide(130)
                    StyleElement(addBtn)
                    addBtn.DoClick = function()
                        net.Start("zb_pointsaction")
                            net.WriteString("create")
                            net.WriteString(groupName)
                            net.WriteInt(0, 16)
                        net.SendToServer()
                        timer.Simple(0.1, function() zb.GetAllPoints() BuildGroups(modeKey) end)
                    end

                    local removeBtn = vgui.Create("DButton", buttons)
                    removeBtn:SetText("Remove Last")
                    removeBtn:SetTextColor(Color(255,255,255))
                    removeBtn:Dock(LEFT)
                    removeBtn:DockMargin(0, 0, 6, 0)
                    removeBtn:SetWide(110)
                    StyleElement(removeBtn)
                    removeBtn.DoClick = function()
                        net.Start("zb_pointsaction")
                            net.WriteString("remove")
                            net.WriteString(groupName)
                            net.WriteInt(0, 16)
                        net.SendToServer()
                        timer.Simple(0.1, function() zb.GetAllPoints() BuildGroups(modeKey) end)
                    end

                    local clearBtn = vgui.Create("DButton", buttons)
                    clearBtn:SetText("Clear All")
                    clearBtn:SetTextColor(Color(255,255,255))
                    clearBtn:Dock(LEFT)
                    clearBtn:SetWide(90)
                    StyleElement(clearBtn)
                    clearBtn.DoClick = function()
                        net.Start("zb_pointsaction")
                            net.WriteString("clear")
                            net.WriteString(groupName)
                            net.WriteInt(0, 16)
                        net.SendToServer()
                        timer.Simple(0.1, function() zb.GetAllPoints() BuildGroups(modeKey) end)
                    end
                end
            end

            modeCombo.OnSelect = function(_, _, _, data)
                BuildGroups(data)
            end

            for _, m in ipairs(zb.availableModes or {}) do
                modeCombo:AddChoice(m.name, m.key)
            end

            zb.GetAllPoints()
        end

        local spawnBtn = vgui.Create("DButton", frame)
        spawnBtn:SetText("Configure Spawnpoints")
        spawnBtn:Dock(TOP)
        spawnBtn:DockMargin(5, 2, 5, 2)
        spawnBtn:SetSize(300, 40)
        StyleElement(spawnBtn)
        spawnBtn.DoClick = function()
            OpenSpawnpointManager()
        end

        local endRoundBtn = vgui.Create("DButton", frame)
        endRoundBtn:SetText("End Round")
        endRoundBtn:Dock(TOP)
        endRoundBtn:DockMargin(5, 2, 5, 2)
        endRoundBtn:SetSize(300, 40)
        StyleElement(endRoundBtn)
        endRoundBtn.DoClick = function()
			net.Start("AdminEndRound")
			net.SendToServer()
			frame:Close()
        end

        frame.OnClose = function()
            isMenuOpen = false
        end
        frame:InvalidateLayout(true)
        frame:SizeToChildren(false, true)
    end
    

    hook.Add("InitPostEntity", "RequestModeData", function()
        if LocalPlayer():IsAdmin() then
            timer.Simple(2, function()
                net.Start("ZB_RequestRoundList")
                net.SendToServer()
            end)
        end
    end)

    local f6Key = KEY_F6

    hook.Add("PlayerButtonDown", "OpenAdminMenuF6", function(ply, key)
        if key == f6Key and LocalPlayer():IsAdmin() and not IsValid(isMenuOpen) then
            OpenAdminMenu()
        end
    end)
end
