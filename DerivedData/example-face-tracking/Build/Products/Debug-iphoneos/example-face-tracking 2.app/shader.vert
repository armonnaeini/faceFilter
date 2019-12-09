
// these are for the programmable pipeline system
uniform mat4 modelViewProjectionMatrix;
attribute vec4 position;

uniform float time;


void main()
{

    float displacementHeight = .03; //.05
    float displacementY = sin(time + (position.z / 1.)*100.) * displacementHeight;
//    position.y = sin(time + position.y) * displacementHeight;
    
    vec4 modifiedPosition = modelViewProjectionMatrix * position;
    modifiedPosition.y += sin(1.5*time + position.y*35.)*displacementHeight; //sin(SPEED*time + position.y*INTENSITY
     modifiedPosition.x += sin(1.5*time + position.x*45.)*displacementHeight; //sin(SPEED*time + position.y*INTENSITY
    gl_Position = modifiedPosition;

}
