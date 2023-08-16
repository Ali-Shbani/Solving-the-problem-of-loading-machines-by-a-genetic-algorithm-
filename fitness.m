% This function calculates the fitness of the solutions based on the system imbalance created by each of them
function [fitness_value,system_unbalance,machines_work_time]=fitness(chromosomes,batch_size,process_plans,machines,times,slots,number_of_operations,available_time,available_slots)
fitness_value=zeros(size(chromosomes,1),1);
system_unbalance=zeros(size(chromosomes,1),1);
row=sum(number_of_operations);
col=max(max(max(machines)));
machines_work_time=zeros(size(chromosomes,1),col);
slots_needed=zeros(size(chromosomes,1),col);
for x=1:size(chromosomes,1)
    operations_times=zeros(row,col);
    operations_slots=zeros(row,col);
    solution1=chromosomes(x,:);
    index_operation=1;
    for i=1:length(solution1)
        if solution1(i)==0
            continue
        end
        plan=process_plans(solution1(i),:,i);
        for j=1:length(plan)
            if plan(j)==0
                continue
            end
            index_time=find(machines(j,:,i)==plan(j));
            operations_times(index_operation,plan(j))=times(j,index_time,i)*batch_size(i);
            operations_slots(index_operation,plan(j))=slots(j,index_time,i);
            index_operation=index_operation+1;
        end
    end
    machines_work_time(x,:)=sum(operations_times);
    slots_needed(x,:)=sum(operations_slots);
    
    system_unbalance(x,1)=sum(abs(machines_work_time(x,:)-available_time));
    if slots_needed(x,:)<=available_slots
        fitness_value(x,1)=system_unbalance(x,1);
    else
        fitness_value(x,1)=system_unbalance(x,1)+10000;
    end        
end