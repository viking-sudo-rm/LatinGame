class Actor extends Object {
  
  PImage img;
  int velocity;
  int x, y;
  
  public Actor(String URL, int x, int y) {
    img = loadImage(URL);
    velocity = 2;
    x = 0;
    y = 0;
  }
  
  public Actor(String URL) {
     this(URL,0,0);
  }
  
  public void move(float theta) {
    theta = radians(theta);
    this.x += velocity * cos(theta);
    this.y += velocity * sin(theta);
  }
  
  public void render(Actor screen) {
    image(img,x - screen.x,y - screen.y);
  }
  
  public void render() {
    image(img, x, y);//image(img, 0, 0);
  }
  
}

Actor thePlayer;

void setup() {
  size(400,400);
  thePlayer = new Actor("thePlayer.gif",30,30);
  thePlayer.velocity *= 2;
}

void draw() {
  background(0);
  thePlayer.render();
}

void keyPressed() {
  switch (key) {
    case 'w': thePlayer.move(-90); break;
    case 'a': thePlayer.move(180); break;
    case 's': thePlayer.move(90); break;
    case 'd': thePlayer.move(0); break;
  }
}
