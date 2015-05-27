function plot(AnalysisObj)
%Plotting Analysis objects depending on biomarker classes
disp('break')
%First we sort into the different classes:
% QBiomarkers
QBidx = nbt_searchvector(AnalysisObj.data{1}.classes,{'nbt_QBiomarker'});


% SignalBiomarkers
SBidx = nbt_searchvector(AnalysisObj.data{1}.classes,{'nbt_SignalBiomarker'});



end
