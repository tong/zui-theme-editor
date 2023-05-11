
import haxe.Json;
import haxe.io.Bytes;
import kha.Assets;
import kha.Framebuffer;
import kha.System;
import zui.Id;
import zui.Themes;
import zui.Zui;

using StringTools;
using zui.Ext;

class Main {

    static var theme_editor: TTheme;
    static var theme: TTheme;

    static function createTheme(name:String) {
        return  {
            NAME: name,
            WINDOW_BG_COL: 0xff292929,
            WINDOW_TINT_COL: 0xffffffff,
            ACCENT_COL: 0xff393939,
            ACCENT_HOVER_COL: 0xff434343,
            ACCENT_SELECT_COL: 0xff505050,
            BUTTON_COL: 0xff383838,
            BUTTON_TEXT_COL: 0xffe8e7e5,
            BUTTON_HOVER_COL: 0xff494949,
            BUTTON_PRESSED_COL: 0xff1b1b1b,
            TEXT_COL: 0xffe8e7e5,
            LABEL_COL: 0xffc8c8c8,
            SEPARATOR_COL: 0xff202020,
            HIGHLIGHT_COL: 0xff205d9c,
            CONTEXT_COL: 0xff222222,
            PANEL_BG_COL: 0xff3b3b3b,
            FONT_SIZE: 16,
            ELEMENT_W: 100,
            ELEMENT_H: 24,
            ELEMENT_OFFSET: 4,
            ARROW_SIZE: 5,
            BUTTON_H: 22,
            CHECK_SIZE: 15,
            CHECK_SELECT_SIZE: 8,
            SCROLL_W: 9,
            TEXT_OFFSET: 8,
            TAB_W: 6,
            FILL_WINDOW_BG: false,
            FILL_BUTTON_BG: true,
            FILL_ACCENT_BG: false,
            LINK_STYLE: Line,
            FULL_TABS: false
        }
    }

    var editor: Zui;
    var preview: Zui;

    public function new() {
        theme = createTheme('theme');
        theme_editor = createTheme('theme_editor');
        final font = Assets.fonts.jetbrains;
        editor = new Zui({font: font, theme: theme_editor});
        preview = new Zui({font: font, theme: theme });
        preview.alwaysRedraw = true;
        kha.System.notifyOnFrames(render);
    }

