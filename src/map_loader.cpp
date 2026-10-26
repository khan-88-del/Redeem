#include "map_loader.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void MapLoader::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_map_path", "path"), &MapLoader::set_map_path);
    ClassDB::bind_method(D_METHOD("get_map_path"), &MapLoader::get_map_path);
    ClassDB::bind_method(D_METHOD("load_glb_map"), &MapLoader::load_glb_map);

    ADD_PROPERTY(PropertyInfo(Variant::STRING, "map_path"), "set_map_path", "get_map_path");
}

MapLoader::MapLoader() {
    map_file_path = "user://Bermuda Map 3D Model.glb";
}

MapLoader::~MapLoader() {}

void MapLoader::set_map_path(const String &p_path) {
    map_file_path = p_path;
}

String MapLoader::get_map_path() const {
    return map_file_path;
}

bool MapLoader::load_glb_map() {
    if (!FileAccess::file_exists(map_file_path)) {
        UtilityFunctions::printerr("C++ Error: File not found: ", map_file_path);
        return false;
    }

    Ref<GLTFDocument> gltf_doc;
    gltf_doc.instantiate();

    Ref<GLTFState> gltf_state;
    gltf_state.instantiate();

    Error err = gltf_doc->append_from_file(map_file_path, gltf_state);
    if (err != OK) {
        UtilityFunctions::printerr("C++ Error: Parse failed, code: ", err);
        return false;
    }

    Node *scene_root = gltf_doc->generate_scene(gltf_state);
    if (scene_root) {
        scene_root->set_name("BermudaTerrainNative");
        add_child(scene_root);
        UtilityFunctions::print("C++: Bermuda Map loaded via Native C++!");
        return true;
    }

    return false;
}
