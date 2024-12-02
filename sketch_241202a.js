let nodeAmount = 300;
let rotateSpeed = 0.01;
let growSpeed = 0.01;
let nodeArray = [];
let linkArray = [];
let linkIndex = 0;
let finishedGenerating = false;

let particleCount = 20;
let particles = []; // For glowing particle effects
let zoom;

function setup() {
  createCanvas(800, 800, WEBGL);
  zoom = min(width, height) * 1.2;

  // Initialize nodes
  while (nodeArray.length < nodeAmount) {
    let alpha = random(TWO_PI);
    let beta = random(TWO_PI);
    let x = sin(alpha) * cos(beta);
    let y = cos(alpha);
    let z = sin(alpha) * sin(beta);
    let n = new Node(x, y, z);
    nodeArray.push(n);
  }

  // Start generating links
  generateGabrielGraph();
}

function draw() {
  background(0);

  // Draw heading (inside the globe, fixed)
  drawHeading();

  // Rotate and translate the entire scene for the globe
  push();
  rotateX(frameCount * 0.005);
  rotateY(frameCount * 0.01);

  // Draw a skeleton sphere (wireframe)
  drawSkeletonSphere(300);

  // Continue step-by-step link generation
  if (!finishedGenerating) {
    stepGenerateLinks();
  }

  // Update and display nodes and links
  for (let node of nodeArray) {
    node.rotate();
    node.update();
    node.show();
  }

  for (let link of linkArray) {
    link.show();
  }

  // Add glowing particle effects for visual enhancement
  for (let i = 0; i < particleCount; i++) {
    particles.push(new Particle(random(-400, 400), random(-400, 400), random(-400, 400)));
  }

  for (let i = particles.length - 1; i >= 0; i--) {
    let p = particles[i];
    p.update();
    p.display();
    if (p.isOutOfBounds()) {
      particles.splice(i, 1);
    }
  }
  pop();
}

function drawHeading() {
  push();
  translate(0, -350, 0);
  textAlign(CENTER);
  fill(255, 204, 0); // Golden-yellow color

  textSize(40); // Smaller font size for the name
  text("Innovate, Create, Dominate!", 0, 0);

  textSize(72); // Larger font size for the event name
  text("TechFest 2024", 0, 100);
  pop();
}

function generateGabrielGraph() {
  linkIndex = 0;
  finishedGenerating = false;
}

function stepGenerateLinks() {
  for (let i = 0; i < 10 && !finishedGenerating; i++) { // Process 10 links per frame
    if (linkIndex >= nodeArray.length) {
      finishedGenerating = true;
      break;
    }
    let current = nodeArray[linkIndex];
    for (let j = linkIndex + 1; j < nodeArray.length; j++) {
      let target = nodeArray[j];
      let center = p5.Vector.add(current.vec3, target.vec3).div(2);
      let distance = current.vec3.dist(target.vec3);
      let radius = distance / 2;

      let isValid = true;
      for (let extra of nodeArray) {
        if (extra !== current && extra !== target) {
          if (extra.vec3.dist(center) <= radius) {
            isValid = false;
            break;
          }
        }
      }

      if (isValid) {
        linkArray.push(new Link(current, target));
      }
    }
    linkIndex++;
  }
}

// Node class
class Node {
  constructor(x, y, z) {
    this.vec3 = createVector(x, y, z);
    this.vec2 = createVector(0, 0);
    this.depth = 0;
    this.scaling = 0;
  }

  rotate() {
    let rot = createVector(this.vec3.x, this.vec3.z).rotate(rotateSpeed);
    this.vec3.x = rot.x;
    this.vec3.z = rot.y;
  }

  update() {
    let magnitude = map(cos(frameCount / 60.0), -1, 1, 3, 1);
    this.depth = magnitude + this.vec3.z;
    this.vec2.x = (this.vec3.x / this.depth) * zoom;
    this.vec2.y = (this.vec3.y / this.depth) * zoom;
    this.scaling = 10 / this.depth;
  }

  show() {
    noStroke();
    fill(random(100, 255), random(50, 200), random(200, 255), 150);
    ellipse(this.vec2.x, this.vec2.y, this.scaling, this.scaling);
  }
}

// Link class
class Link {
  constructor(node1, node2) {
    this.node1 = node1;
    this.node2 = node2;
  }

  show() {
    stroke(random(100, 255), random(100, 255), random(255), 100);
    strokeWeight(1);
    line(this.node1.vec2.x, this.node1.vec2.y, this.node2.vec2.x, this.node2.vec2.y);
  }
}

// Particle class for glowing electric effects
class Particle {
  constructor(x, y, z) {
    this.position = createVector(x, y, z);
    this.velocity = p5.Vector.random3D().mult(random(1, 3));
    this.col = color(random(255), random(0, 255), random(255), 150);
  }

  update() {
    this.position.add(this.velocity);
  }

  display() {
    push();
    translate(this.position.x, this.position.y, this.position.z);
    stroke(this.col);
    strokeWeight(2);
    point(0, 0);
    pop();
  }

  isOutOfBounds() {
    return (abs(this.position.x) > 400 || abs(this.position.y) > 400 || abs(this.position.z) > 400);
  }
}

// Function to draw a skeleton sphere (wireframe) with color
function drawSkeletonSphere(radius) {
  noFill();
  let detail = 24; // Number of longitude and latitude lines

  for (let i = 0; i <= detail; i++) {
    let theta = map(i, 0, detail, 0, TWO_PI);

    // Latitude lines
    beginShape();
    for (let j = 0; j <= detail; j++) {
      let phi = map(j, 0, detail, 0, PI);
      let x = radius * sin(phi) * cos(theta);
      let y = radius * cos(phi);
      let z = radius * sin(phi) * sin(theta);

      let r = map(sin(phi), -1, 1, 100, 255);
      let g = map(cos(theta), -1, 1, 100, 255);
      let b = map(sin(phi + theta), -1, 1, 100, 255);

      stroke(r, g, b, 150);
      vertex(x, y, z);
    }
    endShape();

    // Longitude lines
    beginShape();
    for (let j = 0; j <= detail; j++) {
      let phi = map(j, 0, detail, 0, TWO_PI);
      let x = radius * sin(theta) * cos(phi);
      let y = radius * cos(theta);
      let z = radius * sin(theta) * sin(phi);

      let r = map(sin(phi), -1, 1, 100, 255);
      let g = map(cos(theta), -1, 1, 100, 255);
      let b = map(sin(phi + theta), -1, 1, 100, 255);

      stroke(r, g, b, 150);
      vertex(x, y, z);
    }
    endShape();
  }
}
