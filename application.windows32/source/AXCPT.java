import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AXCPT extends PApplet {

char AXkey = '/';  
char otherkey = 'x';
char upotherkey = 'X';
int fix1dur = 60;
int cuedur = 12; //in frame counts; in msec = 180;
int fix2dur = 60; //two fix : before and after stim
int stimdur = 12;
int ITI = 0;
boolean jumpahead = false;

int index, rowCount=0;
int bgcolor = 255; //black = 0, 128 gray, 255 white; 
IntList trialnums = new IntList();
Table tmptable, table;
int saveTime = frameCount+1000000;
int stimTime, respTime, stimframe;
boolean stimflag=true, FirstPicFlag=true, noMore = true, init = true;
boolean showcue=false, showfix1=false, showstim=false, showfix2=false, showstimflag=true, showITI=false;
TableRow row;
char cue, stim, correctresp;


String instructionText = "Press space to begin.\nYou may have to click on this screen first.\nPress '/' when an 'X' is after an 'A', else press 'X'";
int imagewidth, imageheight;

public void setup() {
  background(bgcolor);
  textAlign(CENTER);
  frameRate(60);
  
  textSize(32);
  fill(0);
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
  ITI = round(PApplet.parseInt(row.getInt("ITI"))*0.06f);
  println(ITI);
  FirstPicFlag = true;
}

public void draw() {
  if (saveTime+fix1dur+cuedur+fix2dur+stimdur+ITI<frameCount) { //when eveything starts anew
    saveTime = frameCount;
    showstimflag=true;
    rowCount += 1;
    //println("rowcount += 1");
    if (rowCount >= table.getRowCount()-1) {
      //it's over, baby
      String dayS = String.valueOf(day());
      String hourS = String.valueOf(hour());
      String minuteS = String.valueOf(minute());
      String myfilename = "AS3out"+"-"+dayS+"-"+hourS+"-"+minuteS+".csv";
      saveTable(table, myfilename, "csv");
      //println("Exit");
      exit();
    }

    FirstPicFlag = true;
    noMore = true;
  } else if (saveTime+fix1dur+cuedur+fix2dur+stimdur<frameCount) {
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=false;
    showITI = true;
  } else if (saveTime+fix1dur+cuedur+fix2dur<frameCount) {
    showfix1=false; 
    showcue=false;
    showfix2=false;
    showstim=true;
    showITI = false;
  } else if (saveTime+fix1dur+cuedur<frameCount) {
    showfix1=false; 
    showcue=false;
    showfix2=true;
    showstim=false;
    showITI = false;
  } else if (saveTime+fix1dur<frameCount) {
    showfix1=false; 
    showcue=true;
    showfix2=false;
    showstim=false;
    showITI = false;
  } else if (saveTime<frameCount) {
    if (FirstPicFlag) {
      //println("First flag");
      row = table.getRow(rowCount);
      cue = (row.getString("cue")).charAt(0);
      stim = (row.getString("stim")).charAt(0);
      correctresp = (row.getString("correctresp")).charAt(0);
      ITI = round(PApplet.parseInt(row.getInt("ITI"))*0.06f);
      println(ITI);
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
    text(cue, width/2, height/2);
    //text("2", width/2, height/2);
  } else if (showfix2) {
    background(bgcolor);
    text("+", width/2, height/2);
    //text("3", width/2, height/2);
  } else if (showstim) {
    background(bgcolor);
    text(stim, width/2, height/2);
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
    text(instructionText, width/2, height/2);
  }
}



public void keyPressed() {

  if (key == ' ') {
    saveTime = frameCount+6;
    init = false;
    showcue = true;
    background(bgcolor);
  }
  if (key == AXkey && noMore) {
    //println("left");
    noMore = false;
    respTime = millis();
    table.setString(rowCount, "answer", str(AXkey));
    table.setInt(rowCount, "correct", PApplet.parseInt(AXkey == correctresp));
    //println(Integer.parseInt(str(leftkey)),left);
    table.setFloat(rowCount, "RT", respTime-stimTime);
  }
  if ((key == otherkey || key == upotherkey) && noMore) {
    //println("right");
    noMore = false;
    respTime = millis();
    table.setString(rowCount, "answer", str(otherkey));
    table.setInt(rowCount, "correct", PApplet.parseInt(otherkey == correctresp));
    //println(Integer.parseInt(str(rightkey)),left);
    table.setFloat(rowCount, "RT", respTime-stimTime);
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "AXCPT" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
