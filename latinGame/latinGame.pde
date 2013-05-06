class Thing {
  
  protected int x, y;
  protected PImage img;
  
  public Thing(int x, int y) {
    this.x = x;
    thsis.y = y;
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

  public int xPos() {return this.x;}
  public int yPos() {return this.y;}
  
  public void render(Actor player) {
    image(img, x - player.x + width / 2, y - player.y + height / 2);
  }
  
}

class Tile extends Thing {
  
  private static final int WIDTH = 30;
    
  public Tile(String URL, int x, int y) {
    super(URL, WIDTH * x, WIDTH * y);
    img.resize(0, WIDTH);
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
    PImage sprite = getSprite();
    if (isFree((int) (x + velocity * cos(direction)),(int) (y + velocity * sin(direction))) && isFree((int) (x + sprite.width + velocity * cos(direction)),(int) (y + velocity * sin(direction))) && isFree((int) (x + velocity * cos(direction)),(int) (y + sprite.height + velocity * sin(direction))) && isFree((int) (x + sprite.width + velocity * cos(direction)),(int) (y + sprite.height + velocity * sin(direction)))) {
      this.x += velocity * cos(direction);
      this.y += velocity * sin(direction);
    }
    else if (abs(theta) < 450) {
      move(theta + (float) Math.PI / 2);
    }
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
    scale(-1,1);
    PImage sprite = getSprite();
    image(sprite,player.x - x - width / 2, y - player.y + height / 2);
  }
  
  public void render() {
    PImage sprite = getSprite();
    image(sprite, width / 2, height / 2);
  }
  ///////////////////////// JASEN \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  public double distanceTo(Thing target) {
    return sqrt((float)(Math.pow(target.x-this.x,2)+ Math.pow(target.y-this.y,2)));
  }
  
  //everything is by default in radians
  public double getAngleBetween(Thing target){
    if(target.x <= this.x && target.y < this.y){
      return -Math.PI/2-acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    if(target.x >= this.x && target.y > this.y){
      return acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    if(target.x >= this.x && target.y <= this.y){
      return -1*acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    if(target.x <= this.x && target.y > this.y){
      return Math.PI/2+acos((float)(abs(target.x-this.x)/distanceTo(target)));
    }
    else return Math.PI;
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
    grid = new Tile[50][50];
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

Actor thePlayer;

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
    
  thePlayer = new Actor("playerSprites");
  thePlayer.velocity *= 2;
   
  units = new ArrayList<Actor>();
  units.add(new Actor("furySprites", 30, 30));
  
  environment = new ArrayList<Thing>();
  for (int x = 0; x < 6; x++) {
    for (int y = 0; y < 6; y++)
      environment.add(new Thing("background.jpg", 375 * x, 275 * y, 375));
  }
  environment.add(new Thing("harpy.png", 40, 40, 36));
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
    System.out.println("Unit Coords: "+unit.x+" "+unit.y);
    System.out.println("Player Coords: "+thePlayer.x+" "+thePlayer.y);
    //System.out.println(unit.getAngleBetween(thePlayer));
    unit.move((float)(unit.getAngleBetween(thePlayer)));
    //unit.move(0);
    unit.render(thePlayer);
    //System.out.println(unit.distanceTo(thePlayer));
  }
  if (A.getValue() + D.getValue() == 0) {
    if (W.getValue() + S.getValue() != 0)
      thePlayer.moveD((Integer) ((W.getValue() + S.getValue())/abs(W.getValue() + S.getValue()) * 90));
  }
  else thePlayer.move((A.getValue() < 0 ? radians(180) : 0) + atan((W.getValue() + S.getValue()) / (A.getValue() + D.getValue())));
  
  //System.out.println("Mouse Coords: " + mouseX + " " + mouseY); 
  
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
