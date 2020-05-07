function cuestimTable = GenAXCPTtable(numAX,numAY,numYY,ispractice)
AlphabetNoAX = 'BCDEFGHIJKLMNOPQRSTUVWYZ';
A = 'A';
X = 'X';
ITIs = [1500,2000,2500];
cue = repmat(A,numAX,1);
stim = repmat(X,numAX,1);
ITI = ITIs(randi(3,numAX,1))';
category = repmat('AX',numAX,1);
correctresp = repmat('/',numAX,1);
cuestimTable = table(cue,stim,ITI,category,correctresp);
cue = repmat(A,numAY,1);
stim = AlphabetNoAX(randi(24,numAY,1))';
ITI = ITIs(randi(3,numAY,1))';
category = repmat('AY',numAY,1);
correctresp = repmat('x',numAY,1);
cuestimTable = [cuestimTable; table(cue,stim,ITI,category,correctresp)];
cue = AlphabetNoAX(randi(24,numYY,1))';
stim = AlphabetNoAX(randi(24,numYY,1))';
ITI = ITIs(randi(3,numYY,1))';
category = repmat('YY',numYY,1);
correctresp = repmat('x',numYY,1);
cuestimTable = [cuestimTable; table(cue,stim,ITI,category,correctresp)];
%cuestimTable = cuestimTable(randperm(height(cuestimTable)),:); 
%randomization happens in processing
cuestimTable.response = repmat({''},height(cuestimTable),1);
cuestimTable.RT = repmat(0.0,height(cuestimTable),1);
cuestimTable.correct = repmat(0,height(cuestimTable),1);
cuestimTable.cuecolor = randi(1,height(cuestimTable),1);
cuestimTable.stimcolor = randi(1,height(cuestimTable),1);
cuestimTable.ispractice = repmat(ispractice,height(cuestimTable),1);

    