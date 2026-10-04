shader_type canvas_item;

varying float global_y;

void vertex() {
    global_y = (CANVAS_MATRIX * MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (global_y > 500.0) {
        tex_color.a = 0.0;
    }
    
    COLOR = tex_color;
}
