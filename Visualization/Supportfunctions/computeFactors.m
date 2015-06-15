function [arsq_factors,factorNames] = computeFactors(answers)

answers = answers';

load ARSQfactors
% answers in the form n_subjects x n_dimensions

n_subjects = size(answers,1);

for i=1:n_subjects
    
    subject = answers(i,:);
    arsq_factors(i,1) = nanmean(double(subject(ARSQfactors.factors.f1')));
    arsq_factors(i,2) = nanmean(subject(ARSQfactors.factors.f2'));
    arsq_factors(i,3) = nanmean(subject(ARSQfactors.factors.f3'));
    arsq_factors(i,4) = nanmean(subject(ARSQfactors.factors.f4'));
    arsq_factors(i,5) = nanmean(subject(ARSQfactors.factors.f5'));
    arsq_factors(i,6) = nanmean(subject(ARSQfactors.factors.f6'));
    arsq_factors(i,7) = nanmean(subject(ARSQfactors.factors.f7'));
    arsq_factors(i,8) = nanmean(subject(ARSQfactors.factors.f8'));
    arsq_factors(i,9) = nanmean(subject(ARSQfactors.factors.f9'));
    arsq_factors(i,10) = nanmean(subject(ARSQfactors.factors.f10'));
    
end

factorNames = ARSQfactors.factorLabels;
% arsq_factors = round(arsq_factors);


