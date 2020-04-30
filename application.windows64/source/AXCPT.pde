int textsize = 64;
char AXkey = '/';  
char otherkey = 'x';
char upotherkey = 'X';
int timemult = 1;
int fix1dur = 60*timemult;
int cuedur = 12*timemult; //in frame counts; in msec = 180;
int fix2dur = 60*timemult; //two fix : before and after stim
int stimdur = 12*timemult;
int ITI = 0;
boolean jumpahead = false;
int initscreen = 1;
import processing.sound.*;
SoundFile soundfile;

int index, rowCount=0;
int bgcolor = 255; //black = 0, 128 gray, 255 white; 
IntList trialnums = new IntList();
Table tmptable, table;
int saveTime = frameCount+1000000;
int stimTime, respTime, stimframe;
boolean stimflag=true, FirstPicFlag=true, noMore = true, init = true, playflag=true;
boolean showcue=false, showfix1=false, showstim=false, showfix2=false, showstimflag=true, showITI=false;
TableRow row;
char cue, stim, correctresp;
int cuecolor, stimcolor;


String instructionText = "Press space to begin.\nYou may have to click on this screen first.\nPress '/' when an 'X' is after an 'A', else press 'X'";
int imagewidth, imageheight;

void setup() {
  background(bgcolor);
  textAlign(CENTER);
  frameRate(60);
  fullScreen();
  textSize(textsize);
  fill(0);
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
  for (int i = 0; i < tmptable.getRowCount(); i++) {
    trialnums.append(i);
  }
  trialnums.shuffle();
  for (int i = 0; i < tmptable.getRowCount(); i++) {
    index = trialnums.get(i);
    row = tmptable.getRow(index);
    table.addRow(row);
  }
  saveTable(table, "temp.csv");
  row = table.getRow(0);
  cue = (row.getString("cue")).charAt(0);
  stim = (row.getString("stim")).charAt(0);
  correctresp = (row.getString("correctresp")).charAt(0);
  ITI = round(int(row.getInt("ITI"))*0.06)*timemult;
  cuecolor = row.getInt("cuecolor");
  stimcolor = row.getInt("stimcolor");
  //println(ITI);
  FirstPicFlag = true;
  showfix1=false; 
  showcue=false;
  showfix2=false;
  showstim=false;
  showITI = false;
}

void draw() {
  if (saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI<frameCount) { //when eveything starts anew
    //println("1");
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=false;
    showITI = false;
    saveTime = frameCount;
    showstimflag=true;
    rowCount += 1;
    FirstPicFlag = true;
    noMore = true;
    if (rowCount >= table.getRowCount()-1) {
      exit();
    }
  } else if (saveTime+fix1dur+cuedur+fix2dur+stimdur<frameCount) {
    //println("2");
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=false;
    showITI = true;
  } else if (saveTime+fix1dur+cuedur+fix2dur<frameCount) {
    //println("3");
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=true;
    showITI = false;
  } else if (saveTime+fix1dur+cuedur<frameCount) {
    //println("4");
    showfix1=false; 
    showcue=false;
    showfix2=true;
    showstim=false;
    showITI = false;
  } else if (saveTime+fix1dur<frameCount) {
    //println("5");
    showfix1=false; 
    showcue=true;
    showfix2=false;
    showstim=false;
    showITI = false;
  } else if (saveTime<frameCount) {
    if (FirstPicFlag) {
      //println("6");
      row = table.getRow(rowCount);
      cue = (row.getString("cue")).charAt(0);
      stim = (row.getString("stim")).charAt(0);
      correctresp = (row.getString("correctresp")).charAt(0);
      ITI = round(int(row.getInt("ITI"))*0.06);
      cuecolor = row.getInt("cuecolor");
      stimcolor = row.getInt("stimcolor");
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
      fill(0, 0, 255);
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
      fill(0, 0, 255);
    } else if (stimcolor == 2) {
      fill(0, 255, 0);
    } else if (stimcolor == 3) {
      fill(255, 0, 0);
    };
    text(stim, width/2, height/2);
    fill(0, 0, 0);
    //text("4", width/2, height/2);
    if (showstimflag) {
      stimframe = frameCount;
      stimTime = millis();
      showstimflag = false;
    }
  } else if (showITI) {
    background(bgcolor);
    //text("5", width/2, height/2);
  }
  if (init) {
    if (initscreen == 1) {
      text(instructionText, width/2, height/2);
      //println("-1");
    } else {
      if (playflag) {
        background(bgcolor);
        soundfile.play();
        playflag = false;
      }
      if (!soundfile.isPlaying()) {
        text("Press space bar to continue", width/2, height/2);
      }
    }
  }
}



void keyPressed() {

  if (key == ' ') {
    if (initscreen>1) {
      init = false;
      showcue = true;
      //println("0");
      background(bgcolor);
      delay(500);
      saveTime = frameCount; //+saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI;
    } else {
      initscreen += 1;
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
  String myfilename = "AS3out"+"-"+dayS+"-"+hourS+"-"+minuteS+".csv";
  saveTable(table, myfilename, "csv");

  println("exiting");
  super.exit();
}
