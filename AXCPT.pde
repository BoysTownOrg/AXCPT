import boystown.processing.util.*;
import processing.sound.*;

private DrawTimer timer;

int bgcolor = 255; //black = 0, 128 gray, 255 white; 
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
SoundFile soundfile;

int index, rowCount=0;
IntList trialnums = new IntList();
Table tmptable, table;
int saveTime = frameCount+1000000;
int stimTime, respTime, stimframe;
boolean FirstPicFlag=true, noMore = true, init = true, playflag=true;
boolean showstimflag = true;
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

  timer = new DrawTimer(new ProcessingScreen(this), new SystemTimer());
}

void draw() {
  if (saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI<frameCount) { //when eveything starts anew
    //println("1");
    showstimflag=true;
    saveTime = frameCount;
    rowCount += 1;
    FirstPicFlag = true;
    noMore = true;
    if (rowCount >= table.getRowCount()-1) {
      exit();
    }
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

      timer.invokeAfter(DrawTimer.Time.fromMilliseconds(0), new ShowFirstFixation(timer, this));
    }
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
      background(bgcolor);
      delay(500);
      if (cuecolor == 1) {
        fill(0, 0, 255);
      } else if (cuecolor == 2) {
        fill(0, 255, 0);
      } else if (cuecolor == 3) {
        fill(255, 0, 0);
      };
      text(cue, width/2, height/2);
      fill(0, 0, 0);
      //println("0");
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

public static class ShowFirstFixation implements DrawTimer.Callback {
    ShowFirstFixation(DrawTimer timer, AXCPT parent) {
        this.timer = timer;
        this.parent = parent;
    }

    @Override
    public void f() {
        parent.background(parent.bgcolor);
        parent.text("+", parent.width/2, parent.height/2);
        timer.invokeAfter(DrawTimer.Time.fromMilliseconds(1000), new ShowCue(timer, parent));
    }

    private AXCPT parent;
    private DrawTimer timer;
}

public static class ShowCue implements DrawTimer.Callback {
    ShowCue(DrawTimer timer, AXCPT parent) {
        this.timer = timer;
        this.parent = parent;
    }

    @Override
    public void f() {
        parent.background(parent.bgcolor);
        if (parent.cuecolor == 1) {
          parent.fill(0, 0, 255);
        } else if (parent.cuecolor == 2) {
          parent.fill(0, 255, 0);
        } else if (parent.cuecolor == 3) {
          parent.fill(255, 0, 0);
        };
        parent.text(parent.cue, parent.width/2, parent.height/2);
        parent.fill(0, 0, 0);
        timer.invokeAfter(DrawTimer.Time.fromMilliseconds(200), new ShowSecondFixation(timer, parent));
    }

    private AXCPT parent;
    private DrawTimer timer;
}

public static class ShowSecondFixation implements DrawTimer.Callback {
    ShowSecondFixation(DrawTimer timer, AXCPT parent) {
        this.timer = timer;
        this.parent = parent;
    }

    @Override
    public void f() {
        parent.background(parent.bgcolor);
        parent.text("+", parent.width/2, parent.height/2);
        timer.invokeAfter(DrawTimer.Time.fromMilliseconds(1000), new ShowStimulus(timer, parent));
    }

    private AXCPT parent;
    private DrawTimer timer;
}

public static class ShowStimulus implements DrawTimer.Callback {
    ShowStimulus(DrawTimer timer, AXCPT parent) {
        this.timer = timer;
        this.parent = parent;
    }

    @Override
    public void f() {
        parent.background(parent.bgcolor);
        if (parent.stimcolor == 1) {
          parent.fill(0, 0, 255);
        } else if (parent.stimcolor == 2) {
          parent.fill(0, 255, 0);
        } else if (parent.stimcolor == 3) {
          parent.fill(255, 0, 0);
        };
        parent.text(parent.stim, parent.width/2, parent.height/2);
        parent.fill(0, 0, 0);
        if (parent.showstimflag) {
          parent.stimframe = parent.frameCount;
          parent.stimTime = parent.millis();
          parent.showstimflag = false;
        }
        timer.invokeAfter(DrawTimer.Time.fromMilliseconds(200), new ShowIntertrialInterval(parent));
    }

    private AXCPT parent;
    private DrawTimer timer;
}

public static class ShowIntertrialInterval implements DrawTimer.Callback {
    ShowIntertrialInterval(AXCPT parent) {
        this.parent = parent;
    }

    @Override
    public void f() {
        parent.background(parent.bgcolor);
    }

    private AXCPT parent;
}
