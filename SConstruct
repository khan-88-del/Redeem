import os

env = Environment()

# Godot-cpp path
env.Append(CPPPATH=["godot-cpp/include", "godot-cpp/gen/include", "src"])
env.Append(CCFLAGS=["-std=c++17", "-fPIC", "-O3"])

sources = ["src/map_loader.cpp", "src/register_types.cpp"]

# Library target
target_lib = env.SharedLibrary(
    target="bin/libbermuda_native.android.template_release.arm64",
    source=sources
)
