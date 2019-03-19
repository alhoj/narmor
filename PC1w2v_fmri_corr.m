clear

addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI/')
addpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila/')

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
load('w2vCompShifted2TRsEmptyRowsFilledWithPrevious')
% PCA on the word2vec model
[~,PCTC] = pca(w2v);
% take the first PC
firstPC=PCTC(:,1);

res='2mm';
mask=load_nii(['/m/nbe/scratch/narmor/masks/mask_' res '.nii']);
inmask=find(mask.img);

for s=1:length(subs)
    disp(s)
    if isequal(res,'2mm')
        nii=load_nii(['/m/nbe/scratch/narmor/fMRI_data/' subs{s} '/compA/epi_preprocessed_cut.nii']);
    else
        nii=load_nii(['/m/nbe/scratch/narmor/fMRI_data/' subs{s} '/compA/epi_preprocessed_cut_' res '.nii']);
    end
    nii=permute(nii.img,[4 1 2 3]);
    r=corr(firstPC,zscore(nii(:,inmask)));
    newbrain=zeros(size(mask.img,1),size(mask.img,2),size(mask.img,3));
    newbrain(inmask)=r;
    filename=['/m/nbe/scratch/narmor/pca_results/' subs{s} '_' res '.nii'];
    save_nii(make_nii(newbrain),filename);
    nii=fixOriginator(filename,mask);
    save_nii(nii,filename);
end