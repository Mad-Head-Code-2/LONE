class Item {
  int texture = -1;
  int hardness = 100;
  int score = 0;
  boolean canmove = false;
  boolean takeable = false;
  boolean cangothrough = false;
  boolean free = false;
  String name = "";

  Item() {
    this.free = true;
  }

  Item(int texture, String name) {
    this.name = name;
    this.takeable = true;
    this.texture = texture;
    this.cangothrough = true;
    this.free = false;
  }
  Item(int texture, boolean cangothrough) {
    this.texture = texture;
    this.cangothrough = cangothrough;
    this.free = false;
  }
  Item(int texture, String name, int hardness) {
    this.texture = texture;
    this.hardness = hardness;
    this.canmove = true;
    this.score = 25;
    this.name = name;
    this.free = false;
  }
  void clearItem() {
    this.texture = -1;
    this.hardness = 100;
    this.score = 0;
    this.canmove = false;
    this.takeable = false;
    this.cangothrough = false;
    this.free = true;
    this.name = "";
  }

  Item use(Player player) {
    if (this.name == "Food") {
      player.health += 20;
      if (player.health>100)
        player.health = 100;
      return new Item();
    }
    if (this.name=="Key") {
      nextLevel();
      return new Item();
    }
    return this;
  }

  void step(Level level, Player player) {
    if (hardness<0) {
      clearItem();
      return;
    }
    if (name != "" && canmove) {
      int dir = ceil(random(4));
      var coord = level.find(this);
      if (dir==1 && level.map[coord[1]+1][coord[0]].free) {
        level.map[coord[1]+1][coord[0]] = this;
        level.map[coord[1]][coord[0]] = new Item();
      }
      if (dir==2 && level.map[coord[1]-1][coord[0]].free) {
        level.map[coord[1]-1][coord[0]] = this;
        level.map[coord[1]][coord[0]] = new Item();
      }
      if (dir==3 && level.map[coord[1]][coord[0]+1].free) {
        level.map[coord[1]][coord[0]+1] = this;
        level.map[coord[1]][coord[0]] = new Item();
      }
      if (dir==4 && level.map[coord[1]][coord[0]-1].free) {
        level.map[coord[1]][coord[0]-1] = this;
        level.map[coord[1]][coord[0]] = new Item();
      }
    }
  }
}

class Player {
  PImage texture;
  Item taken[] = new Item[7];

