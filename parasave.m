function parasave(savename,Object)
save(savename,varname(Object));
fprintf('%s %s saved.\n',varname(Object),savename);
end