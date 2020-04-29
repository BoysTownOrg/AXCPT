AlphabetNoAX = 'BCDEFGHIJKLMNOPQRSTUVWYZ';
A = 'A';
X = 'X';
ITIs = [1500,2000,2500];
cue = repmat(A,32,1);
stim = repmat(X,32,1);
ITI = ITIs(randi(3,32,1))';
category = repmat('AX',32,1);
correctresp = repmat('/',32,1);
cuestimTable = table(cue,stim,ITI,category,correctresp);
cue = repmat(A,64,1);
stim = AlphabetNoAX(randi(24,64,1))';
ITI = ITIs(randi(3,64,1))';
category = repmat('AY',64,1);
correctresp = repmat('x',64,1);
cuestimTable = [cuestimTable; table(cue,stim,ITI,category,correctresp)];
cue = AlphabetNoAX(randi(24,64,1))';
stim = AlphabetNoAX(randi(24,64,1))';
ITI = ITIs(randi(3,64,1))';
category = repmat('AY',64,1);
correctresp = repmat('x',64,1);
cuestimTable = [cuestimTable; table(cue,stim,ITI,category,correctresp)];
%cuestimTable = cuestimTable(randperm(height(cuestimTable)),:); 
%randomization happens in processing
cuestimTable.response = repmat({''},height(cuestimTable),1);
cuestimTable.RT = repmat(0.0,height(cuestimTable),1);
cuestimTable.correct = repmat(0,height(cuestimTable),1);
writetable(cuestimTable,'.\data\AXCPT.csv');
    