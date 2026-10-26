#ifndef MAP_LOADER_H
#define MAP_LOADER_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/gltf_document.hpp>
#include <godot_cpp/classes/gltf_state.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/core/class_db.hpp>

namespace godot {

class MapLoader : public Node3D {
    GDCLASS(MapLoader, Node3D)

private:
    String map_file_path;

protected:
    static void _bind_methods();

public:
    MapLoader();
    ~MapLoader();

    void set_map_path(const String &p_path);
    String get_map_path() const;

    bool load_glb_map();
};

}

#endif
