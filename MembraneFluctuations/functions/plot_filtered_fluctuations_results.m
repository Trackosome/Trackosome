function plot_filtered_fluctuations_results(fluctuations_um, dist_memb_points_um, fft_curve, freqs, all_fluct_axes,fourier_axes)

cla(all_fluct_axes)
cla(fourier_axes)
plot_all_fluctuations(fluctuations_um, dist_memb_points_um, all_fluct_axes);
plot(fourier_axes, freqs, fft_curve, 'linewidth', 1.5)
xlabel(fourier_axes, '1/\mum')
colormap(all_fluct_axes, 'jet')
colormap(fourier_axes, 'jet')