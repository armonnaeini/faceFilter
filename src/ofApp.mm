#include "ofApp.h"
using namespace ofxARKit::common;
using namespace ofxCv;

//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    ARFaceTrackingConfiguration *configuration = [ARFaceTrackingConfiguration new];
    
    [session runWithConfiguration:configuration];
    
    this->session = session;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
}

vector <ofPrimitiveMode> primModes;
int currentPrimIndex;

//--------------------------------------------------------------
void ofApp::setup() {

    ofBackground(0);
    ofClear(255, 255, 255, 0); // 0 is important
    
    ofSetFrameRate(60);
    ofEnableDepthTest();

    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;

    processor = ARProcessor::create(session);
    processor->setup();
    
   
    mesh.setMode(OF_PRIMITIVE_TRIANGLES);

    ofSetFrameRate(60);
    
    verandaFont.load("fonts/verdana.ttf", 30);

    shader.load("shader.vert", "shader.frag");

    
    //==== CV STUFF ====//
    
    /*
    cam.setDeviceID(1);
    cam.setup(500, 500);
     */
    
    nearThreshold = 120; //the higher the better
    farThreshold = 90; //the lower the better
    
    colorImg.allocate(cam.getWidth(), cam.getHeight(), OF_IMAGE_COLOR);
    grayImage.allocate(cam.getWidth(), cam.getHeight(), OF_IMAGE_GRAYSCALE);
    grayThreshNear.allocate(cam.getWidth(), cam.getHeight(), OF_IMAGE_GRAYSCALE);
    grayThreshFar.allocate(cam.getWidth(), cam.getHeight(), OF_IMAGE_GRAYSCALE);
    grayPreprocImage.allocate(cam.getWidth(), cam.getHeight(), OF_IMAGE_GRAYSCALE);
    contourFinder.setFindHoles(true);
    contourFinder.setMinAreaRadius(25); //75
    contourFinder.setMaxAreaRadius(300);
    contourFinder.getTracker().setPersistence(15);
    
    vector<ofColor> col;
    last = ofGetElapsedTimeMillis();
    newColor.setHsb(0,255,255);
    img.load("liquid.png");

}

//--------------------------------------------------------------
void ofApp::update(){
    processor->update();
    processor->updateFaces();
    updateColor();

    counter2 = counter2 + 0.09f;

    //cvify();
}

void ofApp::cvify(){
    cam.update();
    
    if(cam.isFrameNew()) {
        grayImage.setFromPixels(cam.getPixels());
        threshold(grayImage, grayThreshNear, nearThreshold, true);
        threshold(grayImage, grayThreshFar, farThreshold);
        cv::Mat grayThreshNearMat = toCv(grayThreshNear);
        cv::Mat grayThreshFarMat = toCv(grayThreshFar);
        cv::Mat grayImageMat = toCv(grayImage);
        bitwise_and(grayThreshNearMat, grayThreshFarMat, grayImageMat);
        grayPreprocImage = grayImage;
        dilate(grayImage);
        dilate(grayImage);
        erode(grayImage);
        grayImage.update();
        contourFinder.findContours(grayImage);
        pp = contourFinder.getPolylines();
    }
}

void ofApp::updateColor(){
    if(ofGetElapsedTimeMillis() - last > 25){
        newColor.setHue(counter % 256);
        counter ++;
        last = ofGetElapsedTimeMillis();
    }
}

void drawEachTriangle(ofMesh faceMesh) {
    for (auto face : faceMesh.getUniqueFaces()) {
        ofDrawTriangle(face.getVertex(0), face.getVertex(1), face.getVertex(2));
    }
    ofPopStyle();
}


void drawFaceCircles(ofMesh faceMesh) {
    
    ofPushStyle();
    ofSetColor(0, 0, 255);
    
    auto verts = faceMesh.getVertices();
    for (int i = 0; i < verts.size(); ++i){
        ofDrawCircle(verts[i] * ofVec3f(1, 1, 1), 0.001);
    }
    ofPopStyle();
}



