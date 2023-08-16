%{
In this code, a mathematical model of the machine loading problem has been built and the parental selection method has been defined in the genetic algorithm.
Then the coefficients of crossover, mutation, number of generations, and population size were chosen. Then the proposed model was applied to some problems.
As a result, good solutions are found and the performance of the resilient system is improved. System losses were also minimized and maximum utilization
was made of the available resources, which increased the efficiency of the system and increased its economic income.

the original data is written to a Microsoft Excel spreadsheet, then the spreadsheet is read into MATLAB and a genetic algorithm is applied to the data to
obtain optimal results.

The performance of the proposed model was evaluated based on some reference tasks adopted by Mukhopadhyay et al. (1992), where the source data for each task
is available.

The proposed genetic algorithm was coded in MATLAB R2014a and run on an Intel® Core i3 laptop with a 2.4 GHz processor and 2 GB of RAM.
%}

clc
for counter=1:10
tic
clear;
%----------------Data initialization----------------
[num,txt,raw] = xlsread('task1');
number_of_jobs=max(num(:,1));
batch_size=zeros(1,number_of_jobs);
number_of_operations=zeros(1,number_of_jobs);
for i=1:number_of_jobs
    index=find(num(:,1)==i);
    batch_size(i)=num(index,2);
end
index1=1;
index2=1;
for i=1:number_of_jobs-1
    index1=find(num(:,1)==i);
    index2=find(num(:,1)==i+1);
    number_of_operations(i)=max(num(index1:index2-1,3));
end
number_of_operations(number_of_jobs)=max(num(index2:size(num,1),3));

number_of_machines=zeros(number_of_jobs,max(number_of_operations));
for i=1:number_of_jobs
    index1=find(num(:,1)==i);
    if i==number_of_jobs 
        index2=size(num,1)+1;
    else
        index2=find(num(:,1)==i+1);
    end
    for j=1:number_of_operations(i)-1
        index3=find(num(index1:index2-1,3)==j);
        index4=find(num(index1:index2-1,3)==j+1);
        number_of_machines(i,j)=index4-index3;
        machines(j,1:number_of_machines(i,j),i)=num(index1+index3-1:index1+index4-2,6);
        times(j,1:number_of_machines(i,j),i)=num(index1+index3-1:index1+index4-2,4);
        slots(j,1:number_of_machines(i,j),i)=num(index1+index3-1:index1+index4-2,5);
    end
    if isempty(j)
        number_of_machines(i,1)=index2-index1;
        machines(1,1:number_of_machines(i,1),i)=num(index1:index2-1,6);
        times(1,1:number_of_machines(i,1),i)=num(index1:index2-1,4);
        slots(1,1:number_of_machines(i,1),i)=num(index1:index2-1,5);
    else
        number_of_machines(i,j+1)=index2-index1-index4+1;
        machines(j+1,1:number_of_machines(i,j+1),i)=num(index1+index4-1:index2-1,6);
        times(j+1,1:number_of_machines(i,j+1),i)=num(index1+index4-1:index2-1,4);
        slots(j+1,1:number_of_machines(i,j+1),i)=num(index1+index4-1:index2-1,5);
    end
end

number_of_process_plans=zeros(1,number_of_jobs);
a=number_of_machines;
a(a==0)=1;
for i=1:size(a,1)
    k=1;
    for j=1:size(a,2)
        k=k*a(i,j);
    end
    number_of_process_plans(i)=k;
end

process_plans=zeros(max(number_of_process_plans)+1,max(number_of_operations),number_of_jobs);

for i=1:number_of_jobs
    g=machines(:,:,i)';
    ssize = number_of_process_plans(i);
    ncycles = ssize;
    levels=number_of_machines(i,1:number_of_operations(i));
    cols = size(levels,2);
    design = zeros(ssize,cols);
    L=1;
    H=0;
    for k = 1:cols
        H=L+levels(k)-1;
        settings = g(L:H);                       % settings for kth factor
        nreps = ssize./ncycles;                  % repeats of consecutive values
        ncycles = ncycles./levels(k);            % repeats of sequence
        settings = settings(ones(1,nreps),:);    % repeat each value nreps times
        settings = settings(:);                  % fold into a column
        settings = settings(:,ones(1,ncycles));  % repeat sequence to fill the array
        design(:,k) = settings(:);
        L=L+size(g,1);
    end
    process_plans(1:number_of_process_plans(i),1:number_of_operations(i),i)=design;
