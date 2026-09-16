classdef Gread < handle
    properties
        G
        V                
        n_prfl =  100
        p0
        p1
        iV
    end
    methods
        function obj = Gread(G,V)            
        if ndims(G) ~= 3
            error('G must be a 3D array.');
        end
        if size(G,3) ~= numel(V)
            error('Length of third dimension of G must match length of V.');
        end
        obj.G = G;
        obj.V = V;
        end
        function nx = nx(obj)
            nx = size(obj.G,1);
        end
        function ny = ny(obj)
            nx = size(obj.G,2);
        end
        function nz = nz(obj)
            nx = size(obj.G,3);
        end
        function set_line(obj,p0,p1)                        
        % validate  p0 and p1
        'set line in Gread'
        if ~(isnumeric(p0) && isnumeric(p1))
            error('p0 and p1 must be numeric.');
        end
        p0 = double(p0);
        p1 = double(p1);
        if numel(p0) ~= 2 || numel(p1) ~= 2
            error('p0 and p1 must be arrays with exactly 2 elements each.');
        end
        % normalize shapes to row vectors [x,y]
        p0 = reshape(p0(:).',1,2);
        p1 = reshape(p1(:).',1,2);
            obj.p0 = p0
            obj.p1 = p1
        end
        function set_V(obj,Vfcs)
        [minval,iV] = min(abs(obj.V - Vfcs))
        obj.iV = iV;  % Update the index property with the found index
        % compute 1st and 99th percentiles of the current gmap at the selected voltage
        vals = obj.G(:,:,iV);
        p1 = prctile(vals(:),1);
        p99 = prctile(vals(:),99);
        obj.clim_gmap = [p1 p99];
        end
        function foo = prfl(obj)
            foo = get_ldos_prfl(obj.G,obj.p0,obj.p1,obj.n_prfl);
        end
        function foo = gmap(obj)
            foo = obj.G(:,:,obj.iV);
        end
    end
end
function prfl = get_ldos_prfl(G,p0,p1,n)
%GET_LDOS_PRFL Extract an LDOS profile along a 2D line for each z-slice
%  prfl = GET_LDOS_PRFL(G,p0,p1,n)
%    G   : 3D array (rows = y, cols = x, pages = z)
%    p0  : [x0,y0] start in array indices (can be non-integer)
%    p1  : [x1,y1] end
%    n   : number of sample points along the line
%  prfl: n-by-size(G,3) matrix. row i is profile along z at position i.

% input checks
if nargin < 4, error('Usage: get_ldos_prfl(G,p0,p1,n)'); end
assert(ndims(G)==3, 'G must be a 3D array');
p0 = double(p0(:).'); p1 = double(p1(:).');
assert(numel(p0)==2 && numel(p1)==2, 'p0 and p1 must be [x,y]');

% line sample positions (x,y) in array coordinates (cols, rows)
xi = linspace(p0(1), p1(1), n).';
yi = linspace(p0(2), p1(2), n).';

[rows, cols, nz] = size(G);
prfl = nan(n, nz);

% use interp2 on each z-slice; grid is X=1:cols, Y=1:rows
X = 1:cols; Y = 1:rows;
for k = 1:nz
    V = G(:,:,k);
    % interp2 expects XI,YI of same size; provide vectors of same length
    prfl(:,k) = interp2(X, Y, V, xi, yi, 'linear', NaN);
end
end