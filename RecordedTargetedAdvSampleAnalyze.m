% Based on Recorded original file, Targeted Adversarial Sample Comparision.
clc;
clear all;
targetedCsvFile = '/home/hxie1/Projects/DeepSpeech/data/RecordOrgWTargetAdv20181130.csv'; 
recordFileDir = '/home/hxie1/Projects/DeepSpeech/data/originalWaveRecord';
originalWavDir = '/home/hxie1/Projects/DeepSpeech/data/originalWave';   
%targetedAdvWavDir = '/home/hxie1/Projects/DeepSpeech/data/targetedAdvWave'; 
%reconstrWavDir = '/home/hxie1/Projects/DeepSpeech/data/reconstrWave';
dataDir = '/home/hxie1/Projects/DeepSpeech/data';

% read csv file
%  ['Text#, Origin_Text_Wave, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text, \n\r']
%   Var1       Var2                  Var3             Var4             Var5
targetedCsv = table2cell(readtable(targetedCsvFile, 'HeaderLines', 0));
[N,colW] = size(targetedCsv);

% generated file head
c = clock;
timeStr = sprintf('%4d%02d%02d-%02d%02d',c(1),c(2),c(3),c(4),c(5));
targetedAdvStatis = strcat(dataDir,'/RecordedTargetAdvAndNormalXCorr', timeStr, '.csv');
fileID = fopen(targetedAdvStatis, 'w');
% print csv file table header
fprintf(fileID, ['Text#, Origin_Text, Target_Text, DeepSpeech_Recog_RecordText, DeepSpeech_Recog_Advesarial_Text,  '...
                  'MaxXCorr_Genuine_Record, '...
                  'XCorr_Record_Adv, XCorr_Record_AdvRecon, XCorr_Adv_AdvRecon, Corr_Record_NormalRecon, \n\r']);

for i= 1: N
% read original T1 wave file;
   if (i ~= targetedCsv{i,1})
       fprintf('the %d line in csv file has incorrect text# \n', i);
       return;
   end
   genuineFile = sprintf('%s/T%d.wav',originalWavDir, i);
   recordedFile = sprintf('%s/T%d-Record.wav',recordFileDir, i);
   advWavFile = sprintf('%s/T%d-Record-Ad.wav',recordFileDir, i);
   
   % generate recontruction for adversarial text
   advText = targetedCsv{i, 5};
   reconstAdvWavFile = sprintf('%s/T%d-Record-Ad-Recon.wav',recordFileDir, i);
   [s, cmdoutT2S] = system(sprintf('pico2wave --wave=%s  "%s"',  reconstAdvWavFile, advText)); % natural voice
   if 0 ~= s
       disp(cmdoutT2S);
       fprintf("text 2 speech error at output %s, with the %dth text\n", reconstAdvWavFile, i);
       break;
   end
   
   % generate recontruction for normal text
   normalText = targetedCsv{i, 4};
   reconstNormalFile = sprintf('%s/T%d-Record-Normal-Recon.wav',recordFileDir, i);
   [s, cmdoutT2S] = system(sprintf('pico2wave --wave=%s  "%s"',  reconstNormalFile, normalText)); % natural voice
   if 0 ~= s
       disp(cmdoutT2S);
       fprintf("text 2 speech error at output %s, with the %dth text\n", reconstNormalFile, i);
       break;
   end
   
   
   % ['Text#, Origin_Text, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text,  Corr_O_A, Corr_O_R, Corr_A_R, \n\r']
   fprintf(fileID, ['%d, %s, %s, %s, %s,  %9.6f, %9.6f, %5.2f, %5.2f, %5.2f,\n\r'], i, targetedCsv{i,2}, targetedCsv{i,3}, targetedCsv{i,4}, targetedCsv{i,5},...
                     Xcorrelation(genuineFile, recordedFile),...
                 Xcorrelation(recordedFile, advWavFile), Xcorrelation(recordedFile, reconstAdvWavFile), Xcorrelation(advWavFile, reconstAdvWavFile), ...
                 Xcorrelation(recordedFile, reconstNormalFile));

end

% close file
fclose(fileID);

disp('============End of Generating Correlaltion Coefficient Statistic File ============');
