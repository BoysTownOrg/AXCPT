int textsize = 64;
char AXkey = '/';  
char otherkey = 'x';
char upotherkey = 'X';
int timemult = 1;
int fix1dur = 1000*timemult; //in  msec;
int cuedur = 200*timemult; 
int fix2dur = 1000*timemult; //two fix : before and after stim
int stimdur = 200*timemult;
int ITI = 0;
boolean jumpahead = false;
int initscreen = 1;
import processing.sound.*;
SoundFile soundfile;

int index, rowCount=0;
int bgcolor = 255; //black = 0, 128 gray, 255 white; 
IntList trialnums = new IntList();
Table tmptable, table;
int saveTime = millis()+1000000;
int stimTime, respTime;
boolean stimflag=true, FirstPicFlag=true, noMore = true, init = true, playflag=true, expStarted=false;
boolean showcue=false, showfix1=false, showstim=false, showfix2=false, showstimflag=true, showITI=false;
TableRow row;
char cue, stim, correctresp;
int cuecolor, stimcolor, ispractice;

String [] firstInstructions, pracInstructions, expInstructions;

String firstinstructionText, pracinstructionText, expinstructionText; 
int imagewidth, imageheight;

void setup() {
  background(bgcolor);
  textAlign(CENTER);
  //frameRate(60);
  fullScreen();
  textSize(textsize);
  fill(0);
  firstInstructions = loadStrings("FirstInstructions.txt");
  pracInstructions = loadStrings("PracInstructions.txt");
  expInstructions = loadStrings("ExpInstructions.txt");
  firstinstructionText = join(firstInstructions, "\n");
  pracinstructionText = join(pracInstructions, "\n");
  expinstructionText = join(expInstructions, "\n");
  soundfile = new SoundFile(this, "Count.wav");
  tmptable = loadTable("AXCPT.csv", "header");
  table = new Table();
  table.addColumn("cue");
  table.addColumn("stim");
  table.addColumn("ITI");
  table.addColumn("category");
  table.addColumn("correctresp");
  table.addColumn("response");
  table.addColumn("RT");
  table.addColumn("correct");
  table.addColumn("cuecolor");
  table.addColumn("stimcolor");
  table.addColumn("ispractice");
  for (int i = 0; i < tmptable.getRowCount(); i++) {
    trialnums.append(i);
  }
  trialnums.shuffle();
  for (int i = 0; i < tmptable.getRowCount(); i++) {
    index = trialnums.get(i);
    row = tmptable.getRow(index);
    table.addRow(row);
  }
  table.sortReverse("ispractice");
  saveTable(table, "temp.csv");
  row = table.getRow(0);
  cue = (row.getString("cue")).charAt(0);
  stim = (row.getString("stim")).charAt(0);
  correctresp = (row.getString("correctresp")).charAt(0);
  ITI = round(int(row.getInt("ITI")))*timemult;
  cuecolor = row.getInt("cuecolor");
  stimcolor = row.getInt("stimcolor");
  ispractice = row.getInt("ispractice");
  //println(ITI);
  FirstPicFlag = true;
  showfix1=false; 
  showcue=false;
  showfix2=false;
  showstim=false;
  showITI = false;
}

