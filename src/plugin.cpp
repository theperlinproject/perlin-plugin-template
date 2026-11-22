// Your plugin. Rename the class if you like; everything else picks up the name from CMakeLists.txt.
// API reference: https://github.com/theperlinproject/perlin-api/tree/main/docs

#include <perlin/perlin.hpp>

#include <mod_settings.hpp> // generated from plugin.json's "settings" at build time

using namespace perlin;

class MyPlugin : public Plugin {
public:
    void registerCommands(Context& ctx) override {
        // /here prints your block position
        ctx.command<"here">("prints your block position", [] {
            if (auto p = game::player())
                (void)act::message("you are at {}", BlockPos(game::position(*p)));
        });
    }

    void onEnable(Context& ctx) override {
        ctx.hud<"hello">(this, &MyPlugin::draw);
    }

    // Any method named after an event is subscribed automatically.
    void onChatReceived(const abi::EventChat& e) {
        if (e.message.contains("creeper"))
            (void)act::toast("someone said creeper");
    }

private:
    void draw(ui::Canvas& g) {
        if (!settings::show_text)
            return;
        g.text(4, 4, "hello from a plugin", {.color = Rgba::gold});
    }
};
PERLIN_REGISTER(MyPlugin)
