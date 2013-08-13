function Pm = pat_fisher_extest(X, tail)
%  Fisher's Exact mid-P method to test row/col independence of a 2x2 contingency table.
%  It is a non-parametric statistical test for discrete data used to   
%  determine if there are nonrandom associations between the two variables.
%  Mid-P values are a reasonable compromise between the conservativeness of 
%  the ordinary exact test and the uncertain adequacy of large-sample methods.
%  Mid-P values usually performs well, typically being a bit conservative,
%  and is currently recommended by many leading statisticians.
%  Program by Steinar Thorvaldsen, steinar.thorvaldsen@uit.no, Dec. 2004. 
%  Ref.: DeltaProt toolbox at http://services.cbu.uib.no/software/deltaprot/
%  Last changes 22. Dec 2010.

%  Input:
%   X:    data matrix (2x2-table) of observed counts
%   tail: The alternative hypothesis against which to compute p-values.
%         Choices are:
%         TAIL        Alternative Hypothesis
%         --------------------------------------
%         'ne'        2-Tail (default)
%         'gt'        Right tail: the alternative to independence is that 
%                     there is positive association between the variables.
%         'lt'        Left tail: the alternative hypothesis is that there is 
%                     negative association between the variables
%  Output:
%       P-value
%
%  Use: P = pat_fisher_extest(Observed,'ne')

%  Please, use the following reference:
%  Thorvaldsen, S. , Fl, T. and Willassen, N.P. (2010) DeltaProt: a software toolbox 
%       for comparative genomics. BMC Bioinformatics 2010, Vol 11:573.
%       See http://www.biomedcentral.com/1471-2105/11/573

%  Other references:
%  Agresti, A. (2001), Exact inference for categorical data: recent advances 
%       and continuing controvercies. Statistics in Medicine, 20: 2709-2722.
%  Hirji, K.F. (2006), Exact Analysis of Discrete Data. Chapman & Hall.
%  Fisher, R.A. (1934), Statistical Methods for Research Workers. Chapter 12. 
%       5th Ed., Oliver & Boyd.
%  Howell, I.P.S. (Internet homepage), http://www.fiu.edu/~howellip/Fisher.pdf

if nargin < 2
    tail ='ne'; %default value
else
    switch tail %validate the tail parameter:
    case {'ne' 'gt' 'lt'}
        % these are ok
    otherwise            
        error('pat_fisher_extest:UnknownTail', ...
          'The ''tail'' parameter value must be ''ne'', ''gt'', or ''lt''.');
    end %switch
end %if

[I J] = size(X);
if I ~= 2 | J ~= 2,
    error('Fisher exact test: Matrix with observations must be of size 2x2');
end

% Fisher's exact test may be usend on integerized values,
% but a chi-square test should be prefered in this case:
X = round(X);

if any(any(X < 0)) | sum(sum(X)) == 0
    Pm = NaN;
    disp ('pat_fisher_extest expects counts that are nonnegative integers');
    return;
end

%Pre-processing the table by moving the smallest marginal total row to the top line:
%Er = X(:,1)./sum(X')';
%if (Er(1)>Er(2))

rs=sum(X,2);
if rs(1)>rs(2)
    if X(1,1)==0
        X=X;
    elseif X(2,2)==0
        X=X([2,1],[2,1]);
    else
        X=X([2,1],:);
    end
end

a = X(1,1);
b = X(1,2);
c = X(2,1);
d = X(2,2);
N=sum(sum(X));
r1 = a+b;
r2 = c+d;
c1 = a+c;
c2 = b+d;

aprob = [0:min([r1 c1])];
bprob = r1-aprob;
cprob = c1-aprob;
dprob = r2-cprob;

num = sum([log(1:r1) log(1:r2) log(1:c1) log(1:c2) -log(1:N)]);

for i = 1:length(aprob)
   denom = sum([log(1:aprob(i)) log(1:bprob(i)) log(1:cprob(i)) log(1:dprob(i))]);
   Pap(i) = num-denom;
end;
Pap = exp(Pap);

% Also determine the probability of the present observation:
denomXobs = sum([log(1:a) log(1:b) log(1:c) log(1:d)]);
Pobs = exp(num-denomXobs);

switch tail
  case 'ne' % 2-tail
    Pm = sum(Pap(find(Pap <= Pobs))) - 0.5*Pobs;
    if Pm > 1
        Pm = 1;
    end
  case 'gt' % Right tail
    Pm = sum(Pap(find(aprob >= a))) - 0.5*Pobs;
    if Pm > 1
        Pm = 1;
    end
  case 'lt' % Left tail
    Pm = sum(Pap(find(aprob <= a))) - 0.5*Pobs;
    if Pm > 1
        Pm = 1;
    end
end
