%% make jobs for slurm

clear
delete logs/*
delete jobs/*

cfg=[];
cfg.ind=1;
cfg.res='2mm';
cfg.regParam=0.0001;
% cfg.func='cancor_voxelwise_CV_slurm.py';
cfg.func='cancor_slurm.py';

% slurm parameters
cfg.partition='batch';
cfg.mem='250000';
cfg.time='30:00:00';

nsub=29;
cfg.count=0;
for subi=1:nsub
    cfg.count=cfg.count+1;
    cfg.subi=subi;
    function_make_scripts_slurm(cfg)
    cfg.ind=cfg.ind+1;
end

%% run the jobs

system('source slurm_run_jobs_auto.sh')
