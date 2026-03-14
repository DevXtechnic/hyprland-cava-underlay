#version 330 core
uniform int gradient_colors_size;
uniform vec4 gradient_colors[256];
uniform vec2 WindowSize;
out vec4 fragColor;
void main() {
    if (gradient_colors_size <= 1) {
        fragColor = gradient_colors[0];
    } else {
        // Map the gradient to the window height. 
        // We use gl_FragCoord.y / WindowSize.y to get a [0.0, 1.0] range.
        float t = gl_FragCoord.y / WindowSize.y;
        
        // Use the full 0.0 to 1.0 range since the surface itself 
        // is now just a small strip at the bottom.
        float findex = t * float(gradient_colors_size - 1);
        
        int index = int(findex);
        float step = findex - float(index);
        
        if (index >= gradient_colors_size - 1) {
            index = gradient_colors_size - 2;
            step = 1.0;
        }
        if (index < 0) {
            index = 0;
            step = 0.0;
        }
        
        fragColor = mix(gradient_colors[index], gradient_colors[index + 1], step);
    }
}
