class ScoreDeleter
  class << self
    @@operator_map = {1 => '$lt', 2 => '$lte', 4 => '$gte', 5 => '$gt'}
    
    def count(leaderboard, scope, field, operator, value)
      prefix = Score.prefixes[scope]
      conditions = {:leaderboard_id => leaderboard.id, prefix => {'$ne' => nil}}.merge(conditions(field, operator, value, scope))
      Score.count(conditions)
    end
    
    def delete(leaderboard, scope, field, operator, value)
      conditions = {:leaderboard_id => leaderboard.id}.merge(conditions(field, operator, value, scope))
      name = Score.scope_to_name(scope)
      Score.update(conditions, {'$set' => {name => nil}}, {:multi => true})
    end
    
    def conditions(field, operator, value, scope)
      return {:username => value} if field == ScoreDeleterField::UserName
      prefix = Score.prefixes[scope]
      operator == 3 || !@@operator_map.include?(operator) ? {prefix + '.p' => value.to_i} : {prefix + '.p' => {@@operator_map[operator] => value.to_i}}
    end
  end
end