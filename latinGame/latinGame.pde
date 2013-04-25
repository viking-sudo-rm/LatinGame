class Thing {
  
  protected int x, y;
  private PImage img;
  
  public Thing(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public Thing(String URL, int x, int y) {
    img = loadImage(URL);
    this.x = x;
    this.y = y;
  }
  
  public void render(Actor player) {
    image(img, x - player.x, y - player.y);
  }
  
}

class Actor extends Thing {
  
  private static final int MOVES_PER_STEP = 5;
  private static final int WIDTH = 28;
  
  public int velocity;
  private float direction;
  
  private int foot;
  
  private int reversed;
  
  private ArrayList<PImage> sprites = new ArrayList<PImage>();
    
  public Actor(String URL, int x, int y) {
    super(x, y);
    direction = 0;
    velocity = 2;
    foot = 0;
    reversed = 1;
    for (int i = 0; i < 6; i++) {
      sprites.add(loadImage(URL + "/" + i + ".png"));
      ((PImage) sprites.get(i)).resize(WIDTH,0);
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
    int i = (abs(sin(direction)) > abs(cos(direction))) ? 2 * ceil(0.9 * sin(direction)) + getFoot() : 4 + getFoot();
    scale((i > 3 ? -cos(direction) / abs(cos(direction)) : 1), 1);
    reversed = (abs(sin(direction)) > abs(cos(direction))) ? 1 : (int) -(cos(direction) / abs(cos(direction)));
    return (PImage) sprites.get(i);
  }
  
  public void render(Actor player) {
    image(getSprite(), reversed * (x - player.x), y - player.y);
  }
  
  public void render() {
    image(getSprite(), reversed * width / 2, height / 2);
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
ArrayList<Object> environment;

Key W = new Key(-1);
Key A = new Key(-1);
Key S = new Key(1);
Key D = new Key(1);

void setup() {
  size(500,400);
  thePlayer = new Actor("playerSprites");
  environment = new ArrayList<Object>();
  for (int i = 0; i < 6; i++)
    environment.add(new Thing("background.jpg", 40 * i, 70 * i));
  thePlayer.velocity *= 2;
}

void draw() {
  background(0);
  imageMode(CENTER);
  for (Object thing : environment)
    ((Thing) thing).render(thePlayer);
  thePlayer.render();
  
  if (A.getValue() + D.getValue() == 0) {
    if (W.getValue() + S.getValue() != 0)
      thePlayer.moveD((Integer) ((W.getValue() + S.getValue())/abs(W.getValue() + S.getValue()) * 90));
  }
  else thePlayer.move((A.getValue() < 0 ? radians(180) : 0) + atan((W.getValue() + S.getValue()) / (A.getValue() + D.getValue())));
  
  println(A.getValue());
  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) W.press();
    if (keyCode == DOWN) S.press();
    if (keyCode == LEFT) A.press();
    if (keyCode == RIGHT) D.press();
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) W.release();
    if (keyCode == DOWN) S.release();
    if (keyCode == LEFT) A.release();
    if (keyCode == RIGHT) D.release();
  }
}