void draw() {
  if (saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI<millis()) { //when eveything starts anew
    //println("inc rowcount",rowCount);
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=false;
    showITI = false;
    saveTime = millis();
    showstimflag=true;
    rowCount += 1;
    FirstPicFlag = true;
    noMore = true;
    if (rowCount >= table.getRowCount()-1) {
      exit();
    }
  } else if (saveTime+fix1dur+cuedur+fix2dur+stimdur<millis()) {
    //println("2");
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=false;
    showITI = true;
  } else if (saveTime+fix1dur+cuedur+fix2dur<millis()) {
    //println("3");
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=true;
    showITI = false;
  } else if (saveTime+fix1dur+cuedur<millis()) {
    //println("4");
    showfix1=false; 
    showcue=false;
    showfix2=true;
    showstim=false;
    showITI = false;
  } else if (saveTime+fix1dur<millis()) {
    //println("5");
    showfix1=false; 
    showcue=true;
    showfix2=false;
    showstim=false;
    showITI = false;
  } else if (saveTime<millis()) {
    if (FirstPicFlag) {
      //println("6");
      row = table.getRow(rowCount);
      cue = (row.getString("cue")).charAt(0);
      stim = (row.getString("stim")).charAt(0);
      correctresp = (row.getString("correctresp")).charAt(0);
      ITI = round(int(row.getInt("ITI")));
      cuecolor = row.getInt("cuecolor");
      stimcolor = row.getInt("stimcolor");
      ispractice = row.getInt("ispractice");
      if ((ispractice == 0) && !expStarted) {
        //println("xxxx");
        rowCount -= 1;
        expStarted = true;
        noLoop();
        init = true;
        initscreen=4;
      }
      //println(ITI);
      FirstPicFlag = false;

      showfix1=true; 
      showcue=false;
      showfix2=false;
      showstim=false;
      showITI = false;
    }
  }

  if (showfix1) {
    background(bgcolor);
    text("+", width/2, height/2);
    //text("1", width/2, height/2);
  } else if (showcue) {
    background(bgcolor);
    if (cuecolor == 1) {
      fill(0, 0, 0);
    } else if (cuecolor == 2) {
      fill(0, 255, 0);
    } else if (cuecolor == 3) {
      fill(255, 0, 0);
    };
    text(cue, width/2, height/2);
    fill(0, 0, 0);
    //text("2", width/2, height/2);
  } else if (showfix2) {
    background(bgcolor);
    text("+", width/2, height/2);

    //text("3", width/2, height/2);
  } else if (showstim) {
    background(bgcolor);
    if (stimcolor == 1) {
      fill(0, 0, 0);
    } else if (stimcolor == 2) {
      fill(0, 255, 0);
    } else if (stimcolor == 3) {
      fill(255, 0, 0);
    };
    text(stim, width/2, height/2);
    fill(0, 0, 0);
    //text("4", width/2, height/2);
    if (showstimflag) {
      stimTime = millis();
      showstimflag = false;
    }
  } else if (showITI) {
    background(bgcolor);
    //text("5", width/2, height/2);
  }
  if (init) {
    if (initscreen == 1) {
      textSize(textsize/2);
      text(firstinstructionText, width/16, height/4, width*7/8, height*3/4);
      textSize(textsize);
      //println("-1");
    } else if (initscreen == 2) {
      background(bgcolor);
      textSize(textsize/2);
      text(pracinstructionText, width/16, height/4, width*7/8, height*3/4);
      textSize(textsize);
    } else if (initscreen == 3) {
      init = false;
      showcue = true;
      //println("2 ", initscreen);
      background(bgcolor);
      delay(500);
      saveTime = millis(); //+saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI;
    } else if (initscreen == 4) {
      background(bgcolor);
      textSize(textsize/2);
      text(expinstructionText, width/16, height/4, width*7/8, height*3/4);
      textSize(textsize);
    }
  }
}



void keyPressed() {

  if (key == ' ') {
    if (initscreen>2) {
      init = false;
      showcue = true;
      //println("0 ", initscreen);
      if (!looping) {
        loop();
      }
      background(bgcolor);
      delay(500);
      saveTime = millis(); //+saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI;
    } else {
      initscreen += 1;
      //println("1 ", initscreen);
    }
  }
  if (key == AXkey && noMore) {
    //println("left");
    noMore = false;
    respTime = millis();
    table.setString(rowCount, "response", str(AXkey));
    table.setInt(rowCount, "correct", int(AXkey == correctresp));
    //println(Integer.parseInt(str(leftkey)),left);
    table.setFloat(rowCount, "RT", respTime-stimTime);
  }
  if ((key == otherkey || key == upotherkey) && noMore) {
    //println("right");
    noMore = false;
    respTime = millis();
    table.setString(rowCount, "response", str(otherkey));
    table.setInt(rowCount, "correct", int(otherkey == correctresp));
    //println(Integer.parseInt(str(rightkey)),left);
    table.setFloat(rowCount, "RT", respTime-stimTime);
  }
}
void exit() {
  //it's over, baby
  String dayS = String.valueOf(day());
  String hourS = String.valueOf(hour());
  String minuteS = String.valueOf(minute());
  String myfilename = "AXCPTout"+"-"+dayS+"-"+hourS+"-"+minuteS+".csv";
  saveTable(table, myfilename, "csv");

  //println("exiting");
  super.exit();
}
