function nbt_combinePlanar(startpath)

%nbt_fileLooper(startpath,'.mat','analysis',@innerLoop,0)
nbt_fileLooper(startpath,'.mat','info',@innerLoop2,0)
end


function innerLoop(fileName)
load(fileName)

%define list of biomarkers

% for i=1:length(listBiomarkers)
%    [listBiomarkers{i} 'combined'] = combinePlanar() 
% end
try
PeakFitCombined = combinePlanar(PeakFitPlanar1Signal, PeakFit);
PeakFitCombined.signalName = 'CombinedSignal';

clear i
save(fileName)
catch
end



end

function innerLoop2(fileName)
load(fileName)

CombineSignalInfo = Planar1SignalInfo;
CombinedSignalInfo.signalName = 'CombinedSignal';

save(fileName,'CombineSignalInfo','-append')

end