void ofApp::drawCircles(ofMesh faceMesh) {
//    ofPushStyle();
//    ofSetColor(newColor);
    
//    faceMesh.drawWireframe();
    faceMesh.draw();
    
    /*
    auto verts = faceMesh.getVertices();
    float k = 0.0;

    for (int i = 0; i < verts.size(); ++i){
        float height = sin(counter2 + k)/20;
        float width = cos(counter2 + k)/40;
        ofDrawCircle(verts[i] * ofVec3f(1+height, 1, 1), 0.001);
    }*/
//    ofPopStyle();
}




void ofApp::drawFaceMeshNormals(ofMesh mesh) {
    vector<ofMeshFace> faces = mesh.getUniqueFaces();
    ofMeshFace face;
    ofVec3f c, n;
    updateColor();
    ofPushStyle();
    ofSetColor(newColor);
    for(unsigned int i = 0; i < faces.size(); i++){
        face = faces[i];
        c = calculateCenter(&face);
        n = face.getFaceNormal();
//        ofDrawLine(c.x, c.y, c.z, c.x+n.x*normalSize, c.y+n.y*normalSize, c.z+n.z*normalSize);
    }
    
    auto verts = mesh.getVertices();
    float k = 0.0;

    for (int i = 0; i < verts.size(); ++i){
         float height = sin(counter2 + k);
         float width = cos(counter2 + k)/40;
         ofDrawCircle(verts[i] * ofVec3f(1, 1, 1), 0.0015);
        if (i > 0){
//            ofDrawCircle(verts[i-1] * ofVec3f(1, 1, 1), 0.001);
        }

    }
    ofPopStyle();
}



void ofApp::printInfo() {
    std::string infoString = std::string("Current mode: ") + std::string(bDrawTriangles ? "mesh triangles" : "circles");
    infoString += "\nNormals: " + std::string(bDrawNormals ? "on" : "off");
    infoString += std::string("\n\nTap ASDFASDFASDF.");
    infoString += "\nTap left side of the screen to toggle normals.";
    verandaFont.drawString(infoString, 10, ofGetHeight() * 0.85);
}


//--------------------------------------------------------------
void ofApp::draw() {
    
    ofDisableDepthTest();
    shader.begin();
    processor->draw();
    
    /*
    for (int i = 0; i < contourFinder.size(); i++){
             ofPolyline temp = contourFinder.getPolyline(i);
             temp = temp.getSmoothed(10);
             temp.draw();

     }*/
    
    camera.begin();
    processor->setARCameraMatrices();
  
    
    for (auto & face : processor->getFaces()){
        ofFill();
        ofMatrix4x4 temp = toMat4(face.raw.transform);

        ofPushMatrix();
        ofMultMatrix(temp);
        
        mesh.addVertices(face.vertices);
        mesh.addTexCoords(face.uvs);
        mesh.addIndices(face.indices);
        
        if (bDrawTriangles) {
//            drawEachTriangle(mesh);
        } else {
//            drawCircles(mesh);
//            img.bind();
          
            shader.begin();
            shader.setUniform1f("time", ofGetElapsedTimef());
            mesh.draw();
            shader.end();
//            img.unbind();
//            drawFaceCircles(mesh);
        }
        
        if (bDrawNormals) {
            shader.begin();


            shader.setUniform1f("time", ofGetElapsedTimef());

            drawFaceMeshNormals(mesh);
//            mesh.drawWireframe();
            shader.end();

        }

        mesh.clear();
        
        ofPopMatrix();
    }
    camera.end();
    
    printInfo();
}

void ofApp::exit() {}

void ofApp::touchDown(ofTouchEventArgs &touch){
    if (touch.x > ofGetWidth() * 0.5) {
        bDrawTriangles = !bDrawTriangles;
    } else if (touch.x < ofGetWidth() * 0.5) {
        bDrawNormals = !bDrawNormals;
    }
}

void ofApp::touchMoved(ofTouchEventArgs &touch){}

void ofApp::touchUp(ofTouchEventArgs &touch){}

void ofApp::touchDoubleTap(ofTouchEventArgs &touch){}

void ofApp::lostFocus(){}

void ofApp::gotFocus(){}

void ofApp::gotMemoryWarning(){}

void ofApp::deviceOrientationChanged(int newOrientation){
    processor->deviceOrientationChanged(newOrientation);
}

void ofApp::touchCancelled(ofTouchEventArgs& args){}


