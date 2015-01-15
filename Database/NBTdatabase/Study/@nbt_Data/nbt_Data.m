classdef nbt_Data
    %nbt_Data contains collections of biomarker data and is mainly produced
    %by the getData method of the nbt_Group object
    
    properties
        dataStore %cell or function handle
        subjectList
        pool
        poolKey  
        biomarkers
        biomarkerIdentifiers
        subBiomarkers
        classes
        %Further parameters..
        outputFormat %output format - remove nans, etc. cell vs matrix vs struct
    end 
    
    methods
      function DataObject = nbt_Data  
      end
      
      
      function listOfSubjects = getSubjectList(DataObj, BiomarkerIndex) 
         listOfSubjects = DataObj.subjectList{BiomarkerIndex,1};
      end
        
       Biomarker = getBiomarker(nbt_DataObject, Parameters, OutputFormat);   
       
       function B = subsref(A,S)
           if(strcmp(S(1).type,'.'))
               B = eval(['A' S.type S.subs]);    
           elseif(strcmp(S(1).type,'{}'))
               B = A.dataStore{S.subs{1,1},S.subs{1,2}};
               if(iscell(B))
                   tmp = B{1,1}(:);
                   tmp = [tmp , nan(size(tmp,1),length(B)-1)];
                   for sID = 2:length(B)
                       tmp(:,sID) =  B{sID,1}(:);
                   end
                   B = tmp;
               end
           elseif(strcmp(S(1).type,'()')) %this will return a large matrix [biomarkerIDs,ChannelIDs]
               %calling with () gives the full matrix with subjects x
               %channels
               %calling with (1,2) gives biomarker 1 , channel 2 - in
               %subject x channel format
               
               if(isempty(S.subs))
                  S.subs{1,1} = 1:size(A.dataStore,1);
                  S.subs{1,2} = 1:size(A.dataStore{1,1}{1,1},1);
               end
               B = [];
               numSubjects = size(A.dataStore{1,1},1);
                    %returning all biomarkers in Subject x Biomarker format
               
                   for bID = S.subs{1,1} %looping over biomarkers
                       tmp = nan(numSubjects,size(S.subs{1,2},2));
                       for sID = 1:numSubjects %looping over subjects
                            tmp(sID,:) = A.dataStore{bID,1}{sID,1}(S.subs{1,2},1)'; 
                       end
                       B = [B tmp];
                       clear tmp
                   end
               
           end
           
       end 
       
       
    end
    
    methods (Static = true)
     DataObject = dataContainer(GrpObj);
    end
    
     methods (Hidden = true)
       DataObj = outputFormating(DataObj) %called by GetData before returning Data 
    end
    
end

