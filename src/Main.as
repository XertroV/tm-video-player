void Main() {
    LoadConfig();
    startnew(SetupVideos);
}
void OnDestroyed() { MLHook::RemoveAllInjectedML(); }
void OnDisabled() { OnDestroyed(); }

void SetupVideos() {
    string pageCode = GenerateMLPageCode();
    print("SetupVideos:\n" + pageCode);
    if (S_VideosInMenu)
        MLHook::InjectManialinkToMenu("VideoPlayer", pageCode, true);
    if (S_VideosInPG)
        MLHook::InjectManialinkToPlayground("VideoPlayer", pageCode, true);
    if (S_VideosInEditor)
        MLHook::InjectManialinkToEditor("VideoPlayer", pageCode, true);
}

void RefreshVideos() {
    SetupVideos();
}

string GenerateMLPageCode() {
    string[] code = {};//'<manialink name="MLHook_VideoPlayer" version="3">'};
    for (uint i = 0; i < LoadedConfig.Length; i++) {
        code.InsertLast(GenVideoCodeFromConfigRow(LoadedConfig[i], i));
    }
    code.InsertLast('<script><!--');
    code.InsertLast('main() { while (True) { yield; ');
    for (uint i = 0; i < LoadedConfig.Length; i++) {
        code.InsertLast(GenPlayVideoCodeFromConfigRow(LoadedConfig[i], i));
    }
    code.InsertLast(' } }');
    code.InsertLast('--></script>');
    // code.InsertLast('</manialink>');
    return string::Join(code, "\n");
}

string GenPlayVideoCodeFromConfigRow(Json::Value@ row, uint i) {
    // theres a bug in the menu where the video stops playing, so run .Stop and .Play each frame.
    return
        '(Page.GetFirstChild("video'+i+'") as CMlMediaPlayer).Stop();' // declare video'+i+' =
        + '(Page.GetFirstChild("video'+i+'") as CMlMediaPlayer).Play();';
}

string GenVideoCodeFromConfigRow(Json::Value@ row, uint i) {
    int x = int(float(row["x"]));
    int y = int(float(row["y"]));
    int w = int(float(row["width"]));
    int h = int(float(row["height"]));
    string url = row['url'];
    string[] attrs = {'pos="' + x + ' ' + y + '"'};
    attrs.InsertLast('id="video' + i + '"');
    attrs.InsertLast('size="' + w + ' ' + h + '"');
    // attrs.InsertLast('image="' + url + '"');
    attrs.InsertLast('data="' + url + '"');
    attrs.InsertLast('z-index="'+S_ZIndex+'"');
    attrs.InsertLast('play="1" loop="1" music="1" volume="100"');
    // attrs.InsertLast('play="1"');
    // attrs.InsertLast('loop="1"');
    // attrs.InsertLast('music="1"');
    // attrs.InsertLast('volume="0"');
    return "<video " + string::Join(attrs, " ") + " />";
}
