function [status, filename] = streams_existfile(filenamein, pathname)

% the assumed path where the files will be looked for is:
if nargin<2
  pathname = '/project/3011044.02/preproc/meg';
end
filename = fullfile(pathname,filenamein);
status   = exist(filename,'file');

if ~status,
  d = dir(pathname);
  for k = 1:numel(d)
    if d(k).isdir
      filename = fullfile(pathname,d(k).name,filenamein);
      status   = exist(filename,'file');
      if status,
        return;
      end
    end
  end
end