  int health = 100;
  int x;
  int y;
  int itemNum = 0;
  Player(String texture) {
    this.texture = loadImage(texture);
    for (int i = 0; i < 7; i++) {
      taken[i] = new Item();
    }
  }
  boolean canTake() {
    return taken[itemNum].free;
  }
  void draw(Level level) {
    pushStyle();
    imageMode(CENTER);
    rectMode(CENTER);
    stroke(255);
    strokeWeight(2);
    noFill();
    image(texture, width/2, width/2, level.tileSize, level.tileSize);
    drawItems(level);
    popStyle();
  }
  void drawItems(Level level) {
    pushMatrix();
    translate(width/2-int(level.tileSize*3), width);
    for (int i = 0; i < 7; i++) {
      stroke(255);
      rect(i*level.tileSize, 0, level.tileSize*0.8, level.tileSize*0.8);
      if (i==itemNum) {
        stroke(#ff0000);
        noFill();
        rect(i*level.tileSize, 0, level.tileSize*0.8, level.tileSize*0.8);
      }
      if (!taken[i].free) {
        image(level.textures[taken[i].texture-1], i*level.tileSize, 0, level.tileSize*0.6, level.tileSize*0.6);
      }
    }
    translate(int(level.tileSize*3), level.tileSize);
    if (this.health<30)fill(#ff0000);
    else if (this.health<70)fill(#ffff00);
    else fill(#00ff00);
    noStroke();
    rect(0, 0, map(this.health, 0, 100, 0, level.tileSize*7), level.tileSize/4);
    popMatrix();
  }
  Item take(Item item) {
    if (taken[itemNum].free && item.takeable) {
      taken[itemNum] = item;
      itemNum++;
      itemNum%=7;
      return new Item();
    }
    return item;
  }
  void setStartPos(Level level) {
    do {
      this.x = int(random(level.size-1));
      this.y = int(random(level.size-1));
    } while (!level.map[this.y][this.x].free);
  }
  void choose() {
    itemNum+=1;
    itemNum%=7;
  }

  void hitten(Level level) {
    String hittenby="";
    if (level.map[y][x+1].canmove) {
      hittenby = level.map[y][x+1].name;
    }
    if (level.map[y][x-1].canmove) {
      hittenby = level.map[y][x+1].name;
    }
    if (level.map[y+1][x].canmove) {
      hittenby = level.map[y][x+1].name;
    }
    if (level.map[y-1][x].canmove) {
      hittenby = level.map[y][x+1].name;
    }
    if (hittenby=="Bat") {
      this.health-=int(random(5, 10));
    }
    if (hittenby=="Thief") {
      this.health-=int(random(10, 30));
    }
    if (hittenby=="Goblin") {
      this.health-=int(random(30, 50));
    }
    if (hittenby=="Ghoul") {
      this.health-=int(random(50, 60));
    }
    if (hittenby=="Snake") {
      this.health-=int(random(10, 60));
    }
    if (hittenby=="Skeleton") {
      this.health-=int(random(10, 20));
    }
    if (this.health<0)this.health = 0;
  }
  void move(Level level) {
    if (x>0 && x<99 && y>0 && y<99) {
      if (keyCode == RIGHT && (level.map[y][x+1].free || level.map[y][x+1].cangothrough)) {
        x++;
      }
      if (keyCode == LEFT && (level.map[y][x-1].free || level.map[y][x-1].cangothrough)) {
        x--;
      }
      if (keyCode == DOWN && (level.map[y+1][x].free || level.map[y+1][x].cangothrough)) {
        y++;
      }
      if (keyCode == UP && (level.map[y-1][x].free || level.map[y-1][x].cangothrough)) {
        y--;
      }
    }
  }

  void action(Level level) {
    for (int y = this.y-1; y <= this.y+1; y++) {
      for (int x = this.x-1; x <= this.x+1; x++) {
        if (!(x<0 || y<0 || x>level.size || y>level.size)) {
          if (level.map[y][x].canmove) {
            if (taken[itemNum].name == "Sword") {
              level.map[y][x].hardness-=int(random(20, 50));
              taken[itemNum].hardness-=10;
              if (taken[itemNum].hardness<=0)
                taken[itemNum]= new Item();
            }
            if (taken[itemNum].name == "Axe") {
              level.map[y][x].hardness-=int(random(40, 70));
              taken[itemNum].hardness-=10;
              if (taken[itemNum].hardness<=0)
                taken[itemNum]= new Item();
            }
            if (taken[itemNum].name == "Knive") {
              level.map[y][x].hardness-=int(random(10, 20));
              taken[itemNum].hardness-=20;
              if (taken[itemNum].hardness<=0)
                taken[itemNum]= new Item();
            }
          }
        }
      }
    }
  }
}



class Level {
  PImage textures[] = new PImage[15];
  Item map[][];
  int size = 100;
  int tileSize = 20;
  int numLevel;
  Level(int numLevel) {
    map = loadMap(""+numLevel+".map");
    for (int i = 0; i < 15; i ++) {
      textures[i] = loadImage(""+(i+1)+".png");
    }
  }

  int[] find(Item item) {
    int coord[] = new int[2];
    for (int x=0; x <size; x++) {
      for (int y=0; y<size; y++) {
        if (item == this.map[y][x]) {
          coord[0] = x;
          coord[1] = y;
        }
      }
    }
    return coord;
  }
  void draw(Player player) {
    for (int y = player.y-6; y <= player.y+6; y++) {
      for (int x = player.x-6; x <= player.x+6; x++) {
        if (!(x<0 || y<0 || x>size || y>size))
          if (map[y][x].texture!=-1) {
            pushMatrix();
            translate(-(player.x-6)*tileSize, -(player.y-6)*tileSize);
            image(textures[map[y][x].texture-1], x*tileSize, y*tileSize, tileSize, tileSize);
            popMatrix();
          }
      }
    }
  }

  void actions(Player player) {
    player.hitten(this);
    if (punch) {
      punch = false;
      if (player.taken[player.itemNum].name=="Axe") {
        if (map[player.y][player.x].canmove)map[player.y][player.x].hardness-=int(random(30, 40));
        if (map[player.y][player.x].canmove)map[player.y+1][player.x].hardness-=int(random(30, 40));
        if (map[player.y][player.x].canmove)map[player.y-1][player.x].hardness-=int(random(30, 40));
        if (map[player.y][player.x].canmove)map[player.y][player.x+1].hardness-=int(random(30, 40));
        if (map[player.y][player.x].canmove)map[player.y][player.x-1].hardness-=int(random(30, 40));
      }
      if (player.taken[player.itemNum].name=="Sword") {
        if (map[player.y][player.x].canmove)map[player.y][player.x].hardness-=int(random(20, 30));
        if (map[player.y][player.x].canmove)map[player.y+1][player.x].hardness-=int(random(20, 30));
        if (map[player.y][player.x].canmove)map[player.y-1][player.x].hardness-=int(random(20, 30));
        if (map[player.y][player.x].canmove)map[player.y][player.x+1].hardness-=int(random(20, 30));
        if (map[player.y][player.x].canmove)map[player.y][player.x-1].hardness-=int(random(20, 30));
      }
      if (player.taken[player.itemNum].name=="Knive") {
        if (map[player.y][player.x].canmove)map[player.y][player.x].hardness-=int(random(10, 20));
        if (map[player.y][player.x].canmove)map[player.y+1][player.x].hardness-=int(random(10, 20));
        if (map[player.y][player.x].canmove)map[player.y-1][player.x].hardness-=int(random(10, 20));
        if (map[player.y][player.x].canmove)map[player.y][player.x+1].hardness-=int(random(10, 20));
        if (map[player.y][player.x].canmove)map[player.y][player.x-1].hardness-=int(random(10, 20));
      }
    }
    for (int y = player.y-6; y <= player.y+6; y++) {
      for (int x = player.x-6; x <= player.x+6; x++) {
        if (!(x<0 || y<0 || x>size || y>size))
          map[y][x].step(this, player);
      }
    }
  }

  Item[][] loadMap(String levelName) {
    String levelAsStrings[] = loadStrings(levelName);
    int map[][] =new int[size][size];
    for (int i = 0; i<size; i++) {
      String line[] = levelAsStrings[i].split(",");
      for (int j = 0; j <size; j++) {
        map[i][j] = int(line[j]);
      }
    }
    Item mapAsItem[][] = new Item[size][size];
    for (int y = 0; y<size; y++) {
      for (int x = 0; x<size; x++) {
        mapAsItem[y][x] = new Item();
        if (map[y][x]==1) {
          mapAsItem[y][x] = new Item(map[y][x], "Food");//+
        }
        if (map[y][x]==2) {
          mapAsItem[y][x] = new Item(map[y][x], "Knive");//+
        }
        if (map[y][x]==3) {
          mapAsItem[y][x] = new Item(map[y][x], "Axe");//+
        }
        if (map[y][x]==4) {
          mapAsItem[y][x] = new Item(map[y][x], "Sword");//+
        }
        if (map[y][x]==5) {
          mapAsItem[y][x] = new Item(map[y][x], "Key");//+
        }
        if (map[y][x]==6) {
          mapAsItem[y][x] = new Item(map[y][x], "Bat", 5);//+
        }
        if (map[y][x]==7) {
          mapAsItem[y][x] = new Item(map[y][x], "Goblin", 50);//+
        }
        if (map[y][x]==8) {
          mapAsItem[y][x] = new Item(map[y][x], "Thieve", 40);//+
        }
        if (map[y][x]==9) {
          mapAsItem[y][x] = new Item(map[y][x], "Ghoul", 30);//+
        }
        if (map[y][x]==10) {
          mapAsItem[y][x] = new Item(map[y][x], "Skeleton", 20);//+
        }
        if (map[y][x]==11) {
          mapAsItem[y][x] = new Item(map[y][x], "Snake", 10);//+
        }
        if (map[y][x]==12) {
          mapAsItem[y][x] = new Item(map[y][x], true);//+
        }
        if (map[y][x]==13) {
          mapAsItem[y][x] = new Item(map[y][x], false);
        }
        if (map[y][x]==14) {
          mapAsItem[y][x] = new Item(map[y][x], false);
        }
        if (map[y][x]==15) {
          mapAsItem[y][x] = new Item(map[y][x], false);
        }
      }
    }
    return mapAsItem;
  }
}

int levelNum = -1;
void nextLevel() {
  levelNum++;
  if (levelNum<5) {
    currentLevel = new Level(levelNum);
    player.setStartPos(currentLevel);
  }
}


Player player;
Level currentLevel;
boolean punch = false;


void setup() {
  player = new Player("p.png");

  
  size(260, 290);
  
  textFont(createFont("FsJenson1ItalicRegular.ttf", 100));
  
  textAlign(CENTER);
}

void draw() {
  background(0);
  if (levelNum!=5 && levelNum!=-1) {
    currentLevel.draw(player);
    player.draw(currentLevel);
  } else if (levelNum==5) {
    fill(#FFAC05);
    textSize(40);
    text("You win!!!", width/2, height/2);
  } else if (levelNum==-1){
    fill(#ff0000);
    textSize(60);
    text("LONE", width/2, 90);
    fill(#FFAC05);
    if (millis()%1000<500) {
      textSize(30);
      text("Press Any Key!!!", width/2, height/2);
    }
    fill(255);
    textSize(20);
    text("RetroCat", width/6, height-10);
  }
}

void keyReleased() {
  if (levelNum!=5 || levelNum!=-1) {
    if (key == 'q') {
      if (currentLevel.map[player.y][player.x].takeable && player.canTake()) {
        currentLevel.map[player.y][player.x] = player.take(currentLevel.map[player.y][player.x]);
      }
      player.taken[player.itemNum] = player.taken[player.itemNum].use(player);
      player.action(currentLevel);
    }
    if (key == 'w') {
      player.choose();
    } else {
      player.move(currentLevel);
    }
    if (key !='w') {
      currentLevel.actions(player);
    }
  } 
  if (levelNum==-1) {
    nextLevel();
  }
}
