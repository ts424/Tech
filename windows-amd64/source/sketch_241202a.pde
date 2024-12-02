int nodeAmount = 300;
float rotateSpeed = 0.01;
float growSpeed = 0.01;
ArrayList<Node> nodeArray = new ArrayList<>();
ArrayList<Link> linkArray = new ArrayList<>();
int linkIndex = 0;
boolean finishedGenerating = false;

int particleCount = 20;
ArrayList<Particle> particles; // For glowing particle effects
float zoom;

void setup() {
  size(800, 800, P3D);
  particles = new ArrayList<>();
  zoom = min(width, height) * 1.2;

  // Initialize nodes
  while (nodeArray.size() < nodeAmount) {
    float alpha = random(TWO_PI);
    float beta = random(TWO_PI);
    float x = sin(alpha) * cos(beta);
    float y = cos(alpha);
    float z = sin(alpha) * sin(beta);
    Node n = new Node(x, y, z);
    nodeArray.add(n);
  }

  // Start generating links
  generateGabrielGraph();
}

void draw() {
  background(0);

  // Translate to center of the canvas
  translate(width / 2, height / 2, -200);

  // Draw heading (inside the globe, fixed)
  drawHeading();

  // Rotate and translate the entire scene for the globe
  pushMatrix();
  rotateX(frameCount * 0.005);
  rotateY(frameCount * 0.01);

  // Draw a skeleton sphere (wireframe)
  drawSkeletonSphere(300);

  // Continue step-by-step link generation
  if (!finishedGenerating) {
    stepGenerateLinks();
  }

  // Update and display nodes and links
  for (Node node : nodeArray) {
    node.rotate();
    node.update();
    node.show();
  }

  for (Link link : linkArray) {
    link.show();
  }

  // Add glowing particle effects for visual enhancement
  for (int i = 0; i < particleCount; i++) {
    particles.add(new Particle(random(-400, 400), random(-400, 400), random(-400, 400)));
  }

  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isOutOfBounds()) {
      particles.remove(i);
    }
  }
  popMatrix();
}

void drawHeading() {
  pushMatrix();

  // Draw "Tarun Singh" at the top with some space
  fill(255, 204, 0); // Golden-yellow color
  textFont(createFont("Georgia", 40)); // Smaller font size for the name
  textAlign(CENTER, BOTTOM); // Align text to the bottom to position it correctly
  text("Innovate, Create, Dominate!", 0, -350); // Adjusted Y position for space from top

  // Draw "TechFest 2024" in the center
  textFont(createFont("Georgia", 72)); // Larger font size for the event name
  textAlign(CENTER, CENTER); // Center alignment for "TechFest 2024"
  text("TechFest 2024", 0, 0); // Center position inside the globe

  popMatrix();
}


void generateGabrielGraph() {
  linkIndex = 0;
  finishedGenerating = false;
}

void stepGenerateLinks() {
  for (int i = 0; i < 10 && !finishedGenerating; i++) { // Process 10 links per frame
    if (linkIndex >= nodeArray.size()) {
      finishedGenerating = true;
      break;
    }
    Node current = nodeArray.get(linkIndex);
    for (int j = linkIndex + 1; j < nodeArray.size(); j++) {
      Node target = nodeArray.get(j);
      PVector center = PVector.add(current.vec3, target.vec3).div(2);
      float distance = current.vec3.dist(target.vec3);
      float radius = distance / 2;

      boolean isValid = true;
      for (Node extra : nodeArray) {
        if (extra != current && extra != target) {
          if (extra.vec3.dist(center) <= radius) {
            isValid = false;
            break;
          }
        }
      }

      if (isValid) {
        linkArray.add(new Link(current, target));
      }
    }
    linkIndex++;
  }
}

// Node class
class Node {
  PVector vec3;
  PVector vec2;
  float depth;
  float scaling;

  Node(float x, float y, float z) {
    vec3 = new PVector(x, y, z);
    vec2 = new PVector(0, 0);
  }

  void rotate() {
    PVector rot = new PVector(vec3.x, vec3.z).rotate(rotateSpeed);
    vec3.x = rot.x;
    vec3.z = rot.y;
  }

  void update() {
    float magnitude = map(cos(frameCount / 60.0), -1, 1, 3, 1);
    depth = magnitude + vec3.z;
    vec2.x = (vec3.x / depth) * zoom;
    vec2.y = (vec3.y / depth) * zoom;
    scaling = 10 / depth;
  }

  void show() {
    noStroke();
    fill(random(100, 255), random(50, 200), random(200, 255), 150);
    ellipse(vec2.x, vec2.y, scaling, scaling);
  }
}

// Link class
class Link {
  Node node1, node2;

  Link(Node n1, Node n2) {
    node1 = n1;
    node2 = n2;
  }

  void show() {
    stroke(random(100, 255), random(100, 255), random(255), 100);
    strokeWeight(1);
    line(node1.vec2.x, node1.vec2.y, node2.vec2.x, node2.vec2.y);
  }
}

// Particle class for glowing electric effects
class Particle {
  PVector position;
  PVector velocity;
  color col;

  Particle(float x, float y, float z) {
    position = new PVector(x, y, z);
    velocity = PVector.random3D();
    velocity.mult(random(1, 3));
    col = color(random(255), random(0, 255), random(255), 150);
  }

  void update() {
    position.add(velocity);
  }

  void display() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    stroke(col);
    strokeWeight(2);
    point(0, 0);
    popMatrix();
  }

  boolean isOutOfBounds() {
    return (abs(position.x) > 400 || abs(position.y) > 400 || abs(position.z) > 400);
  }
}

// Function to draw a skeleton sphere (wireframe) with color
void drawSkeletonSphere(float radius) {
  noFill();
  int detail = 24; // Number of longitude and latitude lines

  for (int i = 0; i <= detail; i++) {
    float theta = map(i, 0, detail, 0, TWO_PI);

    // Latitude lines
    beginShape();
    for (int j = 0; j <= detail; j++) {
      float phi = map(j, 0, detail, 0, PI);
      float x = radius * sin(phi) * cos(theta);
      float y = radius * cos(phi);
      float z = radius * sin(phi) * sin(theta);

      float r = map(sin(phi), -1, 1, 100, 255); // Red based on latitude
      float g = map(cos(theta), -1, 1, 100, 255); // Green based on longitude
      float b = map(sin(phi + theta), -1, 1, 100, 255); // Blue based on angles

      stroke(r, g, b, 150); // Transparent colors
      vertex(x, y, z);
    }
    endShape();

    // Longitude lines
    beginShape();
    for (int j = 0; j <= detail; j++) {
      float phi = map(j, 0, detail, 0, TWO_PI);
      float x = radius * sin(theta) * cos(phi);
      float y = radius * cos(theta);
      float z = radius * sin(theta) * sin(phi);

      float r = map(sin(phi), -1, 1, 100, 255);
      float g = map(cos(theta), -1, 1, 100, 255);
      float b = map(sin(phi + theta), -1, 1, 100, 255);

      stroke(r, g, b, 150);
      vertex(x, y, z);
    }
    endShape();
  }
}
