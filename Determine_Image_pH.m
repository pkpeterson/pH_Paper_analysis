%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to calculate pH indicated by pH paper quanitatively from
% photographs using the difference between the green and blue channel
% 
% Will prompt user for three inputs, first the file path, than the imcrop
% tool will pop up requesting an outline of the pH scale, than the imcrop
% tool will pop up again, requesting an outline of the area to be analysed.
% Output is two plots, one a pH_calibration*.pdf that shows the calculated
% calibration curve, the other shows an image of the cropped sample and the pH
% scale with the calculated pH displayed above the sample. Script at this
% moment is pretty dumb, will overwite images if there are more than 1
% sample per image. This could potentially be fixed.
%
% Dependencies: correlationplot.m, peakfinder.m, export_fig.m
% Code by Peter Peterson pkpeter@umich.edu
% Original version 1 August 2016
% Update Oct 2017 pkp, include uncertainty, remove outliers from calibration curve
% calculation, flip calibration plot so signal is on y axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Close all figure windows
close all
clear transects I pH_scale_image sample_image

% Select image for analysis and import to matlab
[filename, pathname]=uigetfile('*.JPG','Select Image');
I=imread(fullfile(pathname,filename));

% Select pH scale
pH_scale_image=imcrop(I);
%pH_image_a=imcrop(I);
%pH_image_b=imcrop(I);
% Scale points as indicated on box
pH=[0,.5,1,1.3,1.6,1.9,2.2,2.5]';
%pH=[0,.5,1,1.5,2,2.5]';
%pH=[0,.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6]';
%pH=[2.5,3,3.3,3.6,3.9,4.2,4.5]';

% Select Sample Image
sample_image=imcrop(I);

% stich two scales together
%[x1,~,~]=size(pH_image_a);
%[x2,~,~]=size(pH_image_b);
% if x1>x2
%     pH_scale_image=cat(2,pH_image_a(1:x2,:,:),pH_image_b);
% else
%     pH_scale_image=cat(2,pH_image_a,pH_image_b(1:x1,:,:));
% end
% Separate scale image into red,green,blue channels, 
for i=1:3
    transect=pH_scale_image(:,:,i);
    transects(:,i)=mean(double(transect),1);
end

% Calculate peak positions of blue and green channels
[~, green_mag]=peakfinder(transects(:,2),[],[],-1);
[~, blue_mag]=peakfinder(transects(:,3),[],[],-1);
while length(blue_mag)>length(pH)
    [~,index] = max(blue_mag);
    blue_mag(index)=[];
end

while length(green_mag)>length(pH)
    [~,index] = max(green_mag);
    green_mag(index)=[];
end

% Calculate calibration curve
[p,S]=polyfit(green_mag-blue_mag,pH.^2,1);

%calculate outliers
y_calc=(polyval(p,(green_mag-blue_mag))).^.5;
resid=abs(pH-y_calc).^2;
outlier_color=green_mag(resid>1)-blue_mag(resid>1);
outlier_pH=pH(resid>1);
green_mag(resid>1)=[];
blue_mag(resid>1)=[];
pH(resid>1)=[];

% Update calibration to discard outliers
[p,S]=polyfit(green_mag-blue_mag,pH.^2,1);
% calculate and print cal curve
correlationplot(pH.^2,green_mag-blue_mag)
% print outliers
if isempty(outlier_pH)==0
    hold on
    plot(outlier_pH.^2,outlier_color,'xr','LineWidth',3)
end
ylabel('Average Green-Blue')
xlabel('pH^2')

%prep for export
set(gca,'FontSize',16)
set(gcf,'paperunits','inches')
set(gcf,'papersize',[10,10]) % Desired papersize
set(gcf,'paperposition',[0,0,10,10]) % Place plot on figure
set(gcf, 'Color', 'w');
% remove extension from file name
name_noext=strsplit(filename,'.');
name_noext=name_noext(1);
cal_name=strcat('pH_Calibration_',name_noext);
export_fig(cal_name{1},'-pdf')

% calculate sample pH
sample_green=sample_image(:,:,2);
mean_green=mean(sample_green(:));
green_err=std(double(sample_green(:)))/(length(sample_green(:))^.5);

sample_blue=sample_image(:,:,3);
mean_blue=mean(sample_blue(:));
blue_err=std(double(sample_blue(:)))/(length(sample_blue(:))^.5);

diff_err=green_err+blue_err;
[sample_pH,err_pH]=polyval(p,mean_green-mean_blue,S);
% set negative values to 0
sample_pH(sample_pH<0)=0;
sample_pH=sample_pH^.5;

% plot pH scale and area of image selected for analysis
figure
y_pix=800;
x_pix=2*y_pix;
set(gcf, 'Position', [0, 0, x_pix, y_pix])

subplot(121)
imshow(pH_scale_image)
title({'pH Scale',num2str(pH')})
set(gca,'FontSize',16)
subplot(122)
imshow(sample_image)
ph_string=strcat('pH=',num2str(sample_pH,2),' \pm ',num2str(err_pH,1))
title(ph_string)

set(gca,'FontSize',16)
set(gcf,'paperunits','inches')
set(gcf,'papersize',[10,10]) % Desired papersize
set(gcf,'paperposition',[0,0,10,10]) % Place plot on figure
set(gcf, 'Color', 'w');
% remove extension from file name

image_name=strcat('pH_Result_',name_noext);

% save image
export_fig(image_name{1},'-png')

