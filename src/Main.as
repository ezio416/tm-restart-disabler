bool         enabled = true;
const string title   = "\\$F60" + Icons::Refresh + "\\$G Show Restart Button";

void RenderMenu() {
    const bool solo = InSoloMap();

    if (!solo) {
        enabled = true;
    }

    if (UI::MenuItem(title, "", enabled, solo)) {
        trace((enabled ? "dis" : "en") + "abling restart button");

        auto App = cast<CTrackMania>(GetApp());
        auto Network = cast<CTrackManiaNetwork>(App.Network);
        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

        if (true
            and CMAP !is null
            and CMAP.UILayers.Length > 1
        ) {
            bool success = false;

            for (int i = CMAP.UILayers.Length - 1; i >= 0; i--) {
                CGameUILayer@ Layer = CMAP.UILayers[i];
                if (Layer is null) {
                    continue;
                }

                if (string(Layer.ManialinkPage).Trim().SubStr(0, 50).Contains("_PauseMenu")) {
                    success = ToggleRestartButton(Layer.LocalPage, !enabled);
                    break;
                }
            }

            if (success) {
                enabled = !enabled;
            } else {
                warn("toggle failed");
            }

        } else {
            warn("CMAP error");
        }
    }
}

bool InSoloMap() {
    auto App = cast<CTrackMania>(GetApp());
    auto Network = cast<CTrackManiaNetwork>(App.Network);

    return true
        and App.RootMap !is null
        and App.CurrentPlayground !is null
        and App.PlaygroundScript !is null
        and Network.ClientManiaAppPlayground !is null
        and cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo).CurGameModeStr != "TM_Campaign_Local"
    ;
}

const bool ToggleRestartButton(CGameManialinkPage@ Page, const bool toggle) {
    if (Page is null) {
        return false;
    }

    try {
        cast<CGameManialinkQuad>(
            cast<CGameManialinkFrame>(
                cast<CGameManialinkFrame>(
                    cast<CGameManialinkFrame>(
                        cast<CGameManialinkFrame>(
                            cast<CGameManialinkFrame>(
                                Page.GetFirstChild("frame-buttons-container")
                            ).GetFirstChild("button-restart")
                        ).GetFirstChild("Trackmania_Button_frame-align")
                    ).GetFirstChild("Trackmania_Button_frame-background")
                ).GetFirstChild("Trackmania_Button_frame-hitbox-clip")
            ).GetFirstChild("ComponentTrackmania_Button_quad-background")
        ).Visible = toggle;

        return true;

    } catch {
        return false;
    }
}
