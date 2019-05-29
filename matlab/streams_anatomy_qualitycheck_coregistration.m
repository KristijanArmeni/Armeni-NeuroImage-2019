function streams_anatomy_qualitycheck_coregistration(subjectname)

rootdir = '/home/language/jansch/projects/streams/data/anatomy';
load(fullfile(rootdir,[subjectname,'_anatomy_shape']));
load(fullfile(rootdir,[subjectname,'_anatomy_shapemri']));


% quality check for the coregistration between headshape and mri
headshape    = ft_convert_units(shape,    'mm');
headshapemri = ft_convert_units(shapemri, 'mm');

v = headshapemri.pnt;
f = headshapemri.tri;
[f,v]=reducepatch(f,v, 0.2);
headshapemri.pnt = v;
headshapemri.tri = f;

h = figure;
subplot('position',[0.01 0.51 0.48 0.48]);hold on;
ft_plot_mesh(headshapemri,'edgecolor','none','facecolor',[0.5 0.6 0.8],'fidcolor','y','facealpha',0.3);
ft_plot_headshape(headshape,'vertexsize',5); view(180,-90);
plot3([-130 130],[0 0],[0 0],'k');plot3([0 0],[-120 120],[0 0],'k');plot3([0 0],[0 0],[-100 150],'k');
subplot('position',[0.51 0.51 0.48 0.48]);hold on;
ft_plot_mesh(headshapemri,'edgecolor','none','facecolor',[0.5 0.6 0.8],'fidcolor','y','facealpha',0.3);
ft_plot_headshape(headshape,'vertexsize',5); view(0,90);
plot3([-130 130],[0 0],[0 0],'k');plot3([0 0],[-120 120],[0 0],'k');plot3([0 0],[0 0],[-100 150],'k');
subplot('position',[0.01 0.01 0.48 0.48]);hold on;
ft_plot_mesh(headshapemri,'edgecolor','none','facecolor',[0.5 0.6 0.8],'fidcolor','y','facealpha',0.3);
ft_plot_headshape(headshape,'vertexsize',5); view(90,0);
plot3([-130 130],[0 0],[0 0],'k');plot3([0 0],[-120 120],[0 0],'k');plot3([0 0],[0 0],[-100 150],'k');
subplot('position',[0.51 0.01 0.48 0.48]);hold on;
ft_plot_mesh(headshapemri,'edgecolor','none','facecolor',[0.5 0.6 0.8],'fidcolor','y','facealpha',0.3);
ft_plot_headshape(headshape,'vertexsize',5); view(0,0);
plot3([-130 130],[0 0],[0 0],'k');plot3([0 0],[-120 120],[0 0],'k');plot3([0 0],[0 0],[-100 150],'k');
axis on;
grid on;
set(gcf,'color','w')

