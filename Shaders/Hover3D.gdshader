shader_type canvas_item;

uniform float _tilt_Scale = 0.5;
uniform bool _isSpecularLight = false;
uniform float _speularLightIntensity = 0.5;
uniform float _speularLightPower = 3.0;
uniform vec2 _mousePos;

varying vec2 texCoord;
varying float fragPerspective;
varying vec2 mouseoffset;

void vertex() {
    // Normalize texture coordinates
    texCoord = VERTEX.xy * TEXTURE_PIXEL_SIZE;

    // Center the coordinates around the origin
    vec2 centeredCoord = texCoord - vec2(0.5, 0.5);
	vec2 mouse_centered = ((_mousePos + 0.5/TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE) * 2.0 - 1.0;
	mouseoffset = mouse_centered / 2.0;

    // Rotation matrices around the x, y, and z axes	
    float cosX = cos(mouse_centered.y * _tilt_Scale);
    float sinX = sin(mouse_centered.y * _tilt_Scale);
    mat3 rotationX;
    rotationX[0] = vec3(1.0, 0.0, 0.0);
    rotationX[1] = vec3(0.0, cosX, -sinX);
    rotationX[2] = vec3(0.0, sinX, cosX);

    float cosY = cos(-mouse_centered.x * _tilt_Scale);
    float sinY = sin(-mouse_centered.x * _tilt_Scale);
    mat3 rotationY;
    rotationY[0] = vec3(cosY, 0.0, sinY);
    rotationY[1] = vec3(0.0, 1.0, 0.0);
    rotationY[2] = vec3(-sinY, 0.0, cosY);

    float cosZ = cos(0.);
    float sinZ = sin(0.);
    mat3 rotationZ;
    rotationZ[0] = vec3(cosZ, -sinZ, 0.0);
    rotationZ[1] = vec3(sinZ, cosZ, 0.0);
    rotationZ[2] = vec3(0.0, 0.0, 1.0);

    // Combine rotations
    mat3 rotation = rotationZ * rotationY * rotationX;

    // Apply the rotation to the vertex position
    vec3 transformedCoord = rotation * vec3(centeredCoord, 0.0);

    // Apply perspective projection
    float perspective = 1.0 / (1.0 - transformedCoord.z * 0.5);
	float perspective2 = 1.0 / (transformedCoord.z * 0.5);
    transformedCoord.xy *= perspective;		
	texCoord *= perspective;
	fragPerspective = perspective;
	
    // Transform back to screen coordinates
    vec2 screenPosition = transformedCoord.xy + vec2(0.5, 0.5);	
    VERTEX = screenPosition / TEXTURE_PIXEL_SIZE;	    
}

void fragment() {
	//perspective correction of UV
    vec2 finalTexCoord = texCoord / fragPerspective;	
    vec4 texColor = texture(TEXTURE, finalTexCoord);	    
	
	//sepcular light
	float colvalue = pow(clamp(1.0 - length(finalTexCoord - 0.5 + mouseoffset), 0.0, 1.0), _speularLightPower) * _speularLightIntensity;
	vec3 specularCol = vec3(colvalue, colvalue, colvalue);
    
	if(_isSpecularLight)   
    	COLOR = texColor + vec4(specularCol, 0.0);
	else
		COLOR = texColor;
}