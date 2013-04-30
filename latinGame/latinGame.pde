class Thing {
  
  protected int x, y;
  protected PImage img;
  
  public Thing(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public Thing(String URL, int x, int y) {
    this(x, y);
    img = loadImage(URL);
  }
  
  public Thing(String URL, int x, int y, int height) {
    this(URL, x, y);
    img.resize(0,height);
  }
  
  public void render(Actor player) {
    image(img, x - player.x, y - player.y);
  }
  
}

class Tile extends Thing {
  
  private static final int WIDTH = 30;
  
  public Tile(String URL, int x, int y) {
    super(URL, WIDTH * x, WIDTH * y);
  }
  
}

class Actor extends Thing {
  
  private static final int MOVES_PER_STEP = 5;
  private static final int HEIGHT = 36;
  
  public int velocity;
  private float direction;
  
  private int foot;
    
  private ArrayList<PImage> sprites = new ArrayList<PImage>();
    
  public Actor(String URL, int x, int y) {
    super(x, y);
    direction = 90;
    velocity = 2;
    foot = 0;
    for (int i = 0; i < 8; i++) {
      sprites.add(loadImage(URL + "/" + i + ".png"));
      ((PImage) sprites.get(i)).resize(0,36);
    }
  }
  
  public Actor(String URL) {
     this(URL,0,0);
  }
  
  public void move(float theta) {
    foot = (foot + 1) % (2 * MOVES_PER_STEP);
    direction = theta;
    this.x += velocity * cos(direction);
    this.y += velocity * sin(direction);
  }
  
  public void moveD(int theta) {
    foot = (foot + 1) % (2 * MOVES_PER_STEP);
    direction = radians(theta);
    this.x += velocity * cos(direction);
    this.y += velocity * sin(direction);
  }
  
  private int getFoot() {
    return floor(foot / MOVES_PER_STEP);
  }
  
  private PImage getSprite() {
    int i = (abs(sin(direction)) > abs(cos(direction))) ? 2 * ceil(0.9 * sin(direction)) + getFoot() : 4 + 2 * ceil(0.9 * cos(direction)) + getFoot();
    return (PImage) sprites.get(i);
  }
  
  public void render(Actor player) {
    scale(-1,1);
    PImage sprite = getSprite();
    image(sprite,player.x - x, y - player.y);
  }
  
  public void render() {
    PImage sprite = getSprite();
    image(sprite, width / 2, height / 2);
  }
  
}

class Key {
  
  private boolean isPressed;
  private int sign;
  
  public Key(int sign) {
    this.sign = sign;
    isPressed = false;
  }
  
  public int getValue() {
    return isPressed ? sign : 0;
  }
  
  public void press() {
    isPressed = true;
  }
  
  public void release() {
    isPressed = false;
  }
  
}

Actor thePlayer;

ArrayList<Thing> environment;
ArrayList<Actor> units;

Tile[][] grid;

Key W = new Key(-1);
Key A = new Key(-1);
Key S = new Key(1);
Key D = new Key(1);

void setup() {
  size(500,400);
  thePlayer = new Actor("playerSprites");
  thePlayer.velocity *= 2;
  
  grid = new Tile[50][50];
  
  units = new ArrayList<Actor>();
  units.add(new Actor("furySprites", 30, 30));
  
  environment = new ArrayList<Thing>();
  for (int x = 0; x < 6; x++)
    for (int y = 0; y < 6; y++)
    environment.add(new Thing("background.jpg", 375 * x, 275 * y, 375));
}

void draw() {
  background(0);
  imageMode(CENTER);
  
  for (Thing thing : environment)
    thing.render(thePlayer);
    
  thePlayer.render();
  
  for (Actor unit : units)
    unit.render(thePlayer);
  
  if (A.getValue() + D.getValue() == 0) {
    if (W.getValue() + S.getValue() != 0)
      thePlayer.moveD((Integer) ((W.getValue() + S.getValue())/abs(W.getValue() + S.getValue()) * 90));
  }
  else thePlayer.move((A.getValue() < 0 ? radians(180) : 0) + atan((W.getValue() + S.getValue()) / (A.getValue() + D.getValue())));
    
}

void keyPressed() {
  switch (key) {
    case 'w': W.press(); break;
    case 'a': A.press(); break;
    case 's': S.press(); break;
    case 'd': D.press(); break;
  }
  if (key == CODED) {
    switch (keyCode) {
      case UP: W.press(); break;
      case LEFT: A.press(); break;
      case DOWN: S.press(); break;
      case RIGHT: D.press(); break;
    }
  }
}

void keyReleased() {
  switch (key) {
    case 'w': W.release(); break;
    case 'a': A.release(); break;
    case 's': S.release(); break;
    case 'd': D.release(); break;
  }
  if (key == CODED) {
    switch (keyCode) {
      case UP: W.release(); break;
      case LEFT: A.release(); break;
      case DOWN: S.release(); break;
      case RIGHT: D.release(); break;
    }
  }
}
