function estimated_PDFs = KDE_support_relations
%KDE_SUPPORT_RELATIONS estimates the underlying probability density
%functions for support relations and surface descriptors. (more explanation
%in the example-based scene synthesis paper, Fisher et al.)

Consts_fisher;
load(support_relations_file, 'support_relations');

cat_count = length(support_relations);
estimated_PDFs = repmat(struct('estimated_PDF', []), cat_count, 1);

for rid = 1:length(support_relations)
    descriptors = support_relations(rid).descriptor;
    if isempty(descriptors)
        continue
    end
    
    sigma = std(descriptors);
    n_c = size(descriptors,1);
    bw = 1.06 .* sigma .* (1/nthroot(n_c,5));
%     [f_area,xi] = ksdensity(descriptors(:,1), 'bandwidth', bw(1));
    f_area = fitdist(descriptors(:,1), 'Kernel', 'BandWidth', bw(1));
    %debug
    x = min(descriptors(:,1)):.01:max(descriptors(:,1));
    y = pdf(f_area, x);
    plot(x,y);
    
%     [f_height,xi] = ksdensity(descriptors(:,2), 'bandwidth', bw(2));
    f_height = fitdist(descriptors(:,2), 'Kernel', 'BandWidth', bw(2));
    %debug
    x = min(descriptors(:,2)):.01:max(descriptors(:,2));
    y = pdf(f_height, x);
    plot(x,y);
    
    estimated_PDFs(rid).estimated_PDF = [f_area; f_height];
end

save(estimated_PDF_support_file, 'estimated_PDFs')

end

