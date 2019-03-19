clear

addpath(genpath('/m/nbe/scratch/narmor/scripts'))

res='2mm';
ridgeParam=1e6;

subs={
'narr_subj_09'
'narr_subj_11'
'narr_subj_12'
'narr_subj_13'
'narr_subj_14'
'narr_subj_15'
'narr_subj_16'
'narr_subj_17'
'narr_subj_18'
'narr_subj_20'
'narr_subj_21'
'narr_subj_22'
'narr_subj_23'
'narr_subj_24'
'narr_subj_25'
'narr_subj_26'
'narr_subj_27'
'narr_subj_28'
'narr_subj_29'
'narr_subj_30'
'narr_subj_31'
'narr_subj_32'
'narr_subj_33'
'narr_subj_34'
'narr_subj_35'
'narr_subj_36'
'narr_subj_37'
'narr_subj_38'
'narr_subj_39'
};
%%
% load the language model
load('w2vCompShifted2TRsEmptyRowsFilledWithPrevious')

mask=load_nii(['/m/nbe/scratch/narmor/masks/mask_' res '.nii']);
inmask=find(mask.img);
nvox=length(inmask);
nsub=length(subs);
for s=1:nsub
    disp(['subject ' num2str(s)])
	
    nii=load_nii(['/m/nbe/scratch/narmor/fMRI_data/' subs{s} '/compA/epi_preprocessed_cut_' res '.nii']);
    nii=permute(nii.img,[4 1 2 3]);
    nii=nii(:,inmask);
	betas=zeros(length(inmask),size(w2v,2));
    corrs=zeros(length(inmask),1);
    for voxi=1:nvox
        % display progress every 1000 voxels
        if (mod(voxi,1000)==0)
            disp([num2str(voxi) '/' num2str(nvox)])
        end
        tc=zscore(squeeze(nii(:,voxi))); % voxel timecourse
        betas(voxi,:)=ridge(tc,zscore(w2v),ridgeParam); % betas from ridge regression
        tc_w2v=w2v*betas(voxi,:)'; % dot product between the betas and the w2v model to obtain w2v timecourse
        corrs(voxi)=corr(tc_w2v,tc); % pearson's correlation between the voxel and w2v timecourses
    end
    betas(find(isnan(betas)))=0;
    corrs(find(isnan(corrs)))=0;
    
    save(['/m/nbe/scratch/narmor/ridge_results/betas_' subs{s} '_' res '_ridgeParam' num2str(ridgeParam)], 'betas')
    
    newbrain=zeros(size(mask.img,1),size(mask.img,2),size(mask.img,3));
    newbrain(inmask)=detrend(corrs);
    filename=['/m/nbe/scratch/narmor/ridge_results/corrs_' subs{s} '_' res '_ridgeParam' num2str(ridgeParam) '.nii'];
    save_nii(make_nii(newbrain),filename);
    nii=fixOriginator(filename,mask);
    save_nii(nii,filename);
end

