class Stats {
  
  private int tridentsPickedUp;
  private int kills;
  
  public Stats() {
  }
  
  public void pickupTrident() {
    tridentsPickedUp++;
  }
  
  public void killHarpy() {
    kills++;
  }
  
  public int getTridentsPickupUp() {return tridentsPickedUp;}
  public int getKills() {return kills;}
  
  public int getScore() {return kills + tridentsPickedUp;}//kills / (time * throws)
  
}

class Button {
  
  private int x, y;
  private PImage img;
  private PImage pressedImg;
    
  public Button(int x, int y, String URL, String pressedURL) {
    img = loadImage(URL);
    pressedImg = loadImage(pressedURL);
    this.x = x;
    this.y = y;
  }
  
  public void render() {
    image(img, x, y);
  }
  
  public void renderPressed() {
    image(pressedImg, x, y);
  }
  
  public boolean isPressed() {
    return  mousePressed && x - img.width / 2 < mouseX &&  mouseX < x + img.width / 2 && y - img.width / 2 < mouseY && mouseY < y + img.height / 2;
  }
  
}

class DialogueBox {
  public String speaker,dialogue;
  public PImage portrait;
  private PImage gradientBackground;
  
  public DialogueBox(String speaking, String speakerPicURL, int index){
    speaker = speaking;
    dialogue = english[index];
    portrait = loadImage(speakerPicURL);
    portrait.resize(0, 50);
    gradientBackground = loadImage("Gradient2.png");
    gradientBackground.resize(600,100);
}
  
  public void drawDialogue() {
    image(gradientBackground,width/2,height/16+5);
    fill(0);
    text(speaker + ": \n" + dialogue,width/16*4+20,height/24);
    image(portrait,width/8,height/12);

  }
  
  public void end() {
    
  }
  
}

class EndGameDialogueBox extends DialogueBox {
  
  public EndGameDialogueBox(String speaking, String speakerPicURL, int index){
    super(speaking, speakerPicURL, index);
  }
  
  public void end() {
    inGame = false;
  }
  
}

class ShowImageDialogueBox extends DialogueBox {
  
  PImage img;
  
  public ShowImageDialogueBox(String speaking, String speakerPicURL, int index, String URL){
    super(speaking, speakerPicURL, index);
    img = loadImage(URL);
  }
  
  public void end() {
    image(img, width / 2, height / 2);
  }
  
}

class Thing {
  
  protected int x, y;
  protected PImage img;
  
  public boolean isDead;

  
  public Thing(int x, int y) {
    this.x = x;
    this.y = y;
    isDead = false;

  }
  
  public Thing(String URL, int x, int y) {
    this(x, y);
    img = loadImage(URL);
  }
  
  public Thing(String URL, int x, int y, int height) {
    this(URL, x, y);
    img.resize(0,height);
  }
  
  public void kill() {
    isDead = true;
  }

  public int xPos() {return x;}
  public int yPos() {return y;}
  
  protected void goToCoords(int x, int y) {
    this.x = Tile.WIDTH * x;
    this.y = Tile.WIDTH * y;
  }
  
  public void render(Actor player) {
    image(img, x - player.x + width / 2, y - player.y + height / 2);
  }
  
}

class Tile extends Thing {
  
  private static final int WIDTH = 36;
  
  public boolean passable;
    
  public Tile(String URL, int x, int y) {
    super(URL, WIDTH * x, WIDTH * y);
    passable = false;
    img.resize(0, WIDTH);
  }
    
}

class Trigger extends Tile {
    
  private boolean active;
  
  public Trigger(String URL, int x, int y) {
    super(URL, x, y);
    active = true;
  }
  
  public boolean checkOnce() {
    boolean flag = active && x / Tile.WIDTH == thePlayer.xPos() / Tile.WIDTH && y / Tile.WIDTH == thePlayer.yPos() / Tile.WIDTH;
    active = false;
    return flag;
  }
  
  public boolean check() {
    return active && x / Tile.WIDTH == thePlayer.xPos() / Tile.WIDTH && y / Tile.WIDTH == thePlayer.yPos() / Tile.WIDTH;
  }
  
}

class Actor extends Thing {
  
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
  
  public boolean overlaps(double otherX, double otherY) {
    PImage sprite = getSprite();
    return otherX >= x && otherX <= x + sprite.width / 2 && otherY >= y && otherY <= y + sprite.height / 2;
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
  public boolean hasWon;
  public Stats stats;
  
  public Human(String URL) {
     this(URL,0,0);
  }
  
  public Human(String URL, int x, int y) {
    super(URL, x, y);
    ammo = 0;
    hasWon = false;
    stats = new Stats();
  }
  
  public void kill() {
    dialogues.add(new EndGameDialogueBox("Neptune","poseidon.png",29));
    super.kill();
  }
  
  public void win() {
    hasWon = true;
  }
  
  public void giveTrident() {
    ammo++;
  }
  public int getAmmo(){
    return ammo;
  }
  public Trident attack(Thing target) {    
    if (ammo < 1)
      return null;      
    ammo--;
    return new Trident("trident.png", x, y, (float) getAngleBetween(target), distanceTo(target), true);
  }
    
  public void drawAmmoCounter(){
    noFill();
    rect(width/12*10,height/12*10,width/12*2,height/12*1);
    for(int i = ammo-1; i >= 0; i--){
      image(trident,width/12*10.5+1+i*10,height/12*10.5);
    }
  }
  
}

class Trident extends Thing {
  
