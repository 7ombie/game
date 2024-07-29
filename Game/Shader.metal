#include <metal_stdlib>

using namespace metal;

#define TILE_SIZE 32

struct Uniforms {
    int zoom;
    int2 camera;
    int2 gridSize;
};

int invert(int coordinate) {

    return TILE_SIZE - 1 - coordinate;
}

#define POSITION const float4 position[[position]]
#define UNIFORMS const constant Uniforms &uniforms[[buffer(1)]]
#define TILESET const texture2d<half> tileset[[texture(0)]]
#define TILEMAP constant ushort *tilemap[[buffer(0)]]

fragment half4 tile(POSITION, UNIFORMS, TILESET, TILEMAP) {

    constexpr sampler sampler(filter::nearest, coord::pixel);

    int2 extremes = uniforms.gridSize * TILE_SIZE;
    int2 location = (uniforms.camera * uniforms.zoom + int2(position.xy)) / uniforms.zoom;
    int2 internal = location % TILE_SIZE;

    if (location.x >= extremes.x || location.y >= extremes.y) return tileset.sample(sampler, float2(internal));

    int2 tilewise = location / TILE_SIZE;
    uint tileData = uint(tilemap[tilewise.y * uniforms.gridSize.x + tilewise.x]);

    if (tileData & 1) internal.x = invert(internal.x);                      // flip left-to-right
    if (tileData & 2) internal.y = invert(internal.y);                      // flip top-to-bottom
    if (tileData & 4) internal = int2(internal.y, invert(internal.x));      // rotate 90 degrees

    float2 samplePoint = float2((tileData >> 3) * TILE_SIZE + internal.x, internal.y);

    return tileset.sample(sampler, samplePoint);
}
