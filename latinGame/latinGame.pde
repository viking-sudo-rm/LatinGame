interface Movable {
  
  public void move(float theta);
  
}

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
  //getter methods...just in case, ya know...
  //JASEN U FUCKING OOP GOODY 2SHOES OMFG LEAVE
  //i actually used it lol

  public int xPos() {return this.x;}
  public int yPos() {return this.y;}
  
  public void render(Actor player) {
    image(img, x - player.x + width / 2, y - player.y + height / 2);
  }
  
}

class Tile extends Thing {
  
  private static final int WIDTH = 36;
    
  public Tile(String URL, int x, int y) {
    super(URL, WIDTH * x, WIDTH * y);
    img.resize(0, WIDTH);
  }
  
}

class Actor extends Thing implements Movable {
  
  private static final int MOVES_PER_STEP = 5;
  private static final int HEIGHT = 36;
  
  public int velocity;
  public boolean canFly;
  
  private float direction;
  
  private int foot;
    
  private ArrayList<PImage> sprites = new ArrayList<PImage>();
    
  public Actor(String URL, int x, int y) {
    super(x, y);
    direction = 90;
    velocity = 2;
    foot = 0;
    canFly = false;
    for (int i = 0; i < 8; i++) {
      sprites.add(loadImage(URL + "/" + i + ".png"));
      sprites.get(i).resize(0,36);
    }
  }
  
  public void move(float theta) {    
    foot = (foot + 1) % (2 * MOVES_PER_STEP);
    direction = theta;
    PImage sprite = getSprite();
    if (canFly || (isFree((int) (x + velocity * cos(direction)),(int) (y + velocity * sin(direction))) && isFree((int) (x + sprite.width + velocity * cos(direction)),(int) (y + velocity * sin(direction))) && isFree((int) (x + velocity * cos(direction)),(int) (y + sprite.height + velocity * sin(direction))) && isFree((int) (x + sprite.width + velocity * cos(direction)),(int) (y + sprite.height + velocity * sin(direction))))) {
      this.x += velocity * cos(direction);
      this.y += velocity * sin(direction);
    }
    //else if (abs(theta) < 450) {
      //int sign = (theta % (Math.PI / 2) < Math.PI / 4) ? -1 : 1;
      //move(theta + sign * (float) Math.PI / 2);
    //}
  }
  
  public void moveD(int theta) {
    move(radians(theta));
  }
  
  private int getFoot() {
    return floor(foot / MOVES_PER_STEP);
  }
  
  private PImage getSprite() {
    int i = (abs(sin(direction)) > abs(cos(direction))) ? 2 * ceil(0.9 * sin(direction)) + getFoot() : 4 + 2 * ceil(0.9 * cos(direction)) + getFoot();
    return (PImage) sprites.get(i);
  }
  
  public void render(Actor player) {
    PImage sprite = getSprite();
    image(sprite, x - player.x + width / 2, y - player.y + height / 2);
  }
  
  public void render() {
    PImage sprite = getSprite();
    image(sprite, width / 2, height / 2);
  }

  public double distanceTo(Thing target) {
    return sqrt((float)(Math.pow(target.x-this.x,2)+ Math.pow(target.y-this.y,2)));
  }
  
  public double getAngleBetween(Thing target){
    if(target.x <= this.x && target.y <= this.y){
      return -PI + acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    if(target.x > this.x && target.y > this.y){
      return acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    if(target.x > this.x && target.y <= this.y){
      return -1*acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    if(target.x <= this.x && target.y > this.y){
      return PI - acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    else return Math.PI;
  }

}

class Human extends Actor {
  
  private int ammo;
  
  public Human(String URL) {
     this(URL,50,50);
  }
  
  public Human(String URL, int x, int y) {
    super(URL, x, y);
    ammo = 1000;
  }
  
  public Trident attack(Thing target, ArrayList<Actor> targets) {    
    if (ammo < 1)
      return null;      
    ammo--;
    return new Trident("trident.png", x, y, (float) getAngleBetween(target), targets);
  }
  
}

class Trident extends Thing {
  
  private float theta;
  private ArrayList<Actor> targets;
  private int numUpdates;
  
  private static final int VELOCITY = 8;
  
  public Trident(String URL, int x, int y, float theta, ArrayList<Actor> targets) {
    super(URL, x, y);
    this.theta = theta;
    this.targets = targets;
    numUpdates = 0;
    
  }
  
  protected void update() {
    numUpdates++;
  }
  
  public void render(Actor player) {
    update();
    translate(x - player.x + width / 2, y - player.y + height / 2);
    rotate(theta);
    image(img, numUpdates * VELOCITY, 0);
    rotate(-theta);
    translate(-x + player.x - width / 2, -y + player.y - height / 2);
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
///////////////////// MAIN CLASS STUFF STARTS HERE \\\\\\\\\\\\\\\\\\\\\\\\\\

void loadGrid(String URL) {
    grid = new Tile[50][400];
    String[] lines = loadStrings(URL);
    for (int y = 0; y < lines.length; y++) {
      for (int x = 0; x < lines[y].length(); x++) {
        if (symbols.get(lines[y].charAt(x)) != null)
          grid[y][x] = new Tile(symbols.get(lines[y].charAt(x)), x, y);
      }
    }
}

boolean isFree(int x, int y) {
  x /= Tile.WIDTH;
  y /= Tile.WIDTH;
  if (y < 0 || y >= grid.length || x < 0 || x >= grid[0].length)
    return false;
  return grid[y][x] == null;
}

Human thePlayer;

ArrayList<Thing> environment;
ArrayList<Actor> units;

Tile[][] grid;

Map<Character, String> symbols = new HashMap<Character, String>();

Key W = new Key(-1);
Key A = new Key(-1);
Key S = new Key(1);
Key D = new Key(1);

void setup() {
  
  size(500,400);
  
  symbols.put('a',"wall.png");
  loadGrid("grid.txt");
    
  thePlayer = new Human("playerSprites");
  thePlayer.velocity *= 2;
   
  units = new ArrayList<Actor>();
  units.add(new Actor("furySprites", 100, 400));
  units.get(0).canFly = true;
  
  environment = new ArrayList<Thing>();
  for (int x = -1; x < 30; x++) {
    for (int y = 0; y < 7; y++)
      environment.add(new Thing("background.jpg", 375 * x, 275 * y, 375));
  }
}

void draw() {
  background(0);
  imageMode(CENTER);
  
  for (Thing thing : environment)
    thing.render(thePlayer);
  
  for (int y = 0; y < grid.length; y++) {
    for (int x = 0; x < grid[0].length; x++) {
      if (grid[y][x] != null) {
        grid[y][x].render(thePlayer);
      }
    }
  }
    
  thePlayer.render();
  
  for (Actor unit : units){
    unit.move((float)(unit.getAngleBetween(thePlayer)));
    unit.render(thePlayer);
  }
  
  if (A.getValue() + D.getValue() == 0) {
    if (W.getValue() + S.getValue() != 0)
      thePlayer.moveD((Integer) ((W.getValue() + S.getValue())/abs(W.getValue() + S.getValue()) * 90));
  }
  else thePlayer.move((A.getValue() < 0 ? radians(180) : 0) + atan((W.getValue() + S.getValue()) / (A.getValue() + D.getValue())));
  
}

void mousePressed() {
  Trident t = thePlayer.attack(new Thing(mouseX + thePlayer.xPos() - width / 2, mouseY + thePlayer.yPos() - height / 2), units);
  if (t != null) environment.add(t);
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
