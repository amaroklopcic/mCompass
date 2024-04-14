
hook.Add("PopulateToolMenu", "mCompass_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption("Options", "mCompass", "Settings", "Settings", "", "", function(panel)
        panel:ClearControls()

        local Label1 = vgui.Create("DLabel", panel)
        Label1:Dock(TOP)
        Label1:SetTextColor(Color(50, 50, 50))
        Label1:SetText("Client Settings")
        Label1:SizeToContents()
        panel:AddItem(Label1)

        ----====----====----====----====----====----====----====----

        local box = vgui.Create("DCheckBoxLabel", panel)
        box:SetText("Enabled")
        box:SetTextColor(Color(50, 50, 50))
        box:SetConVar("mcompass_enabled")
        box:SetValue(GetConVar("mcompass_enabled"):GetInt())
        box:SizeToContents()
        panel:AddItem(box)

        local box2 = vgui.Create("DCheckBoxLabel", panel)
        box2:SetText("Show Heading")
        box2:SetTextColor(Color(50, 50, 50))
        box2:SetConVar("mcompass_heading")
        box2:SetValue(GetConVar("mcompass_heading"):GetInt())
        box2:SizeToContents()
        panel:AddItem(box2)

        panel:NumSlider("Style", "mcompass_style", 1, 3, 0)

        panel:NumSlider("X Position", "mcompass_xposition", 0, 1)
        panel:NumSlider("Y Position", "mcompass_yposition", 0, 1)
        panel:NumSlider("Width", "mcompass_width", 0, 1)
        panel:NumSlider("Height", "mcompass_height", 0, 1)

        panel:NumSlider("Spacing", "mcompass_spacing", 1, 10, 2)
        panel:NumSlider("Ratio (font size)", "mcompass_ratio", 0.1, 10)

        local mixercolor = string.ToColor(GetConVar("mcompass_color"):GetString())

        local mixer = vgui.Create("DColorMixer", panel)
        mixer:SizeToContents()
        mixer:SetColor(mixercolor)
        panel:AddItem(mixer)

        local but1 = vgui.Create("DButton", panel)
        but1:SetText("Set Color")
        but1.DoClick = function(self)
            local c = mixer:GetColor()
            local red = tostring(c.r) .. " "
            local green = tostring(c.g) .. " "
            local blue = tostring(c.b) .. " "
            local alpha = tostring(c.a)
            RunConsoleCommand("mcompass_color", red .. green .. blue .. alpha)
        end
        panel:AddItem(but1)

        local but2 = vgui.Create("DButton", panel)
        but2:SetText("Reset Settings")
        but2.DoClick = function(self)
            RunConsoleCommand("mcompass_reset")
        end
        panel:AddItem(but2)
    end)
end)
