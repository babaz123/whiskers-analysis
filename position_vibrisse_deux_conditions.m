function position_vibrisse_deux_conditions(table_condition1,table_condition2,postlesion_ION_condition1,postlesion_ION_condition2,cno_condition1,cno_condition2,phase_condition1,phase_condition2)

% 1. vérifier si lésion ION a affecté mouvement vibrisse.
% 2. vérifier si lésion ION a affecté effect inactivation CM

% dreadds rien pris ??? où mis adaptations???

% attention à données incluses pour DREADDS, parfois mauvaises.

%% Définition rangs essais

if postlesion_ION_condition1=='o'
    rang_condition1=find(cell2mat(table_condition1{{'postlesion_ION'},:})==1);
else
    rang_condition1=find(cell2mat(table_condition1{{'postlesion_ION'},:})==0);
end
if cno_condition1=='o'
    rang_condition1=intersect(rang_condition1,find(cell2mat(table_condition1{{'CNO'},:})==1));
else
    rang_condition1=intersect(rang_condition1,find(cell2mat(table_condition1{{'CNO'},:})==0));
end
if strfind(phase_condition1,'entrainement')
    rang_essais_condition1=intersect(rang_condition1,find(cell2mat(table_condition1{{'hold_time'},:})<1));
elseif strfind(phase_condition1,'performance')
    rang_essais_condition1=intersect(rang_condition1,find(cell2mat(table_condition1{{'hold_time'},:})>=1));
end
rang_interessais_condition1=intersect(rang_essais_condition1(1:end-1)+1,find(cell2mat(table_condition1{{'essai/interessai'},:})==0));


if postlesion_ION_condition2=='o'
    rang_condition2=find(cell2mat(table_condition2{{'postlesion_ION'},:})==1);
else
    rang_condition2=find(cell2mat(table_condition2{{'postlesion_ION'},:})==0);
end
if cno_condition2=='o'
    rang_condition2=intersect(rang_condition2,find(cell2mat(table_condition2{{'CNO'},:})==1));
else
    rang_condition2=intersect(rang_condition2,find(cell2mat(table_condition2{{'CNO'},:})==0));
end
if strfind(phase_condition2,'entrainement')
    rang_essais_condition2=intersect(rang_condition2,find(cell2mat(table_condition2{{'hold_time'},:})<1));
elseif strfind(phase_condition2,'performance')
    rang_essais_condition2=intersect(rang_condition2,find(cell2mat(table_condition2{{'hold_time'},:})>=1));
end
rang_interessais_condition2=intersect(rang_essais_condition2(1:end-1)+1,find(cell2mat(table_condition2{{'essai/interessai'},:})==0));


%% Calculs
% commencer variances essais (échoués, tentés et réussis) entre condition1
% et condition2

position_vibrisse_tous_essais_condition1=cell2mat(table_condition1{{'position_vibrisse'},rang_essais_condition1});
position_vibrisse_essais_reussis_condition1=cell2mat(table_condition1{{'position_vibrisse'},...
    intersect(rang_essais_condition1,find(cell2mat(table_condition1{{'reussite'},:})==1))});
position_vibrisse_essais_tentes_condition1=cell2mat(table_condition1{{'position_vibrisse'},...
    intersect(rang_essais_condition1,find(cell2mat(table_condition1{{'essai_tente'},:})==1))});
position_vibrisse_essais_echoues_condition1=cell2mat(table_condition1{{'position_vibrisse'},...
    intersect(rang_essais_condition1,find(cell2mat(table_condition1{{'reussite'},:})==0))});

position_vibrisse_tous_essais_condition2=cell2mat(table_condition2{{'position_vibrisse'},rang_essais_condition2});
position_vibrisse_essais_tentes_condition2=cell2mat(table_condition2{{'position_vibrisse'},...
    intersect(rang_essais_condition2,find(cell2mat(table_condition2{{'essai_tente'},:})==1))});
position_vibrisse_essais_reussis_condition2=cell2mat(table_condition2{{'position_vibrisse'},...
    intersect(rang_essais_condition2,find(cell2mat(table_condition2{{'reussite'},:})==1))});
