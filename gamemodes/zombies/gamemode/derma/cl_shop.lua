local blurMat = Material( "pp/blurscreen" )
local mat_local_ov = Material("zombies/ui/overview.png")
local mat_local_user = Material("zombies/ui/class.png")
local mat_local_gun = Material("zombies/ui/gun.png")
local mat_local_perk = Material("zombies/ui/perks.png")
local mat_local_skin = Material("zombies/ui/skins.png")
local mat_local_lock = Material("zombies/ui/lock.png")
local mat_local_close = Material("zombies/ui/close.png")
local mat_local_badge = Material("zombies/ui/badge.png")

// save the current panel
local current_panel

-- Function to draw the blur effect
-- guys chill i added this before gmod had shader support
function DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(blurMat)
    
    for i = 1, 3 do
        blurMat:SetFloat("$blur", (i / 3) * (amount or 6))
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

local function AddShopOption(name, panel, material, default, buttonClick)
    local material = material or Material("error.png")
    local Selection = vgui.Create("DButton", panel)
    Selection:Dock(TOP)
    Selection:SetTall(32)
    Selection:DockMargin(16, 0, 16, 0)
    Selection:SetText("")

    Selection.Paint = function(self, w, h)
        local alpha = 125
        if self:IsHovered() or current_panel == self then
            alpha = 255
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(mat_grad_center)
            surface.DrawTexturedRect(0, h - 1, w, 1)
        end

        draw.SimpleText(name, "DisplayFontText", 40, h / 2, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(material)
        surface.DrawTexturedRect(4, 4, 24, 24)
    end

    local originalButtonClick = buttonClick

    Selection.DoClick = function()
        if originalButtonClick then
            originalButtonClick()
        end
        surface.PlaySound(sound_click)
        current_panel = Selection
    end

    if default then
        current_panel = Selection
    end

    return Selection
end

local function CreateSubPanel(parent, posX, posY, sizeX, sizeY, visible, panelPaint )
    local panel = vgui.Create("DPanel", parent)
    panel:SetSize(sizeX, sizeY)
    panel:SetPos(posX, posY)
    panel:SetVisible( visible )
    panel.Paint = panelPaint
    return panel
end

function ShopMenu()
    local scrw, scrh = ScrW(), ScrH()

    if IsValid(Shop) then
        Shop:Remove()
    end

    local alphaAnim, timeAnim, delayAnim = 255, 0.2, 0

	Shop = vgui.Create("DFrame")
    Shop:SetPos(0, 0)
	Shop:SetSize(scrw * 0.7, scrh * 0.7)
    Shop:Center()
    Shop:SetAlpha(0)
    Shop:AlphaTo( alphaAnim, timeAnim, delayAnim )
	Shop:SetTitle("")
    Shop:ShowCloseButton(false)
    Shop:SetDraggable(false)
	Shop:MakePopup()

    Shop.Paint = function(self, w, h)
        DrawBlur(self, 8)
        draw.RoundedBoxEx(8, 0, 0, 160, h, Color(0, 0, 0, 225), true, false, true, false)
        draw.RoundedBoxEx(8, 160, 0, w - 160, 32, Color(0, 0, 0, 225), false, true, false, false)

        draw.SimpleText("Zombies", "DisplayFontTitle", 80, 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(FormatMoney(LocalPlayer():GetPoints()).. "P", "DisplayFontText", 80, h - 48, Color(255, 255, 255, 55), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        local level, needed, gained = LocalPlayer():GetLevel()
        draw.SimpleText("Level: ".. level.. " (".. gained.. "/".. needed.. ")", "DisplayFontText", 80, h - 24, Color(255, 255, 255, 55), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetDrawColor(0, 0, 0, 155)
        surface.DrawRect(16, h - 16, 128, 8)

        surface.SetDrawColor(155, 155, 155, 255)
        local xp_bar = (gained / needed) * 128
        surface.DrawRect(16, h - 16, xp_bar, 8)
        surface.DrawLine(128 + 16, h - 16, 128 + 16, h - 8)

        --surface.SetDrawColor(30, 33, 36, 255)
        --surface.DrawRect(160, 0, w - 160, 32)

        surface.SetDrawColor(255, 255, 255, 55)
        surface.DrawLine(159, 31, 159, h)
        surface.DrawLine(159, 31, w, 31)
    end

    local ShopSelection = vgui.Create("DPanel", Shop)
    ShopSelection:SetPos(0, 64)
    ShopSelection:SetSize(160, Shop:GetTall() - 128)
    ShopSelection.Paint = function()
        return
    end

    local panel = {}

    panel.overview = CreateSubPanel(Shop, 160, 32, Shop:GetWide() - 160, Shop:GetTall() - 32, true, function(self, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(30,33,36, 225), false, false, false, true)
    end)

    panel.classes = CreateSubPanel(Shop, 160, 32, Shop:GetWide() - 160, Shop:GetTall() - 32, false, function(self, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(30,33,36, 225), false, false, false, true)
    end)

    panel.weapons = CreateSubPanel(Shop, 160, 32, Shop:GetWide() - 160, Shop:GetTall() - 32, false, function(self, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(30,33,36, 225), false, false, false, true)
    end)

    panel.badges = CreateSubPanel(Shop, 160, 32, Shop:GetWide() - 160, Shop:GetTall() - 32, false, function(self, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(30,33,36, 225), false, false, false, true)
    end)

    panel.skins = CreateSubPanel(Shop, 160, 32, Shop:GetWide() - 160, Shop:GetTall() - 32, false, function(self, w, h)
        draw.SimpleText("In progress..", "DisplayFontText", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

    panel.perks = CreateSubPanel(Shop, 160, 32, Shop:GetWide() - 160, Shop:GetTall() - 32, false, function(self, w, h)
        draw.SimpleText("In progress..", "DisplayFontText", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

    AddShopOption("Overview", ShopSelection, mat_local_ov, true, function()
        for _, panel in pairs(panel) do
            panel:SetVisible(false)
        end

        panel["overview"]:SetVisible(true)
    end)
    AddShopOption("Classes", ShopSelection, mat_local_user, false, function()
        for _, panel in pairs(panel) do
            panel:SetVisible(false)
        end

        panel["classes"]:SetVisible(true)
    end)
    AddShopOption("Market", ShopSelection, mat_local_gun, false, function()
        for _, panel in pairs(panel) do
            panel:SetVisible(false)
        end

        panel["weapons"]:SetVisible(true)
    end)
    AddShopOption("Badges", ShopSelection, mat_local_badge, false, function()
        for _, panel in pairs(panel) do
            panel:SetVisible(false)
        end

        panel["badges"]:SetVisible(true)
    end)
    /*
    AddShopOption("Extras", ShopSelection, mat_local_skin, false, function()
        for _, panel in pairs(panel) do
            panel:SetVisible(false)
        end

        panel["skins"]:SetVisible(true)
    end)
    AddShopOption("Perks", ShopSelection, mat_local_perk, false, function()
        for _, panel in pairs(panel) do
            panel:SetVisible(false)
        end

        panel["perks"]:SetVisible(true)
    end)
    */

    local CloseButton = vgui.Create( "DButton", Shop )
    CloseButton:SetText( "" )
    CloseButton:SetPos( Shop:GetWide() - 24, 8 )
    CloseButton:SetSize( 16, 16 )
    CloseButton.DoClick = function()
        surface.PlaySound(sound_click)
        Shop:Close()
    end
    CloseButton.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        if self:IsHovered() then
            surface.SetDrawColor(255, 55, 55, 255)
        end
        surface.SetMaterial(mat_local_close)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    // WEAPONS _____________________________________________________________________________________
    local weaponinfo

    local WLPanel = vgui.Create( "DPanel", panel.weapons )
    WLPanel:SetPos(Shop:GetWide() - 256 - 128 - 32, 0)
    WLPanel:SetSize( 256, panel.weapons:GetTall() )
    WLPanel.Paint = function(self, w, h)
        if !ZConfig.shop.weapons[weaponinfo] then return end
        local swep = ZConfig.shop.weapons[weaponinfo].swep or "m9k_winchester73"
        local weapon = weapons.Get( swep )
        local wep_dmg = math.Clamp(weapon.Primary.Damage, 0, 100)
        local firerate = weapon.Primary.RPM
        local wep_recoil = math.Clamp(( weapon.Primary.KickHorizontal + weapon.Primary.KickUp + weapon.Primary.KickDown ) / 2 * 100, 0, 100 )
        local clip = weapon.Primary.ClipSize
        local wep_accu = math.Clamp(100 - (weapon.Primary.Spread * 1000), 1, 100)
        local price = ZConfig.shop.weapons[weaponinfo].price or 0

        local wep_name =  ZConfig.shop.weapons[weaponinfo].name or "none"
        local dmg = (wep_dmg/100) * 224-- 0-100
        local accu = (wep_accu/100) * 224-- 0-100
        local recoil = (wep_recoil/100) * 224-- 0-100
        draw.SimpleText(wep_name, "DisplayFontHeader", w / 2, 32, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Damage", "DisplayFontText", 8, 256 + 32 + 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(wep_dmg, "DisplayFontText", 224, 256 + 32 + 18, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(8, 256 + 48, 224 - 16, 4)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(8, 256 + 48, dmg - 16, 4)
        draw.SimpleText("Accuracy", "DisplayFontText", 8, 256 + 64 + 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(wep_accu, "DisplayFontText", 224, 256 + 64 + 18, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(8, 256 + 64 + 16, 224 - 16, 4)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(8, 256 + 64 + 16, accu - 16, 4)

        -- Draw recoil bar
        draw.SimpleText("Recoil", "DisplayFontText", 8, 256 + 96 + 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(wep_recoil, "DisplayFontText", 224, 256 + 80 + 32 + 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(8, 256 + 96 + 16, 224 - 16, 4)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(8, 256 + 96 + 16, recoil - 16, 4)

        draw.SimpleText("Firerate: " .. firerate .. "rpm", "DisplayFontText", 8, 256 + 128 + 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Clip: " .. clip .. "/" .. clip, "DisplayFontText", 8, 256 + 144 + 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        --draw.SimpleText("Cost: " .. price .. "P", "DisplayFontText", 8, 256 + 160 + 4, Color(155, 255, 155, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local ctrl = vgui.Create( "DAdjustableModelPanel", WLPanel )
    ctrl:SetPos(0, 0)
    ctrl:SetSize( 256, 256 )
    ctrl:SetLookAng( Angle( 45, 0, 0 ) )
    ctrl:SetCamPos( Vector( -20, 0, 20 ) )

    local ScrollPanelWeapons = vgui.Create("DScrollPanel", panel.weapons)
    ScrollPanelWeapons:SetPos(0, 32)
    ScrollPanelWeapons:SetSize(Shop:GetWide() - 160 - 256, Shop:GetTall() - 64)
    ScrollPanelWeapons.Paint = function(self, w, h)
        return
    end

    local sbar = ScrollPanelWeapons:GetVBar()
    function sbar:Paint(w, h)
        return
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(155, 155, 155, 155)
        surface.DrawRect(0, 0, 1, h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(155, 155, 155, 155)
        surface.DrawRect(0, 0, 1, h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(155, 155, 155, 155)
        surface.DrawRect(0, 0, 1, h)
    end

    local function SortMenuWeapons(sorted)
        for index, weaponData in SortedPairsByMemberValue(ZConfig.shop.weapons, "price", false) do
            --if LocalPlayer():HasBoughtWeapon(index) then continue end
            if sorted and sorted ~= 0 and sorted ~= weaponData.slot then continue end
            local ShopButton = vgui.Create( "DButton", ScrollPanelWeapons )
            ShopButton:Dock(TOP)
            ShopButton:DockMargin(8, 8, 8, 8)
            ShopButton:SetText("")
            ShopButton:SetTall(48)
            ShopButton.Paint = function(self, w, h)
                if !LocalPlayer():HasBoughtWeapon(index) then
                    surface.SetDrawColor(0, 0, 0, 155)
                    if self:IsHovered() then
                        surface.SetDrawColor(0, 0, 0, 225)
                    end
                    surface.DrawRect(0, 0, w, h)
                    if LocalPlayer():CanAfford(weaponData.price) then
                        if weaponData.price == 0 then
                            draw.SimpleText("Free", "DisplayFontText", w - 12, h / 2, Color(155, 255, 155, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        else
                            draw.SimpleText(FormatMoney(weaponData.price).. "P", "DisplayFontText", w - 12, h / 2, Color(155, 255, 155, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end
                    else
                        draw.SimpleText(FormatMoney(weaponData.price).. "P", "DisplayFontText", w - 12, h / 2, Color(255, 155, 155, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end
                else
                    draw.SimpleText("Purchased", "DisplayFontText", w - 12, h / 2, Color(155, 155, 155, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end

                surface.SetDrawColor(255, 255, 255, 55)
                surface.DrawOutlinedRect(0, 0, w, h)
                draw.SimpleText(weaponData.name, "DisplayFontText", 8, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            ShopButton.DoClick = function()
                local swep = weaponData.swep or "m9k_winchester73"
                local weapon = weapons.Get( swep )
                local model = weapon.WorldModel or "error.mdl"
                ctrl:SetModel(model)

                surface.PlaySound(sound_click)

                weaponinfo = index
                if weaponinfo then
                    print("Selected Weapon Name:", ZConfig.shop.weapons[index].name)
                else
                    print("Error: Selected weapon not found in config.")
                end
            end
        end
    end

    // call it when the menu loads
    SortMenuWeapons(0)

    local sortingButtons = {
        {text = "All", sorting = 0, width = 32},
        {text = "Primary", sorting = 1, width = 64},
        {text = "Secondary", sorting = 2, width = 80}
    }

    local active_sorting = 0
    local function CreateSortingButton(parent, xPos, buttonData)
        local button = vgui.Create("DButton", parent)
        button:SetPos(xPos, 8)
        button:SetSize(buttonData.width, 24)
        button:SetText("")

        button.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255, 55)
            surface.DrawLine(0, h - 1, w, h - 1)
            if active_sorting == buttonData.sorting then
                draw.SimpleText(buttonData.text, "DisplayFontText", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(buttonData.text, "DisplayFontText", w / 2, h / 2, Color(155, 155, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        button.DoClick = function()
            surface.PlaySound(sound_click)
            active_sorting = buttonData.sorting
            ScrollPanelWeapons:Clear()
            SortMenuWeapons(buttonData.sorting)
        end
    end

    local sorting_xPos = 8
    for _, buttonData in ipairs(sortingButtons) do
        CreateSortingButton(panel.weapons, sorting_xPos, buttonData)
        sorting_xPos = sorting_xPos + buttonData.width + 8
    end

    local BuyButton = vgui.Create( "DButton", panel.weapons )
    BuyButton:SetPos(panel.weapons:GetWide() - 192, panel.weapons:GetTall() - 64)
    BuyButton:SetSize(128, 32)
    BuyButton:SetText("")
    BuyButton.Paint = function(self, w, h)
        if ZConfig.shop.weapons[weaponinfo] then
            if !LocalPlayer():HasBoughtWeapon(weaponinfo) then
                if LocalPlayer():CanAfford(ZConfig.shop.weapons[weaponinfo].price) then
                    surface.SetDrawColor(55, 55, 55, 155)
                    if self:IsHovered() then
                        surface.SetDrawColor(155, 255, 155, 255)
                    end
                    surface.SetMaterial(mat_grad_down)
                    surface.DrawTexturedRect(0, 0, w, h)
                    surface.SetDrawColor(0, 0, 0, 155)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(255, 255, 255, 55)
                    surface.DrawOutlinedRect(0, 0, w, h)
                    draw.SimpleText("Buy", "DisplayFontText", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(0, 0, 0, 155)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(255, 255, 255, 55)
                    surface.DrawOutlinedRect(0, 0, w, h)
                    surface.SetDrawColor(55, 55, 55, 155)
                    surface.SetMaterial(mat_local_lock)
                    surface.DrawTexturedRect(w / 2 - 10, h / 2 - 10, 20, 20)
                end
            else
                draw.SimpleText("Purchased", "DisplayFontText", w / 2, h / 2, Color(155, 155, 155, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
    BuyButton.DoClick = function()
        if LocalPlayer():CanAfford(ZConfig.shop.weapons[weaponinfo].price) then
            if !LocalPlayer():HasBoughtWeapon(weaponinfo) then
                Shop:Remove()
                net.Start("NetBuyWeapon")
                net.WriteInt(weaponinfo, 16)
                net.SendToServer()
            end
        end
    end

    // CLASSES_______________________________________________________________________________________

    local ScrollPanelClasses = vgui.Create("DScrollPanel", panel.classes)
    ScrollPanelClasses:SetPos(0, 16)
    ScrollPanelClasses:SetSize(panel.classes:GetWide(), panel.classes:GetTall() - 16)
    ScrollPanelClasses.Paint = function(self, w, h)
        return
    end
    local ClassList = vgui.Create( "DIconLayout", ScrollPanelClasses )
    ClassList:Dock( FILL )
    ClassList:DockMargin(16, 0, 16, 0)
    ClassList:SetSpaceY( 4 )
    ClassList:SetSpaceX( 4 )

    local ListLabel = ClassList:Add( "DLabel" )
    ListLabel.OwnLine = true
    ListLabel:SetSize(128, 32)
    ListLabel:SetFont("DisplayFontHeader")
    ListLabel:SetColor( Color(255, 55, 55) )
    ListLabel:SetText( "Zombies" )

    for index, data in SortedPairsByMemberValue(ZConfig.classes.zombies, "level", false) do
        local model = data.model or "models/player/combine_super_soldier.mdl"

        local icon = ClassList:Add( "DModelPanel" )
        icon:SetSize(128,128)
        icon:SetModel( model )
        function icon:LayoutEntity( Entity ) return end
        if IsValid(icon.Entity) then
            local headBone = icon.Entity:LookupBone("ValveBiped.Bip01_Head1")
            if headBone then
                local headpos = icon.Entity:GetBonePosition(headBone)
                if headpos then
                    icon:SetLookAt(headpos)
                    icon:SetCamPos(headpos - Vector(-25, 0, 0))
                end
            end
            if LocalPlayer():GetLevel() < data.level then
                icon.Entity:SetMaterial("models/rendertarget")
            end
        end

        local Button = vgui.Create("DButton", icon)
        Button:Dock( FILL )
        Button:SetText( "" )
        Button.Paint = function(self, w, h)
            if LocalPlayer():GetLevel() >= data.level then
                surface.SetDrawColor(0, 0, 0, 155)
                surface.DrawRect(0, h - 32, w, 32)
                draw.SimpleText(data.name, "DisplayFontHUD", w / 2, h - 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            else
                surface.SetDrawColor(155, 155, 155, 255)
                surface.SetMaterial(mat_local_lock)
                surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
                draw.SimpleText(data.level, "DisplayFontHUD", w / 2, h - 4, Color(155, 155, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
            if index == LocalPlayer():GetZombieClass() then
                surface.SetDrawColor(255, 55, 55, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            else
                surface.SetDrawColor(255, 55, 55, 15)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
        end
        Button.DoClick = function()
            if LocalPlayer():GetLevel() >= data.level then
                net.Start("NetSelectClassZombie")
                net.WriteInt(index, 16)
                net.SendToServer()
                if index ~= LocalPlayer():GetZombieClass() then
                    surface.PlaySound(sound_click)
                end
            end
        end
        local InfoBox = vgui.Create("DPanel")
        local desc = data.desc
        surface.SetFont("DisplayFontText")
        local desc_length = surface.GetTextSize(desc)
        InfoBox:SetSize(desc_length + 16, 146)
        InfoBox:SetText("")
        InfoBox:SetDrawOnTop(true)
        InfoBox:SetVisible(false)
        InfoBox.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 225)
            surface.DrawRect(0, 0, w, h)

            local name = data.name
            local desc = data.desc
            local speed = data.speed
            local health = data.health

            draw.SimpleText(name, "DisplayFontHeader", 8, 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(desc, "DisplayFontText", 8, 40, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            surface.SetDrawColor(155, 155, 155, 55)
            surface.DrawOutlinedRect(0, 0, w, h)

            draw.SimpleText("Speed", "DisplayFontText", 8, 76, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local speed_bar = ( speed / 400 ) * 128
            surface.SetDrawColor(75, 75, 75, 255)
            surface.DrawRect(8, 96, 128, 8)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(8, 96, speed_bar, 8)

            draw.SimpleText("Health", "DisplayFontText", 8, 128 - 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local health_bar = math.Clamp( ( health / 500 ) * 128, 0, 128 )
            surface.SetDrawColor(75, 75, 75, 255)
            surface.DrawRect(8, 128, 128, 8)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(8, 128, health_bar, 8)
        end

        Button.OnCursorEntered = function()
            InfoBox:SetVisible(true)
        end

        Button.OnCursorExited = function()
            InfoBox:SetVisible(false)
        end

        Button.Think = function()
            if InfoBox:IsVisible() then
                local x, y = gui.MousePos()
                InfoBox:SetPos(x + 12, y + 12)
            end
        end

        Button.OnRemove = function()
            InfoBox:Remove()
        end
    end

    local ListLabel = ClassList:Add( "DLabel" )
    ListLabel.OwnLine = true
    ListLabel:SetSize(128, 32)
    ListLabel:SetFont("DisplayFontHeader")
    ListLabel:SetText( "Humans" )

    for index, data in SortedPairsByMemberValue(ZConfig.classes.humans, "level", false) do
        local model = data.model or "models/player/combine_super_soldier.mdl"

        local icon = ClassList:Add( "DModelPanel" )
        icon:SetSize(128,128)
        icon:SetModel( model )
        function icon:LayoutEntity( Entity ) return end
        if IsValid(icon.Entity) then
            local headBone = icon.Entity:LookupBone("ValveBiped.Bip01_Head1")
            if headBone then
                local headpos = icon.Entity:GetBonePosition(headBone)
                if headpos then
                    icon:SetLookAt(headpos)
                    icon:SetCamPos(headpos - Vector(-25, 0, 0))
                end
            end
            if LocalPlayer():GetLevel() < data.level then
                icon.Entity:SetMaterial("models/rendertarget")
            end
        end

        local Button = vgui.Create("DButton", icon)
        Button:Dock( FILL )
        Button:SetText( "" )
        Button.Paint = function(self, w, h)
            if LocalPlayer():GetLevel() >= data.level then
                surface.SetDrawColor(0, 0, 0, 155)
                surface.DrawRect(0, h - 32, w, 32)
                draw.SimpleText(data.name, "DisplayFontHUD", w / 2, h - 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            else
                surface.SetDrawColor(155, 155, 155, 255)
                surface.SetMaterial(mat_local_lock)
                surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
                draw.SimpleText(data.level, "DisplayFontHUD", w / 2, h - 4, Color(155, 155, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
            if index == LocalPlayer():GetHumanClass() then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            else
                surface.SetDrawColor(255, 255, 255, 15)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
        end
        Button.DoClick = function()
            if LocalPlayer():GetLevel() >= data.level then
                net.Start("NetSelectClassHuman")
                net.WriteInt(index, 16)
                net.SendToServer()
                if index ~= LocalPlayer():GetHumanClass() then
                    surface.PlaySound(sound_click)
                end
            end
        end

        local InfoBox = vgui.Create("DPanel")
        local desc = data.desc
        surface.SetFont("DisplayFontText")
        local desc_length = surface.GetTextSize(desc)
        InfoBox:SetSize(desc_length + 16, 146)
        InfoBox:SetText("")
        InfoBox:SetDrawOnTop(true)
        InfoBox:SetVisible(false)
        InfoBox.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 225)
            surface.DrawRect(0, 0, w, h)

            local name = data.name
            local desc = data.desc
            local speed = data.speed
            local health = data.health or 100

            draw.SimpleText(name, "DisplayFontHeader", 8, 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(desc, "DisplayFontText", 8, 40, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            surface.SetDrawColor(155, 155, 155, 55)
            surface.DrawOutlinedRect(0, 0, w, h)

            draw.SimpleText("Speed", "DisplayFontText", 8, 76, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local speed_bar = ( speed / 240 ) * 128
            surface.SetDrawColor(75, 75, 75, 255)
            surface.DrawRect(8, 96, 128, 8)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(8, 96, speed_bar, 8)

            draw.SimpleText("Health", "DisplayFontText", 8, 128 - 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local health_bar = ( health / 200 ) * 128
            surface.SetDrawColor(75, 75, 75, 255)
            surface.DrawRect(8, 128, 128, 8)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(8, 128, health_bar, 8)
        end

        Button.OnCursorEntered = function()
            InfoBox:SetVisible(true)
        end

        Button.OnCursorExited = function()
            InfoBox:SetVisible(false)
        end

        Button.Think = function()
            if InfoBox:IsVisible() then
                local x, y = gui.MousePos()
                InfoBox:SetPos(x + 12, y + 12)
            end
        end

        Button.OnRemove = function()
            InfoBox:Remove()
        end
    end

    // BADGES________________________________________________________________________________________________
    local ScrollPanelBadges = vgui.Create("DScrollPanel", panel.badges)
    ScrollPanelBadges:SetPos(16, 16)
    ScrollPanelBadges:SetSize(panel.badges:GetWide() - 32, panel.badges:GetTall() - 32)
    ScrollPanelBadges.Paint = function(self, w, h)
        return
    end

    local sbar = ScrollPanelBadges:GetVBar()
    function sbar:Paint(w, h)
        return
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(155, 155, 155, 155)
        surface.DrawRect(0, 0, 1, h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(155, 155, 155, 155)
        surface.DrawRect(0, 0, 1, h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(155, 155, 155, 155)
        surface.DrawRect(0, 0, 1, h)
    end

    for k, v in pairs(ZConfig.badges) do
        local Panel = ScrollPanelBadges:Add( "DPanel" )
        Panel:Dock( TOP )
        Panel:SetTall(64)
        Panel:DockMargin( 0, 0, 0, 16 )
        Panel.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 225)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(212, 175, 55, 255)
            surface.DrawOutlinedRect(0, 0, w, h)

            surface.SetDrawColor(212, 175, 55)
            surface.SetMaterial(v.png)
            surface.DrawTexturedRect(8, 8, 48, 48)

            draw.SimpleText(v.title, "DisplayFontHeader", 70, h / 2, Color(212, 175, 55), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(v.desc, "DisplayFontText", w / 2, h / 2, Color(155, 155, 155, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    // OVERVIEW__________________________________________________________________________________
    /*
    local mdl = vgui.Create( "DModelPanel", panel.overview )
    mdl:Dock(FILL)
    mdl:SetModel("models/player/combine_super_soldier.mdl")

    function mdl:LayoutEntity(ent)
        ent:SetSequence(ent:LookupSequence("menu_gman"))
        mdl:RunAnimation()		
        return
    end

    local eyepos = mdl.Entity:GetBonePosition(mdl.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    eyepos:Add(Vector(0, 0, 2))	-- Move up slightly
    mdl:SetLookAt(eyepos)
    mdl:SetCamPos(eyepos-Vector(-32, 0, 0))
    */

    local TTitle = vgui.Create( "DLabel", panel.overview )
    TTitle:Dock(TOP)
    TTitle:DockMargin(8, 4, 0, 0)
    TTitle:SetText( "Model" )

    local pm_selection = vgui.Create( "DComboBox", panel.overview )
    pm_selection:Dock(TOP)
    pm_selection:DockMargin(4, 0, 4, 4)
    pm_selection:SetValue( "Model: 1" )
    pm_selection:SetTextColor(color_white)
    pm_selection.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 55)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 55)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    /*
    for i=0, 10 do
        pm_selection:AddChoice( "Model: ".. i )
    end
    */

    local TTitle = vgui.Create( "DLabel", panel.overview )
    TTitle:Dock(TOP)
    TTitle:DockMargin(8, 0, 0, 0)
    TTitle:SetText( "Primary" )

    local wep_selection = vgui.Create( "DComboBox", panel.overview )
    wep_selection:Dock(TOP)
    wep_selection:DockMargin(4, 0, 4, 4)
    wep_selection:SetTextColor(color_white)
    wep_selection.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 55)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 55)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local default_primary = ZConfig.shop.weapons[tonumber(LocalPlayer():GetPData("primary_weapon_index", 1))].name
    wep_selection:SetValue( default_primary, tonumber(LocalPlayer():GetPData("primary_weapon_index", 1)) )
    for index, data in ipairs(ZConfig.shop.weapons) do
        if LocalPlayer():HasBoughtWeapon(index) then
            if data.slot == 1 then
                wep_selection:AddChoice( data.name, index )
            end
        end
    end

    wep_selection.OnSelect = function( self, index, value, data )
        if tonumber(LocalPlayer():GetPData("primary_weapon_index", 1)) == data then return end
        if LocalPlayer():HasBoughtWeapon(data) then
            LocalPlayer():SetPData("primary_weapon_index", data)
            net.Start("NetEquipPrimary")
            net.WriteInt(data, 16)
            net.SendToServer()
        end
    end

    local TTitle = vgui.Create( "DLabel", panel.overview )
    TTitle:Dock(TOP)
    TTitle:DockMargin(8, 0, 0, 0)
    TTitle:SetText( "Secondary" )

    local wep_selection2 = vgui.Create( "DComboBox", panel.overview )
    wep_selection2:Dock(TOP)
    wep_selection2:DockMargin(4, 0, 4, 4)
    wep_selection2:SetTextColor(color_white)
    wep_selection2.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 55)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 55)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local default_secondary = ZConfig.shop.weapons[tonumber(LocalPlayer():GetPData("secondary_weapon_index", 2))].name
    wep_selection2:SetValue( default_secondary, tonumber(LocalPlayer():GetPData("secondary_weapon_index", 2)) )
    for index, data in ipairs(ZConfig.shop.weapons) do
        if LocalPlayer():HasBoughtWeapon(index) then
            if data.slot == 2 then
                wep_selection2:AddChoice( data.name, index )
            end
        end
    end

    wep_selection2.OnSelect = function( self, index, value, data )
        if tonumber(LocalPlayer():GetPData("secondary_weapon_index", 2)) == data then return end
        if LocalPlayer():HasBoughtWeapon(data) then
            LocalPlayer():SetPData("secondary_weapon_index", data)
            net.Start("NetEquipSecondary")
            net.WriteInt(data, 16)
            net.SendToServer()
        end
    end
end

//______________ DEV