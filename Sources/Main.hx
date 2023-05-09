
import kha.Assets;
import kha.System;

class Main {

	static function main() {
        System.start({title: "ZuiThemeEditor", width: 1280, height: 720}, window -> {
            Assets.loadEverything(() -> {
                new zui.ThemeEditor();
            });
        });
	}
}
