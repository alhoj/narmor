function function_make_scripts_slurm(cfg)

disp('Making jobs ...')

fid = fopen(['./jobs/job_' num2str(cfg.ind) '.sh'],'w');

fprintf(fid,'#!/bin/bash\n\n');

fprintf(fid,['#SBATCH --partition=' cfg.partition '\n']);
fprintf(fid,['#SBATCH --time=' cfg.time '\n']);
fprintf(fid,['#SBATCH --output=./logs/log_' num2str(cfg.ind) '\n']);
fprintf(fid,'#SBATCH --qos=normal\n');
fprintf(fid,['#SBATCH --mem=' cfg.mem '\n']);
fprintf(fid,'#SBATCH --constraint=[hsw|wsm]\n\n');

fprintf(fid,'cd /m/nbe/scratch/narmor/scripts\n\n');

fprintf(fid,'ml Python/3.5.1-goolf-triton-2016a\n\n');

fprintf(fid,['srun python ' cfg.func ' ' num2str(cfg.count) ' ' num2str(cfg.res) ' ' num2str(cfg.regParam)]); 

fclose(fid);

end
