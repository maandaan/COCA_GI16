constrained_dag = zeros(6,6);
constrained_dag(1,2) = 1;
constrained_dag(1,3) = 1;
constrained_dag(1,5) = 1;
constrained_dag(1,6) = 1;
constrained_dag(3,4) = 1;
constrained_dag(5,6) = 1;

max_score = -realmax;
max_dag = [];

node_sizes = repmat(2,1,6);
data = [1 1 1; 1 0 0; 1 1 0; 1 0 0; 0 0 1; 0 1 1];
[dag,best_score] = learn_struct_gs_hard_constraints(data, node_sizes, constrained_dag);

% for i = 1:6
%     for j = 1:6
%         if constrained_dag(i,j) == 1
%             continue
%         end
%         
%         constrained_dag(i,j) = 1;
%         dag = {constrained_dag};
%         try
%             score = score_dags(data, node_sizes, dag, 'scoring_fn', 'bic');
%         catch
%             constrained_dag(i,j) = 0;
%             continue
%         end
%         if score > max_score
%             max_score = score
%             max_dag = constrained_dag
%         end
%         constrained_dag(i,j) = 0;
%     end
% end