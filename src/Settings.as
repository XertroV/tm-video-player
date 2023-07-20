[Setting hidden]
string S_SavedConfig = '[{"width":64,"y":80,"url":"https://dl6.webmfiles.org/big-buck-bunny_trailer.webm","x":-160,"height":36}]';
[Setting hidden]
bool S_VideosInMenu = true;
[Setting hidden]
bool S_VideosInPG = true;
[Setting hidden]
bool S_VideosInEditor = true;
[Setting hidden]
int S_ZIndex = 20;

Json::Value@ LoadedConfig = null;
bool configHasChanged = false;

[SettingsTab name="Videos" icon="FileVideoO"]
void S_RenderConfig() {
    bool[] orig = {S_VideosInMenu, S_VideosInPG, S_VideosInEditor};
    S_VideosInMenu = UI::Checkbox("Show in Menu", S_VideosInMenu);
    S_VideosInPG = UI::Checkbox("Show in PG", S_VideosInPG);
    S_VideosInEditor = UI::Checkbox("Show in Editor", S_VideosInEditor);
    S_ZIndex = UI::InputInt("Z-Index", S_ZIndex);
    configHasChanged = configHasChanged
        || orig[0] != S_VideosInMenu
        || orig[1] != S_VideosInPG
        || orig[2] != S_VideosInEditor
        ;


    if (LoadedConfig is null) LoadConfig();

    DrawConfigEditor();

    UI::Separator();

    UI::BeginDisabled(!configHasChanged);
    if (UI::Button("Save & Load Videos")) {
        SaveConfig();
        startnew(RefreshVideos);
    }
    UI::EndDisabled();
}

void LoadConfig() {
    @LoadedConfig = Json::Parse(S_SavedConfig);
    configHasChanged = false;
}

void SaveConfig() {
    S_SavedConfig = Json::Write(LoadedConfig);
    configHasChanged = false;
    Meta::SaveSettings();
}

void DrawConfigEditor() {
    if (UI::Button("Add Video")) {
        LoadedConfig.Add(Json::Object());
        configHasChanged = true;
    }
    for (uint i = 0; i < LoadedConfig.Length; i++) {
        UI::PushID("ce"+i);
        bool changed = DrawConfigEditRow(LoadedConfig[i], i);
        configHasChanged = changed || configHasChanged;
        UI::PopID();
    }
}

bool DrawConfigEditRow(Json::Value@ row, uint i) {
    UI::Separator();
    if (UI::Button("Remove Video " + i)) {
        LoadedConfig.Remove(i);
        return true;
    }
    bool anyChanged = false;
    anyChanged = DrawJsonInputFloatReturnChanged(row, "x", -160) || anyChanged;
    anyChanged = DrawJsonInputFloatReturnChanged(row, "y", 80) || anyChanged;
    anyChanged = DrawJsonInputFloatReturnChanged(row, "width", 32) || anyChanged;
    anyChanged = DrawJsonInputFloatReturnChanged(row, "height", 18) || anyChanged;
    bool urlChanged;
    row["url"] = UI::InputText("URL", row.Get("url", "https://i.imgur.com/tvCfGyT.webm"), urlChanged);
    return anyChanged || urlChanged;
}

bool DrawJsonInputFloatReturnChanged(Json::Value@ row, const string &in key, float _default) {
    float val = row.Get(key, _default);
    float newVal = UI::InputFloat(key, val);
    row[key] = newVal;
    return val != newVal;
}
