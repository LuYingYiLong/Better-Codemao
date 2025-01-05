#include <windows.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/node.hpp>

using namespace godot;

class SystemParams : public Node {
    GDCLASS(SystemParams, Node);

public:
    static void _register_methods() {
        register_method("get_system_theme", &SystemParams::get_system_theme);
    }

    String get_system_theme() {
        BOOL is_dark_mode = FALSE;
        SystemParametersInfo(SPI_GETACTIVEWINDOWTRACKING, 0, &is_dark_mode, 0);
        return is_dark_mode ? "dark" : "light";
    }
};

void initialize_system_params_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
    ClassDB::register_class<SystemParams>();
}

void uninitialize_system_params_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
    GDExtensionBool GDE_EXPORT system_params_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
        init_obj.register_initializer(initialize_system_params_module);
        init_obj.register_terminator(uninitialize_system_params_module);
        init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
        return init_obj.init();
    }
}