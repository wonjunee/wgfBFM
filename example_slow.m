%% Example of the Back-And-Forth method
% 
% For more explanation see also the documentation here:
% https://wasserstein-gradient-flows.netlify.app/
% 


% Parameters
n = 512;             % The size of the n x n grid
maxIters = 200;      % Maximum number of BFM iterations
TOL = 1e-2;          % Tolerance for BFM
nt  = 60;            % Number of outer iterations
tau = 0.005;         % Time step in the JKO scheme
m   = 2;             % m in the internal energy
gamma = 0.05;        % gamma in the internal energy
folder = 'data';     % Output directory
verbose  = 1;        % pPrint out logs


[x,y] = meshgrid(linspace(0,1,n));

% Initial density
rhoInitial = zeros(n);
idx = (x-0.5).^2 + (y-0.5).^2 < 0.1^2;
rhoInitial(idx) = 1;
rhoInitial = rhoInitial / sum(rhoInitial(:)) * n^2;

% Potential
V = sin(3*pi*x) .* sin(3*pi*y);

% No obstacle
obstacle = zeros(n);

% Plots
subplot(1,2,1)
contourf(x, y, rhoInitial)
title('Initial density')
axis square

subplot(1,2,2)
contourf(x, y, V);
title('Potential V')
axis square


%% Run BFM!
rhoFinal = wgfslow(rhoInitial, V, obstacle, m, gamma, maxIters, TOL, nt, tau, folder, verbose);


%% Make movie
fig = figure;
movieName = 'movie.gif';

for i = 0:nt
    file = fopen(sprintf("%s/rho-%04d.dat", folder, i), 'r');
    rho = fread(file, [n n], 'double');
    imagesc(rho)
    axis xy square
    set(gca,'XTickLabel',[], 'YTickLabel',[])

    frame = getframe(fig);
    im = frame2im(frame);
    [X,cmap] = rgb2ind(im, 256);

    % Write to the GIF file
    if i == 0
        imwrite(X, cmap, movieName, 'gif', 'Loopcount',inf, 'DelayTime',0.03);
    else
        imwrite(X, cmap, movieName, 'gif', 'WriteMode','append', 'DelayTime',0.03);
    end
end