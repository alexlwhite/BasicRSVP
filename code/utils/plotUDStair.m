function [] = plotUDStair(q,inlog,thresh)

hold on;

nts=length(q.response);

is=q.x(1:nts);
%thresh = PAL_AMUD_analyzeUD(q,'reversals',lastRevsToCount);

if inlog
    is=10.^is;
    thresh=10^thresh;
end

revTrls = find(q.reversal>0);
plot(revTrls,is(revTrls),'y.','MarkerSize',18);

plot(1:nts,is,'b-');

corrTrls = find(q.response(1:nts));
crH=plot(corrTrls, is(corrTrls), 'g.','MarkerSize',10);

incTrls = find(~q.response(1:nts));
inH=plot(incTrls, is(incTrls), 'r.','MarkerSize',10);

plot([0 nts],[thresh thresh],'r-');

%title('Staircase','FontSize',15);
xlabel('Trial');
ylabel('Intensity');

%legend([crH inH],'Correct','Incorrect','Location','NorthEast');

set(gca,'FontSize',12);