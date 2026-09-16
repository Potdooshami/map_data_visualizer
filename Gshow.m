classdef Gshow < Gread
    properties
        clim_gmap = [] 
        clim_prfl = []
    end
    methods        
        function show_map(obj)
            gmap = obj.gmap();
            if isempty(obj.clim_gmap)
                obj.clim_gmap = get_p199(gmap);                
            end
            imagesc(gmap)
            colormap(jet)                     
            axis image                        
            axis xy                           
            colorbar
            xlabel('x'); ylabel('y');            
            caxis(obj.clim_gmap);
            colorbar
        end
        function add_map_line(obj)
            hold on
            
            hold off

        end
        function show_map_hist(obj)
            h = histogram(obj.gmap());
            view([90 -90]);
            set(gca,'YAxisLocation','right');
            xlabel('Count'); ylabel('Value');            
            vals = obj.gmap();
            mx = max(vals(:));
            mn = min(vals(:));
            mu = mean(vals(:));
            med = median(vals(:));
            sigma = std(vals(:));
            p1 = prctile(vals(:),1);
            p99 = prctile(vals(:),99);
            
            yl = ylim;
            hold on
            % vertical lines
            h1 = plot([mx mx], yl, 'r-', 'LineWidth',1.5);
            h2 = plot([mn mn], yl, 'g-', 'LineWidth',1.5);
            h3 = plot([mu mu], yl, 'b--', 'LineWidth',1.5);
            h4 = plot([med med], yl, 'k--', 'LineWidth',1.5);
            h5 = plot([mu-sigma mu-sigma], yl, 'c:', 'LineWidth',1.5);
            h6 = plot([mu+sigma mu+sigma], yl, 'c:', 'LineWidth',1.5);
            h7 = plot([p1 p1], yl, 'm-.', 'LineWidth',1.5);
            h8 = plot([p99 p99], yl, 'm-.', 'LineWidth',1.5);
            hold off
            legend([h1 h2 h3 h4 h5 h7 h8],...
                {sprintf('max=%.3g',mx), sprintf('min=%.3g',mn), sprintf('mean=%.3g',mu), ...
                 sprintf('median=%.3g',med), sprintf('mean\\pm1\\sigma=%.3g',sigma), ...
                 sprintf('1%%=%.3g',p1), sprintf('99%%=%.3g',p99)}, 'Location','best');
        end
        function show_dos(obj)
        g = squeeze(mean(mean(obj.G)))
        plot(obj.V,g)
        xlabel('V (V)')
        ylabel('LDOS (au)')
        xline(0,':','Fermi level')
        Vfcs = obj.V(obj.iV)
        xline(Vfcs,'-','V='+string(Vfcs))            
        yline(obj.clim_gmap(1))
        yline(obj.clim_gmap(2))
        end
        function show_prfl(obj)
        prfl = obj.prfl();
        if isempty(obj.clim_prfl)
            obj.clim_prfl = get_p199(prfl);                
        end
        obj.n_prfl = 200;       
        imagesc(obj.V, 1:size(prfl,1), prfl)
        set(gca,'YDir','normal')
        xlabel('V (V)')
        colormap('jet')        
        yticks([])
        end
        function show_all(obj)
            % Use existing show_* methods to build combined figure
        fig = figure('Units','inches', 'Position',[1 1 3.4 2.55], 'Resize','off');
        set(fig, 'PaperUnits','inches', 'PaperPosition',[0 0 3.4 2.55], 'PaperPositionMode','manual');

        t = tiledlayout(3,3,'TileSpacing','compact','Padding','compact');

        % map (rows1-2, cols1-2)
        ax_map = nexttile(t, [2 2]);
        % call show_map but direct its drawing to ax_map
        axes(ax_map); cla(ax_map);
        obj.show_map();

        % dos (rows1-2, col3)
        ax_prfl = nexttile(t, [2 1]);
        axes(ax_prfl); cla(ax_prfl);
        obj.show_prfl();
        % 
        % fill row3 cols1-2 with empty axes to preserve layout
        for col = 1:2
            nexttile(t, [1 1]);
            axis off
        end

        % prfl (3,3)
        ax_dos = nexttile(t, [1 1]);
        axes(ax_dos); cla(ax_dos);
        obj.show_dos();
        end
    end       
end
function p199 = get_p199(vals)
p199 = [prctile(vals(:), 1), prctile(vals(:), 99)];
end