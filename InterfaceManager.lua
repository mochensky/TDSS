local httpService = game:GetService("HttpService")
local InterfaceManager = {}

InterfaceManager.Folder = "TDSS"
InterfaceManager.Settings = {
    Theme = "Darker",
    Acrylic = true,
    Transparency = true,
    MenuKeybind = "RightShift"
}

function InterfaceManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

function InterfaceManager:SetLibrary(library)
    self.Library = library
end

function InterfaceManager:BuildFolderTree()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
end

function InterfaceManager:SaveSettings()
    writefile(self.Folder .. "/options.json", httpService:JSONEncode(self.Settings))
end

function InterfaceManager:LoadSettings()
    local path = self.Folder .. "/options.json"
    if isfile(path) then
        local data = readfile(path)
        local success, decoded = pcall(httpService.JSONDecode, httpService, data)
        if success then
            for i, v in next, decoded do
                self.Settings[i] = v
            end
        end
    end
end

function InterfaceManager:BuildInterfaceSection(tab)
    assert(self.Library, "Must set InterfaceManager.Library")
    local Library = self.Library
    local Settings = self.Settings

    self:LoadSettings()

    local section = tab:AddSection("Interface")

    local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
        Title = "Theme",
        Values = Library.Themes,
        Default = Settings.Theme,
        Callback = function(Value)
            Library:SetTheme(Value)
            Settings.Theme = Value
            InterfaceManager:SaveSettings()
        end
    })

	InterfaceTheme:SetValue(Settings.Theme)

	section:AddToggle("AcrylicToggle", {
		Title = "Acrylic",
		Description = "Graphic quality 8+",
		Default = Settings.Acrylic,

		Callback = function(Value)
			Library:ToggleAcrylic(Value)
			Settings.Acrylic = Value
			InterfaceManager:SaveSettings()
		end
	})

    section:AddToggle("TransparentToggle", {
        Title = "Transparency",
        Default = Settings.Transparency,

        Callback = function(Value)
            Library:ToggleTransparency(Value)
            Settings.Transparency = Value
            InterfaceManager:SaveSettings()
        end
    })

    local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
    MenuKeybind:OnChanged(function()
        Settings.MenuKeybind = MenuKeybind.Value
        InterfaceManager:SaveSettings()
    end)
    Library.MinimizeKeybind = MenuKeybind
end

return InterfaceManager
