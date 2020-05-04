import boystown.processing.util.*;
import processing.sound.*;

private DrawTimer timer;

int bgcolor = 255; //black = 0, 128 gray, 255 white; 
int textsize = 64;
char AXkey = '/';  
char otherkey = 'x';
char upotherkey = 'X';
int ITI = 0;
int initscreen = 1;
SoundFile soundfile;

int rowCount=0;
IntList trialnums = new IntList();
Table table;
int stimTime, respTime;
boolean FirstPicFlag=true, noMore = true, init = true, playflag=true;
TableRow row;
char cue, stim, correctresp;
int cuecolor, stimcolor;

String instructionText = "Press space to begin.\nYou may have to click on this screen first.\nPress '/' when an 'X' is after an 'A', else press 'X'";

void setup() {
  background(bgcolor);
  textAlign(CENTER);
  frameRate(60);
  fullScreen();
  textSize(textsize);
  fill(0);
  soundfile = new SoundFile(this, "Count.wav");
  Table tmptable = loadTable("AXCPT.csv", "header");
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
    int index = trialnums.get(i);
    row = tmptable.getRow(index);
    table.addRow(row);
  }
  saveTable(table, "temp.csv");

  FirstPicFlag = true;

  timer = new DrawTimer(new ProcessingScreen(this), new SystemTimer());
}

void draw() {
  if (init) {
    if (initscreen == 1) {
      text(instructionText, width/2, height/2);
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
  else if (FirstPicFlag) {
    row = table.getRow(rowCount);
    cue = (row.getString("cue")).charAt(0);
    stim = (row.getString("stim")).charAt(0);
    correctresp = (row.getString("correctresp")).charAt(0);
    ITI = row.getInt("ITI");
    cuecolor = row.getInt("cuecolor");
    stimcolor = row.getInt("stimcolor");
    FirstPicFlag = false;

    timer.invokeAfter(DrawTimer.Time.fromMilliseconds(0), new ShowFirstFixation(timer, this));
  }
}

void keyPressed() {
  if (key == ' ') {
    if (initscreen>1) {
      init = false;
      background(bgcolor);
      delay(500);
    } else {
      initscreen += 1;
    }
  }
  if (key == AXkey && noMore) {
    noMore = false;
    respTime = millis();
    table.setString(rowCount, "response", str(AXkey));
    table.setInt(rowCount, "correct", int(AXkey == correctresp));
    table.setFloat(rowCount, "RT", respTime-stimTime);
  }
  if ((key == otherkey || key == upotherkey) && noMore) {
    noMore = false;
    respTime = millis();
    table.setString(rowCount, "response", str(otherkey));
    table.setInt(rowCount, "correct", int(otherkey == correctresp));
    table.setFloat(rowCount, "RT", respTime-stimTime);
  }
}

void exit() {
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
        parent.stimTime = parent.millis();
        timer.invokeAfter(DrawTimer.Time.fromMilliseconds(200), new ShowIntertrialInterval(timer, parent));
    }

    private AXCPT parent;
    private DrawTimer timer;
}

public static class ShowIntertrialInterval implements DrawTimer.Callback {
    ShowIntertrialInterval(DrawTimer timer, AXCPT parent) {
        this.timer = timer;
        this.parent = parent;
    }

    @Override
    public void f() {
        parent.background(parent.bgcolor);
        timer.invokeAfter(DrawTimer.Time.fromMilliseconds(parent.ITI), new Anew(parent));
    }

    private AXCPT parent;
    private DrawTimer timer;
}


public static class Anew implements DrawTimer.Callback {
    Anew(AXCPT parent) {
        this.parent = parent;
    }

    @Override
    public void f() {
      parent.rowCount += 1;
      parent.FirstPicFlag = true;
      parent.noMore = true;
      if (parent.rowCount >= parent.table.getRowCount()-1) {
        parent.exit();
      }
    }

    private AXCPT parent;
}