  private float theta;
  private double distance;
  private int numUpdates;
  private boolean pickedUp;
    
  private static final int VELOCITY = 8;
  
  public Trident(String URL, int x, int y, float theta, double distance) {
    super(URL, x, y);
    pickedUp = false;
    this.theta = theta;
    this.distance = distance;
    numUpdates = 0;  
  }
  
  public Trident(String URL, int x, int y, float theta, double distance, boolean pickedUp) {
    this(URL, x, y, theta, distance);
    this.pickedUp = pickedUp;
  }
  
  protected void update() {
    if (numUpdates * VELOCITY < distance) {
      numUpdates++;
      for (int i = 0; i < units.size(); i++) {
        if (units.get(i).overlaps(x + (numUpdates * VELOCITY + img.width / 2) * cos(theta), y + (numUpdates * VELOCITY) * sin(theta)))
          units.get(i).kill();
      }
    }
    else if (thePlayer.overlaps(x + (numUpdates * VELOCITY + img.width / 2) * cos(theta), y + (numUpdates * VELOCITY) * sin(theta)) || thePlayer.overlaps(x + (numUpdates * VELOCITY - img.width / 2) * cos(theta), y + (numUpdates * VELOCITY) * sin(theta))) {
      if (! pickedUp) {
        if (thePlayer.stats.tridentsPickedUp == 0) {
          dialogues.add(new DialogueBox("Neptune", "poseidon.png", 15));
          dialogues.add(new DialogueBox("Neptune", "poseidon.png", 16));
        } else
          dialogues.add(new DialogueBox("Neptune","poseidon.png",17));
        thePlayer.stats.pickupTrident();
      }
      thePlayer.giveTrident();
      isDead = true;
    }
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
    String[] lines = loadStrings(URL);
    grid = new Tile[lines.length][lines[0].length()];
    String name;
    for (int y = 0; y < lines.length; y++) {
      for (int x = 0; x < lines[y].length(); x++) {
        name = symbols.get(lines[y].charAt(x));
        if (name != null) {
          if (name == "3") {
            weapons.add(new Trident("trident.png", 0, 0, 0, 0));
            weapons.get(weapons.size() - 1).goToCoords(x,y);
          }
          else if (name == "H") {
            environment.add(new Thing("house.png", 0, 0));
            environment.get(environment.size() - 1).goToCoords(x, y);
          } else {
            if (name.charAt(0) == 'T')
              grid[y][x] = new Trigger(name.substring(1), x, y);
            else
              grid[y][x] = new Tile(name.substring(1), x, y);
            if (name.charAt(0) != '/')
                grid[y][x].passable = true;
          }
        }
      }
    }
}

boolean isFree(int x, int y) {
  x /= Tile.WIDTH;
  y /= Tile.WIDTH;
  if (y < 0 || y >= grid.length || x < 0 || x >= grid[0].length)
    return false;
  return grid[y][x] == null || grid[y][x].passable;
}

boolean inGame;
Button joinGame;
boolean shouldEnterGame;
PImage menuBackground, trident;
PFont font;

String[] english;

Human thePlayer;

ArrayList<Thing> environment;
ArrayList<Thing> backgrounds;
ArrayList<Actor> units; //make an array
ArrayList<Trident> weapons;
ArrayList<DialogueBox> dialogues = new ArrayList<DialogueBox>();

Tile[][] grid;

Map<Character, String> symbols = new HashMap<Character, String>();

Key W = new Key(-1);
Key A = new Key(-1);
Key S = new Key(1);
Key D = new Key(1);

void setup() {
  
  size(500, 400);
  trident = loadImage("trident.png");
  english = loadStrings("scripts/english.txt");
  font = loadFont("AgencyFB-Bold-48.vlw");
  
  menuBackground = loadImage("menu.png");
  joinGame = new Button(250, 200, "button.png", "loadingbutton.png");
  shouldEnterGame = false;
  
  setupMenu();
  
}

void draw() {
  
  imageMode(CENTER);
  textFont(font, 16);
  
  if (inGame) {
    drawGame();
  } else {
    drawMenu();
  }
}

void setupGame() {
    
  inGame = true;
  shouldEnterGame = false;
  
  symbols.put('a',"/rock.png");
  symbols.put('w',"/water.png");
  symbols.put('d',".water.png");
  symbols.put('W',"Twater.png");
  symbols.put('b',"/bush.png");
  symbols.put('t',"/tree.png");
  symbols.put('x',"/blank.png");
  symbols.put('p',".road/road1.png");
  symbols.put('r',".road/roadside.png");
  symbols.put('e',".road/roadedgeside.png");
  symbols.put('u',".road/roadedgedown.png");
  symbols.put('c',".road/roadcorner.png");
  symbols.put('^',".road/roadedgeup.png");
  symbols.put('&',".road/roadinter.png");
  symbols.put('E',"Tblank.png");
  symbols.put('T',"3");
  symbols.put('H',"H");
    
  thePlayer = new Human("playerSprites");
  thePlayer.goToCoords(34,9 );
  thePlayer.velocity *= 1.5;
  
  weapons = new ArrayList<Trident>();  
  units = new ArrayList<Actor>();
  
  backgrounds = new ArrayList<Thing>();
  for (int x = -1; x < 30; x++) {
    for (int y = 0; y < 7; y++)
      backgrounds.add(new Thing("background.jpg", 375 * x, 275 * y, 375));
  }
  
  environment = new ArrayList<Thing>();
  environment.add(new Thing("temple.png", 0, 0));
  environment.get(0).goToCoords(35, 6);
  environment.add(new Thing("finalstairs.png", 0, 0));
  environment.get(1).goToCoords(15, 29);

  loadGrid("/grid.txt");  
  
  draw();
  
  for (int i = 0; i < 11; i++) {
    dialogues.add(new DialogueBox("Neptune","poseidon.png",i));
  }
  
}

void drawGame() {
  
  if (thePlayer.isDead) {
    background(0,0,0);
   }
  else if (dialogues.size() == 0) {
  
    for (Thing thing : backgrounds)
      thing.render(thePlayer);
    
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[0].length; x++) {
        if (grid[y][x] != null) {
          grid[y][x].render(thePlayer);
        }
      }
    }
    