    function render(framebuffers: Array<Framebuffer>) {

        final g = framebuffers[0].g2;
        final windowWidth = System.windowWidth();
        final windowHeight = System.windowHeight();

        editor.begin(g);

        var htab = Id.handle({selected: true});
		htab.redraws = 1;
        if(editor.window(htab, 0, 0, 500, windowHeight, false)) {
            if(editor.tab(Id.handle({selected: true}), "Editor")) {

                theme.NAME = editor.textInput(Id.handle({text: theme.NAME}), 'NAME');

                editor.indent();

                editor.separator(4, false);

                theme.WINDOW_BG_COL = Std.parseInt('0x'+editor.textInput(Id.handle({text: theme.WINDOW_BG_COL.hex()}), "WINDOW_BG_COL"));
                theme.WINDOW_TINT_COL = Std.parseInt('0x'+editor.textInput(Id.handle({text: theme.WINDOW_TINT_COL.hex()}), "WINDOW_TINT_COL"));
                theme.BUTTON_COL = Std.parseInt('0x'+editor.textInput(Id.handle({text: theme.BUTTON_COL.hex()}), "BUTTON_COL"));
                theme.ACCENT_COL = Std.parseInt('0x'+editor.textInput(Id.handle({text: theme.ACCENT_COL.hex()}), "ACCENT_COL"));
                theme.ACCENT_HOVER_COL = Std.parseInt('0x'+editor.textInput(Id.handle({text: theme.ACCENT_COL.hex()}), "ACCENT_COL"));
                //theme.ACCENT_COL = editor.colorWheel(Id.handle(), true, 400, 40, true, ()->{
                 //   trace('cccc');
                //});

                editor.separator(4, true); 

                theme.BUTTON_H = Std.int(editor.slider( Id.handle({ text: ""+theme.BUTTON_H, value: theme.BUTTON_H }), "BUTTON_H", 0, 128, true, 1 ));
                theme.ELEMENT_W = Std.int(editor.slider( Id.handle({ text: ""+theme.ELEMENT_W, value: theme.ELEMENT_W }), "ELEMENT_W", 0, 1024, true, 1 ));
                theme.ELEMENT_H = Std.int(editor.slider( Id.handle({ value: theme.ELEMENT_H }), "ELEMENT_H", 0, 128, true, 1 ));
                theme.ELEMENT_OFFSET = Std.int(editor.slider( Id.handle({ text: ""+theme.ELEMENT_OFFSET, value: theme.ELEMENT_OFFSET }), "ELEMENT_OFFSET", 0, 128, true, 1 ));
                theme.SCROLL_W = Std.int(editor.slider( Id.handle({ text: ""+theme.SCROLL_W, value: theme.SCROLL_W }), "SCROLL_W", 0, 128, true, 1 ));
                theme.TEXT_OFFSET = Std.int(editor.slider( Id.handle({ text: ""+theme.TEXT_OFFSET, value: theme.TEXT_OFFSET }), "TEXT_OFFSET", 0, 128, true, 1 ));

                editor.separator(4, true); 

                theme.FONT_SIZE = Std.int(editor.slider( Id.handle({ text: ""+theme.FONT_SIZE, value: theme.FONT_SIZE }), "FONT_SIZE", 0, 128, true, 1 ));
                theme.CHECK_SIZE = Std.int(editor.slider(Id.handle(Id.handle({value: theme.CHECK_SIZE})), "CHECK_SIZE", 0, 128, true, 1));
                theme.CHECK_SELECT_SIZE = Std.int(editor.slider(Id.handle(Id.handle({value: theme.CHECK_SELECT_SIZE})), "CHECK_SELECT_SIZE", 0, 128, true, 1));
                theme.TAB_W = Std.int(editor.slider( Id.handle({ text: ""+theme.TAB_W, value: theme.TAB_W }), "TAB_W", 0, 128, true, 1 ));

                editor.separator(4, true);

                theme.FILL_WINDOW_BG = editor.check(Id.handle(), "FILL_WINDOW_BG");
                theme.FILL_BUTTON_BG = editor.check(Id.handle(), "FILL_BUTTON_BG");
                theme.FILL_ACCENT_BG = editor.check(Id.handle(), "FILL_ACCENT_BG");
                theme.FULL_TABS = editor.check(Id.handle(), "FULL_TABS");

                theme.LINK_STYLE = editor.combo(Id.handle(), ["Line", "??"], "LINK_STYLE", true);

                editor.separator(10, true);

                editor.unindent();

                editor.row([1/2, 1/2]);
                if(editor.button("Save")) {
                    var json = Json.stringify(preview.t, "  ");
                    trace(json);
                    #if kha_krom
                    var path = "theme.json";
                    Krom.log(json);
                    Krom.fileSaveBytes(path, Bytes.ofString(json).getData());
                    Krom.log('Saved to $path');
                    #end
                }
                if(editor.button("Quit")) System.stop();

                //editor.textArea(Id.handle({ text: json }), Left, false, "", true);

                editor.separator(10, true);
            }
        }

        editor.end();

        preview.begin(g);
        var htab = Id.handle();
		htab.redraws = 1;
        if(preview.window(htab, 520, 20, 400, 600, true)) {
            if(preview.tab(Id.handle({selected: true}), "Preview")) {
                if(preview.panel(Id.handle({selected: true}), 'Preview')) {
                    preview.indent();
                    //preview.text('Name: Custom');
                    //preview.textInput(Id.handle({text: StringTools.hex(theme.WINDOW_BG_COL)}), "WINDOW_BG_COL");
                    //preview.textArea(Id.handle(), Left, true, JsonPrinter.print(theme,'\t'));
                    preview.text('Text');
                    preview.button('Button');
                    preview.row([1/3, 1/3, 1/3]);
                    preview.button('A');
                    preview.button('B');
                    preview.button('C');
                    //preview.image(Assets.images.armory);
                    preview.textInput(Id.handle(), 'TextInput');
                    preview.check(Id.handle(), 'Check');
                    preview.combo(Id.handle(), ["Item 1", "Item 2", "Item 3"], 'Combo');
                    preview.slider(Id.handle(), 'Slider 1', 0, 100, true);
                    preview.slider(Id.handle(), 'Slider 2', 0, 100, true);
                    preview.slider(Id.handle(), 'Slider 3', 0, 100, true);
                    preview.check(Id.handle(), 'Check', "Label");
                    for(i in 1...23) {
                        if(i % 2 == 0) preview.separator(1, false);
                        else preview.separator(23-i);
                    }
                    preview.separator(1, false);
                    //preview.tooltip("Tooltip");
                    //preview.tooltipImage(Assets.images.armory);
                    preview.unindent();
                }
            }
        }

        preview.end();
    }

	static function main() {
        System.start({title: "ZuiThemeEditor", width: 1280, height: 720}, window -> {
            Assets.loadEverything(() -> new Main());
        });
	}
}
