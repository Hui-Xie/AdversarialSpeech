% Targeted Adversarial Sample Comparision.
clc;
clear all;
targetedCsvFile = '/home/hxie1/Projects/DeepSpeech/data/gpuAdv20181112Sum.csv'; 
originalWavDir = '/home/hxie1/Projects/DeepSpeech/data/originalWave';   
targetedAdvWavDir = '/home/hxie1/Projects/DeepSpeech/data/targetedAdvWave'; 
reconstrWavDir = '/home/hxie1/Projects/DeepSpeech/data/reconstrWave';
dataDir = '/home/hxie1/Projects/DeepSpeech/data';

% read csv file
%  ['Text#, Origin_Text_Wave, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text, \n\r']
%   Var1       Var2                  Var3             Var4             Var5
targetedCsv = table2cell(readtable(targetedCsvFile));
[N,colW] = size(targetedCsv);

% generated file head
c = clock;
timeStr = sprintf('%4d%02d%02d-%02d%02d',c(1),c(2),c(3),c(4),c(5));
targetedAdvStatis = strcat(dataDir,'/targetAdvStatis', timeStr, '.csv');
fileID = fopen(targetedAdvStatis, 'w');
% print csv file table header
fprintf(fileID, ['Text#, Origin_Text, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text,  Corr_O_A, Corr_O_R, Corr_A_R, \n\r']);

for i= 1: N
% read original T1 wave file;
   if (i ~= targetedCsv{i,1})
       fprintf('the %d line in csv file has incorrect text# \n', i);
       return;
   end
   originalWavFile = sprintf('%s/T%d.wav',originalWavDir, i);
   advWavFile = sprintf('%s/T%d-Ad.wav',targetedAdvWavDir, i);
   
   % generate 
   advText = targetedCsv{i, 5};
   reconstWavFile = sprintf('%s/T%d-Ad-Recon.wav',reconstrWavDir, i);
   [s, cmdoutT2S] = system(sprintf('pico2wave --wave=%s  "%s"',  reconstWavFile, advText)); % natural voice
   if 0 ~= s
       disp(cmdoutT2S);
       fprintf("text 2 speech error at output %s, with the %dth text\n", reconstWavFile, i);
       break;
   end
   
   % ['Text#, Origin_Text, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text,  Corr_O_A, Corr_O_R, Corr_A_R, \n\r']
   fprintf(fileID, ['%d, %s, %s, %s, %s, %9.6f, %5.2f, %5.2f, \n\r'], i, targetedCsv{i,2}, targetedCsv{i,3}, targetedCsv{i,4}, targetedCsv{i,5},...
                     correlation(originalWavFile, advWavFile), correlation(originalWavFile, reconstWavFile), correlation(advWavFile, reconstWavFile));

end

% close file
fclose(fileID);

disp('============End of Generating Correlaltion Coefficient Statistic File ============');
