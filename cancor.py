# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 14:07:37 2019

@author: jaalho
"""

# first run the following command in terminal:
# ml Python/3.5.1-goolf-triton-2016a

import numpy as np
import pandas as pd
import nibabel as nib
import rcca # Make sure that this is in the same folder
from scipy.stats import pearsonr, zscore

## read the word2vec data
w2v_file = '/m/nbe/scratch/narmor/w2v_comp_shifted2TRs_emptyRowsFilledWithPrevious.xlsx'
sheet=pd.read_excel(w2v_file,header=None)
w2v_data=sheet.as_matrix()
nsamples = w2v_data.shape[0]
ndims = w2v_data.shape[1]

## define subjects
subs = ['narr_subj_09', 'narr_subj_13', 'narr_subj_16', 'narr_subj_20', 'narr_subj_23', 'narr_subj_26', 'narr_subj_29', 'narr_subj_32', 'narr_subj_35', 'narr_subj_38',
'narr_subj_11', 'narr_subj_14', 'narr_subj_17', 'narr_subj_21', 'narr_subj_24', 'narr_subj_27', 'narr_subj_30', 'narr_subj_33', 'narr_subj_36', 'narr_subj_39',
'narr_subj_12', 'narr_subj_15', 'narr_subj_18', 'narr_subj_22', 'narr_subj_25', 'narr_subj_28', 'narr_subj_31', 'narr_subj_34', 'narr_subj_37']
nsubs=len(subs)
res = '16mm' # define resolution i.e. voxel size
reg_param = 0.001 # Regularization parameter

for subi, sub in enumerate(subs):
    print('Processing ' + sub + ' - ' + str(subi+1) + '/' + str(nsubs))
    ## read the fMRI data
    nii_mask = nib.load('/m/nbe/scratch/narmor/masks/mask_' + res + '.nii') # add mask
    mask = np.asarray(nii_mask.get_fdata())
    mask = np.reshape(mask, (mask.shape[0]*mask.shape[1]*mask.shape[2]),order="F")
    inmask = np.nonzero(mask) # indices of voxels within the mask
    nii_fmri = nib.load('/m/nbe/scratch/narmor/fMRI_data/' + sub + '/compA/epi_preprocessed_cut_' + res + '.nii')
    fmri_data = np.asarray(nii_fmri.get_fdata())
    fmri_data = np.reshape(fmri_data, (fmri_data.shape[0]*fmri_data.shape[1]*fmri_data.shape[2],nsamples),order="F").T
    fmri_data = np.squeeze(fmri_data[:,inmask])
    fmri_data = zscore(fmri_data)
    
    ## do CCA
    # Use 3/4 of samples (i.e. time points) as training data and rest for testing
    index = int(3.0/4*nsamples)
    # randomize samples
    samples = np.arange(nsamples)
    np.random.shuffle(samples)
    # Create CCA object; predefined regularization parameter
    cca = rcca.CCA(numCC=1, reg=reg_param, kernelcca=False, verbose=False)
    # Use cross-validation to find optimized regularization parameter
    #cca = rcca.CCACrossValidate(kernelcca = False, numCCs = [1], regs = [1e-4, 1e-3, 1e-2, 1e-1 1 1e1 1e2 1e3 1e4])
    # Train the model: this adds comps, ws and cancorrs to CCA object
    cca.train([w2v_data[samples[:index],:], fmri_data[samples[:index],:]])
    vox_ws=np.asarray(cca.ws[1])
    # save weights
    np.save('/m/nbe/scratch/narmor/cca_results/' + sub + '_' + res + '_weights_regParam' + str(reg_param), vox_ws)
    #cca.train([w2v_data[:index,:], fmri_data[:index,:]])
    # Transform test data to canonical space
#    w2v_test = np.dot(cca.ws[0].T, w2v_data[samples[index:], :].T).T
#    #fmri_test = np.dot(cca.ws[1].T, fmri_data[samples[index:], :].T).T 
#    nvox=fmri_data.shape[1]
#    nsamples_test = np.shape(samples[index:])[0]
#    fmri_test = np.zeros((nsamples_test,nvox))
#    corrs = np.zeros(nvox)
#    for voxi in range(nvox):
#        fmri_test[:,voxi] = np.dot(cca.ws[1][voxi][0].T, fmri_data[samples[index:], voxi].T).T
#        # Calculate correlation value for each voxel
#        [corrs[voxi],_] = pearsonr(w2v_test[:,0], fmri_test[:,voxi])
##    newbrain = np.zeros((nii_mask.shape[0],nii_mask.shape[1],nii_mask.shape[2]))
##    newbrain = np.reshape(newbrain, (newbrain.shape[0]*newbrain.shape[1]*newbrain.shape[2]),order="F").T
##    newbrain[inmask] = corrs
##    newbrain = np.reshape(newbrain,(nii_mask.shape[0],nii_mask.shape[1],nii_mask.shape[2]),order="F").T
##    newnii=nib.Nifti1Image(newbrain,nii_mask.affine,nii_mask.header)
##    nib.save(newnii, '/m/nbe/scratch/narmor/cca_results/' + sub + '_8mmvox_corrs.nii')
#    np.save('/m/nbe/scratch/narmor/cca_results/' + sub + '_' + res + 'vox_corrs_regParam' + str(reg_param),corrs)
    
    

