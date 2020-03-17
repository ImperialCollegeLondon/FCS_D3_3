
RMapS = NaN(34,30,0);
for evi = 1:156
    A = load(['K:\DATA_FCS\RainEvent\Birm-34-30-Radar\EventNo',sprintf('%03d.mat',evi)],'RMap');
    RMapS = cat(3,RMapS,A.RMap);
end
load(['K:\DATA_FCS\RainEvent\Birm-34-30-Radar\EventNo',sprintf('%03d.mat',157)],'RMap','EE','NN');


%%
pcNum = 100;

preTrans = @(x)reshape(log(x+0.01),numel(x(:,:,1)),[]);% Box-Cox Transformation
XTrain = transpose(preTrans(RMapS));
% Preprocessing of PCA func:
% original ingredients data centered by subtracting the column means from corresponding columns.
[coeff,scoreTrain,latent,tsquared,explained,mu] = pca(XTrain,'NumComponents',pcNum);
U_pm = coeff(:,1:pcNum);% at least 95% variance is preserved
X_lp = XTrain-mu;% exp(transpose(preTrans(RMapS)))-0.01;
PREDRAIN_pca_lm = X_lp*U_pm;
Um = U_pm;
numP = pcNum;

X_lp = transpose(preTrans(RMap))-mu;% exp(transpose(preTrans(RMap)))-0.01;
PREDRAINval_pca_lm = X_lp*U_pm;

%%
pcNum0 = 200;
for imNo = (1:20:1000)
    obs = XTrain(imNo,:);
    a1 = exp(reshape(mu'+sum(U_pm(:,1:pcNum0).*PREDRAIN_pca_lm(imNo,1:pcNum0),2),34,30))-0.01;
    a1(a1 < 0.03) = NaN;
    a2 = exp(reshape(obs,34,30))-0.01;
    a2(a2 < 0.03) = NaN;
    if nanmax(a1(:))>5
        setFigureProperty('Subplot2');
        ha = tight_subplot(1,2,[.05 .05],[.05 .15],[.05 .05]);
        set(0,'defaultAxesFontSize',12);
        axes(ha(1))
        pcolor(EE,NN,a1);shading flat
        caxis([0 10])
        set(gca,'XTick',[],'YTick',[],'XTickLabel','','YTickLabel','');
        cptcmap('precip_meteoswiss', 'mapping','direct');%,'ncol',20);
        title('Constructed Rainfall');
        % axis off
        
        axes(ha(2))
        pcolor(EE,NN,a2);shading flat
        caxis([0 10])
        set(gca,'XTick',[],'YTick',[],'XTickLabel','','YTickLabel','');
        cptcmap('precip_meteoswiss', 'mapping','direct');%,'ncol',20);
        title('Radar Observation');
        % axis off
        % box on;
        savePath = 'C:\Users\Yuting Chen\Dropbox (Personal)\Data_PP\Fig_FCS\PCA_costruction';
        filename = [savePath,filesep,sprintf('%04d',imNo)];
        savePlot(filename,'XYWH',[50,50,250,130],'needreply','N','onlyPng',true);
        pause([0.15])
        close all
        
    end
end

%%
samL = PREDRAIN_pca_lm(1:10000:end,1:50)';
for li = 1:size(samL,2)
    % subplot(5,1,li)
    plot(samL(:,li)');hold on
    xlim([0,50]);
    ylim([-50,50])
    xlabel('Components No.')
    ylabel('Coef.')
    savePath = 'C:\Users\Yuting Chen\Dropbox (Personal)\Data_PP\Fig_FCS\PCA_costruction';
    filename = [savePath,filesep,sprintf('PCs_No%04d',li)];
    savePlot(filename,'XYWH',[50,-50,250,130],'needreply','N','onlyPng',true);
    pause([0.15])
end
%%
figure;
ha = tight_subplot(3,4,[.05 .05],[.05 .05],[.15 .05]);
pc = [1:10,50,100];
for pli = 1:numel(ha)
    axes(ha(pli));
    pcolor(EE,NN,reshape(U_pm(:,pc(pli)),size(RMap,[1,2])));
    shading flat
    % axis equal
    axis off
    cptcmap('flood_blue', 'mapping','scaled','flip',false,'ncol',20);
    caxis([-0.09 0.09])
    title(sprintf('U%d (%02d%%)',pc(pli),round(sum(explained(1:pc(pli))))));
end
c = colorbar('location','Manual', 'position', [0.1 0.1 0.02 0.8]);

preTrans = @(x)reshape(log(x+0.01),numel(x(:,:,1)),[]);% Box-Cox Transformation
X_lp = exp(transpose(preTrans(RMapS)))-0.01;
fea = X_lp*U_pm;


savePath = 'C:\Users\Yuting Chen\Dropbox (Personal)\Data_PP\Fig_FCS';
filename = [savePath,filesep,'PCA_Eigenvectors'];
savePlot(filename,'XYWH',[50,-50,500,300],'needreply','Y');




