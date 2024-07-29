#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float4 position[[attribute(0)]];
};

vertex float4 canvas(Vertex in[[stage_in]]) {
    return in.position;
}