end

number_of_chromosomes=prod(number_of_process_plans+1);%number_of_process_plans+1 for 0 situation

%----------------Create the initial population census----------------
size_population=floor(number_of_chromosomes/10);
chromosomes=zeros(size_population,number_of_jobs);
for i=1:size_population
    for j=1:number_of_jobs
        chromosomes(i,j)=floor(rand*(number_of_process_plans(j)+1));
    end
end

%----------------Fitness evaluation for the first generation----------------
available_time=[480 480 480 480];
available_slots=[5 5 5 5];
[fitness_value,system_unbalance,machines_work_time]=fitness(chromosomes,batch_size,process_plans,machines,times,slots,number_of_operations,available_time,available_slots);
sum_fitness_value=sum(fitness_value)

generation=1;
while (generation<60)
    generation=generation+1;
    %----------------Selection----------------
    aux_fitness_value=fitness_value;
    indexs_of_chromosomes=1:size(chromosomes,1);
    indexs_of_chromosomes=indexs_of_chromosomes';
    for i=1:size(chromosomes,1)/2
        x=find(aux_fitness_value==min(aux_fitness_value));
        y=find(aux_fitness_value==max(aux_fitness_value));
        for j=1:length(y)
            chromosomes(indexs_of_chromosomes(y(j)),:)=chromosomes(indexs_of_chromosomes(x(1)),:);
        end
        z=[x;y];
        aux_fitness_value(z)=[];
        indexs_of_chromosomes(z)=[];
        if isempty(aux_fitness_value)
            break
        end
    end
    
    %----------------Crossover----------------
    crossover_rate=0.4;
    for i=1:2:size(chromosomes,1)-1
        r=rand;
        crossover_start=size(chromosomes,2);
        crossover_end=size(chromosomes,2);
        if r<crossover_rate
            swap=chromosomes(i,crossover_start:crossover_end);
            chromosomes(i,crossover_start:crossover_end)=chromosomes(i+1,crossover_start:crossover_end);
            chromosomes(i+1,crossover_start:crossover_end)=swap;
        end
    end
    
    %----------------Mutation----------------
    mutation_rate=0.002;
    for i=1:size(chromosomes,1)
        for j=1:size(chromosomes,2)
            r=rand;
            if r<mutation_rate
                new_gen=floor(rand*(number_of_process_plans(j)+1));
                if new_gen==chromosomes(i,j) && new_gen+1>number_of_process_plans(j)
                    chromosomes(i,j)=0;
                elseif new_gen==chromosomes(i,j) 
                    chromosomes(i,j)=new_gen+1;
                else 
                    chromosomes(i,j)=new_gen;
                end
            end
        end
    end
    
    %----------------Fitness evaluation for the resulting generation----------------
[fitness_value1,system_unbalance,machines_work_time]=fitness(chromosomes,batch_size,process_plans,machines,times,slots,number_of_operations,available_time,available_slots); 
sum_fitness_value1=sum(fitness_value1);
if abs(sum_fitness_value-sum_fitness_value1)<3
    break
else
    sum_fitness_value=sum_fitness_value1;
end
    
end
sum_fitness_value1
min(fitness_value1)
index_min_fitness1=find(fitness_value1==min(fitness_value1));
sol1=chromosomes(index_min_fitness1(1),:);
throughput=0;
plan=zeros(number_of_jobs,max(number_of_operations));
for i=1:length(sol1)
    if sol1(i)~=0
        throughput=throughput+batch_size(i);
        plan(i,:)=process_plans(sol1(i),:,i);
    end
end
throughput
plan
toc
    %----------------Show results----------------
x_start=0;
y_start=0.75;
solution=machines_work_time(index_min_fitness1(1),:);

figure('color','w'),set(axes,'FontSize',20)
hold on
ylim([0, length(solution)+0.5]);
for i=1:length(solution)
    rectangle('Position', [x_start, y_start, solution(i), 0.5],'EdgeColor', 'b', 'FaceColor', 'b');
    x_start=0;
    y_start=y_start+1;
end
xlabel('Time')
ylabel('Machine')
line([480 480],[0 max(solution)+0.5],'Color','k','LineStyle','--')
text(480,0.25,'480','FontSize',20)

end