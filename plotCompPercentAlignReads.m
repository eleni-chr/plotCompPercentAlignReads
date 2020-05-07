function plotCompPercentAlignReads
%% Function written by Eleni Christoforidou in MATLAB R2019b

%This function creates a plot comparing the percentage of reads that
%aligned at least once by two different aligners.

%The functions "qname_analysis" and "countqnames" must be ran beforehand to
%generate the variables used in the current function.

%Run this function from one directory above the folder containing the 
%subfolders with the MAT files generated by the above functions.

%IMPORTANT: This function creates a plot for 6 samples. A lot of things are
%hardcoded so this code will need to be modified for use with new samples.

%INPUT ARGUMENTS: None.

%OUTPUT ARGUMENTS: None, but the plot is saved in 2 different formats in
%the working directory.

%% Obtain data.

%Find MAT files to work with.
F=dir('*Data analysis*'); %get names of folders containing the subfolders with the MAT files.
masterdir=cd; %save master directory.

%Initialise variables.
high_quality=zeros(6,2);
aligned=zeros(6,2); %number of reads that aligned at least once by each aligner.

for ii=1:2 %loop through each master folder.
    cd(strcat(pwd,'\',F(ii).name)); %navigate to a master folder containing subfolders.

    D=dir('*/qname_analysis.mat'); %get list of MAT files in subfolders.
    d=length(D); %number of MAT files found.
    wd=cd; %save working directory.
    
    for f=1:d %loop through each MAT file.
        fprintf('Working on aligner %d of 2: file %d of %d\n',ii,f,d); %inform user of progress
        cd(D(f).folder); %navigate to subfolder containing MAT file.
        load('qname_analysis.mat','unique_qnames','unique_mapped') %load the data into the workspace.
        high_quality(f,ii)=length(unique_qnames); %this is the number of reads that were used for the alignment by each aligner.
        aligned(f,ii)=length(unique_mapped); %this is the number of reads that aligned at least once by each aligner.
        clear unique_qnames unique_mapped
        cd(wd); %return to working directory for next iteration of for-loop.
    end
    cd(masterdir); %return to master directory for next iteration of for-loop.
end

%Calculate percentages.
percentAligned=round(aligned./high_quality.*100); %convert number of aligned reads to percentage of reads that aligned.

%% Create plot.

fig=figure('Position', get(0, 'Screensize')); %make figure full-screen.
categories={'Wildtype 1','Wildtype 2','Wildtype 3','Mutant 1','Mutant 2','Mutant 3'}; %x-axis categories.
x=categorical(categories); %convert x to categorical data for plotting.
x=reordercats(x,{'Wildtype 1','Wildtype 2','Wildtype 3','Mutant 1','Mutant 2','Mutant 3'}); %re-order categories because previous line sorts them in alphabetical order.
b=bar(x,percentAligned); %plot bar chart.
ylabel('Percentage of reads that aligned','FontSize',14); %add y-axis label.
legend({'minimap2','Guppy'},'FontSize',14); %add chart legend.
set(gca,'box','off'); %remove top x-axis and right y-axis.
set(gca,'TickLength',[0 0]); %remove axes ticks.
ylim([0 100]);
set(gca,'FontSize',14);

%Display values on top of bars.
for a=1:2
    xtips=b(a).XEndPoints;
    ytips=b(a).YEndPoints;
    labels=strcat(string(b(a).YData),'%');
    text(xtips,ytips,labels,'HorizontalAlignment','center','VerticalAlignment','cap','FontSize',12);
end

%Save figure.
savefig(fig,'CompNumAlignReads'); %save figure as a FIG file in the working directory.
fig.Renderer='painters'; %force MATLAB to render the image as a vector.
saveas(fig,'CompNumAlignReads.svg'); %save figure as an SVG file.
close
clear
end