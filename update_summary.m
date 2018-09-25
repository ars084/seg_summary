function out = update_summary
close all
%Loads a waiting bar
f = waitbar(0,'0%','Name','Extracting info');
setappdata(f,'canceling',0);

%LVAD_CT_STATISTICS
%This code creates a cell that will output various statistics within 
%the wip and annotations folder for lvad, and stores the data in an 
%excel file called 'update.xlsx'

%need to be logged into VPN and mounted to McVeighLab to work

results = cell(10,1000); %preallocate empty cell
j_tot = 298; %last num total patients
ogfolder = cd; %will return home w/ this
base_folder = '/Volumes/McVeighLab/'; 
path{1} = 'annotations/datasets/ucsd_bivent';
path{2} = 'annotations/datasets/ucsd_ccta';
path{3} = 'annotations/datasets/ucsd_lvad';
path{4} = 'annotations/datasets/ucsd_pv';
path{5} = 'annotations/datasets/ucsd_siemens';
path{6} = 'annotations/datasets/ucsd_tavr_1';
path{7} = 'annotations/datasets/ucsd_toshiba';
path{8} = 'wip/nih_normals';
path{9} = 'wip/nih_tof';
path{10} = 'wip/ucsd_AN';
path{11} = 'wip/ucsd_bivent';
path{12} = 'wip/ucsd_ccta';
path{13} = 'wip/ucsd_chd';
path{14} = 'wip/ucsd_lvad';
path{15} = 'wip/ucsd_normals';
path{16} = 'wip/ucsd_pv';
path{17} = 'wip/ucsd_siemens';
path{18} = 'wip/ucsd_tavr';
path{19} = 'wip/ucsd_tavr_1';
path{20} = 'wip/ucsd_tendyne';
path{21} = 'wip/ucsd_tof';
path{22} = 'wip/ucsd_toshiba';
location{1} = 'annotations bivent';
location{2} = 'annotations ccta';
location{3} = 'annotations lvad';
location{4} = 'annotations pv';
location{5} = 'annotations siemens';
location{6} = 'annotations tavr 1';
location{7} = 'annotations toshiba';
location{8} = 'wip nih normals';
location{9} = 'wip nih tof';
location{10} = 'wip AN';
location{11} = 'wip bivent';
location{12} = 'wip ccta';
location{13} = 'wip chd';
location{14} = 'wip lvad';
location{15} = 'wip normals';
location{16} = 'wip pv';
location{17} = 'wip siemens';
location{18} = 'wip tavr';
location{19} = 'wip tavr_1';
location{20} = 'wip tendyne';
location{21} = 'wip tof';
location{22} = 'wip toshiba';
j = 1; %count for num of cvc files

for k = 1:length(path) %through each path
    cd([base_folder,path{k}]) %go to path
    d = dir(); %get what's in the folder
    n = length(d);    
    d_cell = struct2cell(d);
    for i = 1:n %for every patient file in on the path
        if contains(d(i).name(1),'.') == 0 && d(i).isdir == 1 
            cd([base_folder, path{k}, '/', d_cell{1,i}])
            if exist('img-nii','file')>0
                results{2,j} = d_cell(1,i); %gives the name of the file
                cd('./img-nii'); %opens cvc folder
                frames = dir();
                z = 1;
            
 % this while loop removes the files ., .., and .DS_Store
 % which can throw off the count of segmentation and frames 
 
                while z < 2
                    if contains(frames(z).name(1),'.') == 1
                    	frames(z) = [];
                    else
                        z = 2;
                    end
                end
            
                frames = length(frames);
                results{3,j} = frames; %number of frames
                cd('..') 
            
 % this checks to see if the file has been segmented
                esc = 1;
                if exist('seg-nii','file') > 0 
                    cd('./seg-nii')
                    segs = dir();
                    q = 1;
                    esc = 0;
                    while q < 2 
                        if isempty(segs) == 1
                            esc = 1;
                            q = 2;
                        elseif contains(segs(q).name(1),'.') == 1
                            segs(q) = [];
                        else
                            q = 2;
                        end
                    end
                end
                if esc < 1
                    segs = struct2cell(segs);
                    results{4,j} = length(segs); %num of segmented frames
                    results{5,j} = segs{3,end}; %date last edited
                    %Check to see what labels are in segmentation
                    labels = unique(niftiread(segs{1})); %Bottleneck
                    %array with values b/w 0 and 13, refer to labels.txt
                    %to find out what these labels refer to

                    cd('../')
                    results{6,j} = (exist('screenshots','dir')>0); %screenshots or not

                    if results{6,j} == 1
                        cd('./screenshots')
                        out = struct2cell(dir);
                        results{7,j} = out{3,end};%date of screenshots
                        cd('../')
                    else
                        results{7,j} = 'NA'; %no screenshots
                    end

                    if ismember(1,labels) == 1 %contains LV seg
                        results{8,j} = 'TRUE';
                    else
                        results{8,j} = 'FALSE';
                    end

                    if ismember(10, labels) == 1 %contains RV seg
                        results{9,j} = 'TRUE';
                    else
                        results{9,j} = 'FALSE';
                    end
                    
                    if contains(results{8,j},'TRUE') == 1 && ...
                            contains(results{9,j},'TRUE')==1
                        results{10,j} = 'TRUE';
                        results{8,j} = 'FALSE';
                        results{9,j} = 'FALSE';
                    else
                        results{10,j} = 'FALSE';
                    end

                else %contains no segmentation, only images
                    results{4,j} = 0;
                    results{5,j} = 'NA';
                    results{6,j} = 'NA';
                    results{7,j} = 'NA';
                    results{8,j} = 'FALSE';
                    results{9,j} = 'FALSE';
                    results{10,j} = 'FALSE';
                end

                results{1,j} = location{k}; %location of file
                j = j + 1;   
                cd('..')
            end
        end
        waitbar(j/j_tot,f,[num2str(round(100*j/j_tot,2)),...
            '% complete @',location{k}])
    end
end
results = results';
title = {'Location','Patient_Num','Img_frames','Seg_frames',...
    'Date_Seg','gifs','Date_gif','LV_Seg','RV_Seg','Both_Seg'};
cd(ogfolder)
delete(f)
qpq = cell2table(results(1:j,:));
qpq.Properties.VariableNames = title;
csv_title = ['Segs_updated_',date,'.csv'];
writetable(qpq,csv_title)
out = qpq;
end