    for (Thing thing : environment)
      thing.render(thePlayer);
        
    for (int i = 0; i < weapons.size(); i++) {
      weapons.get(i).render(thePlayer);
      if (weapons.get(i).isDead) {
        weapons.remove(i);
        i--;
      }
    }
         
    thePlayer.render();
    
    Actor unit;
    for (int i = 0; i < units.size(); i++) {
      unit = units.get(i);
      unit.move((float)(unit.getAngleBetween(thePlayer)));
      unit.render(thePlayer);
      if (unit.overlaps(thePlayer.xPos(),thePlayer.yPos()))
        thePlayer.kill();
      if (unit.isDead) {
        units.remove(i);
        i--;
      }
    }
    
    for (int i = units.size(); i < 10; i++) {
      units.add(new Actor("furySprites",0,0));
      units.get(i).goToCoords(30 + 5 * i, 2);
      units.get(i).canFly = true;
    }
    
    for (int i = 28; i < 31; i++) {
      if(((Trigger) grid[i][15]).check()) {
        thePlayer.win();
        dialogues.add(new DialogueBox("Narrator","blank.png",19));
      }
    }
    
    if (thePlayer.hasWon) {
      thePlayer.move(PI);
      for (int i = 28; i < 31; i++) {
        if(((Trigger) grid[i][13]).check()) {
          for (int j = 19; j < 26; j++)
            dialogues.add(new DialogueBox("Narrator","blank.png",j));
          dialogues.add(new ShowImageDialogueBox("Narrator","blank.png",26, "painting.jpg"));
          dialogues.add(new EndGameDialogueBox("Narrator","blank.png",27));
        }
      }
    }
    else {
      thePlayer.drawAmmoCounter();
      if (A.getValue() + D.getValue() == 0) {
        if (W.getValue() + S.getValue() != 0)
          thePlayer.moveD((Integer) ((W.getValue() + S.getValue())/abs(W.getValue() + S.getValue()) * 90));
      }
      else thePlayer.move((A.getValue() < 0 ? PI : 0) + atan((W.getValue() + S.getValue()) / (A.getValue() + D.getValue())));
    }
    
  }
  
  if(dialogues.size() > 0) dialogues.get(0).drawDialogue();

  
}

void setupMenu() {
  inGame = false;
}

void drawMenu() {
  if (shouldEnterGame) setupGame();
  else {
    image(menuBackground, width / 2, height / 2);
    joinGame.render();
    if (joinGame.isPressed()) {
      joinGame.renderPressed();
      shouldEnterGame = true;
    }
  }
}

Trident t;

void mousePressed() {
  if (inGame) {
    t = thePlayer.attack(new Thing(mouseX + thePlayer.xPos() - width / 2, mouseY + thePlayer.yPos() - height / 2));
    if (t != null) weapons.add(t);
  }
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
  if(key==' ' && dialogues.size() > 0) {
    dialogues.get(0).end();
    dialogues.remove(0);
  }
}
