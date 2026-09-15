addpath ..\..\..\..\RawData\1T-TaS2(DWN)\
load('LinearDWN(0_0_1).mat')
if exist('TTDWmap.mat','file')
    load('TTDWmap.mat')
end
load('quickTTDWmap.mat')
load('DWsampling(1_0_0).mat')