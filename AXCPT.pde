import boystown.processing.util.*;
import processing.sound.*;

private DrawTimer timer;
private static final DrawTimer.Time firstFixationDuration =
  DrawTimer.Time.fromMilliseconds(1000);
private static final DrawTimer.Time cueDuration =
  DrawTimer.Time.fromMilliseconds(200);
private static final DrawTimer.Time secondFixationDuration =
  DrawTimer.Time.fromMilliseconds(1000);
private static final DrawTimer.Time stimulusDuration =
  DrawTimer.Time.fromMilliseconds(200);
private final DrawTimer.Callback presentTrial =
  new ShowFirstFixation_Cue_SecondFixation_Stimulus_IntertrialIntervalThenPrepareNext();

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

    timer.invokeAfter(DrawTimer.Time.fromMilliseconds(0), presentTrial);
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

public class ShowFirstFixation_Cue_SecondFixation_Stimulus_IntertrialIntervalThenPrepareNext
  implements DrawTimer.Callback {
  private final DrawTimer.Callback next =
    new ShowCue_SecondFixation_Stimulus_IntertrialIntervalThenPrepareNext();
  
  @Override
  public void f() {
    background(bgcolor);
    text("+", width/2, height/2);
    timer.invokeAfter(firstFixationDuration, next);
  }
}

public class ShowCue_SecondFixation_Stimulus_IntertrialIntervalThenPrepareNext
implements DrawTimer.Callback {
  private final DrawTimer.Callback next =
    new ShowSecondFixation_Stimulus_IntertrialIntervalThenPrepareNext();
  
  @Override
  public void f() {
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
    timer.invokeAfter(cueDuration, next);
  }
}

public class ShowSecondFixation_Stimulus_IntertrialIntervalThenPrepareNext
  implements DrawTimer.Callback {
  private final DrawTimer.Callback next =
    new ShowStimulus_IntertrialIntervalThenPrepareNext();
  
  @Override
  public void f() {
    background(bgcolor);
    text("+", width/2, height/2);
    timer.invokeAfter(secondFixationDuration, next);
  }
}

public class ShowStimulus_IntertrialIntervalThenPrepareNext
implements DrawTimer.Callback {
  private final DrawTimer.Callback next =
    new ShowIntertrialIntervalThenPrepareNext();
  
  @Override
  public void f() {
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
    stimTime = millis();
    timer.invokeAfter(stimulusDuration, next);
  }
}

public class ShowIntertrialIntervalThenPrepareNext implements DrawTimer.Callback {
  private final DrawTimer.Callback next = new PrepareNextTrial();

  @Override
  public void f() {
    background(bgcolor);
    timer.invokeAfter(DrawTimer.Time.fromMilliseconds(ITI), next);
  }
}

public class PrepareNextTrial implements DrawTimer.Callback {
  @Override
  public void f() {
    rowCount += 1;
    FirstPicFlag = true;
    noMore = true;
    if (rowCount >= table.getRowCount()-1) {
      exit();
    }
  }
}