position_vibrisse_essais_echoues_condition2=cell2mat(table_condition2{{'position_vibrisse'},...
    intersect(rang_essais_condition2,find(cell2mat(table_condition2{{'reussite'},:})==0))});

moyenne_tous_essais_condition1=nanmean(position_vibrisse_tous_essais_condition1);
ecart_type_tous_essais_condition1=nanstd(position_vibrisse_tous_essais_condition1);
moyenne_tous_essais_condition2=nanmean(position_vibrisse_tous_essais_condition2);
ecart_type_tous_essais_condition2=nanstd(position_vibrisse_tous_essais_condition2);

moyenne_essais_echoues_condition1=nanmean(position_vibrisse_essais_echoues_condition1);
ecart_type_essais_echoues_condition1=nanstd(position_vibrisse_essais_echoues_condition1);
moyenne_essais_echoues_condition2=nanmean(position_vibrisse_essais_echoues_condition2);
ecart_type_essais_echoues_condition2=nanstd(position_vibrisse_essais_echoues_condition2);

moyenne_essais_reussis_condition1=nanmean(position_vibrisse_essais_reussis_condition1);
ecart_type_essais_reussis_condition1=nanstd(position_vibrisse_essais_reussis_condition1);
moyenne_essais_reussis_condition2=nanmean(position_vibrisse_essais_reussis_condition2);
ecart_type_essais_reussis_condition2=nanstd(position_vibrisse_essais_reussis_condition2);

moyenne_essais_tentes_condition1=nanmean(position_vibrisse_essais_tentes_condition1);
ecart_type_essais_tentes_condition1=nanstd(position_vibrisse_essais_tentes_condition1);
moyenne_essais_tentes_condition2=nanmean(position_vibrisse_essais_tentes_condition2);
ecart_type_essais_tentes_condition2=nanstd(position_vibrisse_essais_tentes_condition2);


%% Figures

figure

subplot(2,1,1)
histogram(position_vibrisse_essais_reussis_condition1,'Normalization','probability')
hold on
histogram(position_vibrisse_essais_echoues_condition1,'Normalization','probability');
legend('essais réussis','essais échoués')
xlim([50 140])
if postlesion_ION_condition1=='o' & cno_condition1=='n'
    title([cell2mat(table_condition1{{'nom_animal'},1}) ', rat ION lésé, sans CNO'])
elseif postlesion_ION_condition1=='o' & cno_condition1=='o'
    title([cell2mat(table_condition1{{'nom_animal'},1}) ', rat ION lésé, avec CNO'])
elseif postlesion_ION_condition1=='n' & cno_condition1=='n'
    title([cell2mat(table_condition1{{'nom_animal'},1}) ', rat ION non lésé, sans CNO'])
elseif postlesion_ION_condition1=='n' & cno_condition1=='o'
    title([cell2mat(table_condition1{{'nom_animal'},1}) ', rat ION non lésé, avec CNO'])
end

subplot(2,1,2)
histogram(position_vibrisse_essais_reussis_condition2,'Normalization','probability')
hold on
histogram(position_vibrisse_essais_echoues_condition2,'Normalization','probability');
legend('essais réussis','essais échoués')
xlim([50 140])
if postlesion_ION_condition2=='o' & cno_condition2=='n'
    title([cell2mat(table_condition2{{'nom_animal'},1}) ', rat ION lésé, sans CNO'])
elseif postlesion_ION_condition2=='o' & cno_condition2=='o'
    title([cell2mat(table_condition2{{'nom_animal'},1}) ', rat ION lésé, avec CNO'])
elseif postlesion_ION_condition2=='n' & cno_condition2=='n'
    title([cell2mat(table_condition2{{'nom_animal'},1}) ', rat ION non lésé, sans CNO'])
elseif postlesion_ION_condition2=='n' & cno_condition2=='o'
    title([cell2mat(table_condition2{{'nom_animal'},1}) ', rat ION non lésé, avec CNO'])
end



end

