require 'yaml'

class TeamNameMappings < Array
  class TeamNameMappingChoice
    attr_accessor   :from_name,
                    :to_name,
                    :idx
    
    def initialize(from_name, to_name, idx)
      @from_name = from_name
      @to_name   = to_name
      @idx       = idx
    end
  end

  def initialize(from_names, to_names)
    while from_names.size >=  1 do
      idx=0
      map_choices = []
      from_names.each do |from|
        to_names.each do |to| 
          idx += 1
          map_choices << TeamNameMappingChoice.new(from, to, idx)
        end
        break;
      end
      if map_choices.size > 1
        choice = get_choice(map_choices)
        return nil if choice.nil?
      else
        choice = map_choices[0]
      end
      self << TeamNameMapping.new(choice.from_name, choice.to_name)
      from_names.reject!{|a| a == choice.from_name}
      to_names.reject!{|a| a == choice.to_name}
    end
  end

  def add_teams_file(path, pattern, teams)
    changed_teams = Teams.new
    self.each do |map|
       changed_teams << teams.find_by_name(map.to_name)
    end

    file = Dir.glob(File.join("**", path, pattern)).sort.last
    if file
      filebase = file.gsub(file.slice(/^.*\//),'').gsub(/\d*\.yml$/,'')
      idx =  file.gsub(file.slice(/^.*\//),'').gsub(/\.yml$/,'').gsub(filebase,'')
      idx = idx.to_i
      idx += 1

      File.open(File.join(path, "#{filebase}#{sprintf "%3.3d", idx}.yml"), "w") do |out|
        YAML.dump({"teams" => changed_teams}, out)
      end
    end
  end

  def fix_result_files(path, pattern)
    Dir.glob(File.join("**", path, pattern)).sort.each do |f|
      records = ResultTxt.records(f)
      records.each do |rec|
        self.each do |map|
          rec.line.gsub!(map.from_name, map.to_name)
        end
      end
      fout = File.open(f, "w")
      records.each do |rec|
        fout.puts rec.line
      end
      fout.close
    end
  end

  def fix_teams(teams)
    self.each do |map|
      team = teams.find_by_name(map.from_name)
      team.name = map.to_name unless team.nil?
    end
  end

  private

  def get_choice(map_choices)
    while true do
      puts
      puts
      printf "%24.24s    %-20.20s\n", "From Name","To Name"
      printf "%24.24s    %-20.20s\n", "-" * 20, "-" * 20
      map_choices.each do |choice|
        printf "%2i. %20.20s => %-20.20s\n", choice.idx, choice.from_name, choice.to_name  
      end
      crange = Range.new(1,map_choices.size)
      puts " x. Exit"
      puts
      printf "Pick name switch from above [(1..%d),[xX]]: ", map_choices.size 
      ans = gets
      ans.chomp!
      return nil if ans.downcase.eql?("x")
      if ans.to_i.to_s == ans
        break if crange.include?(ans.to_i)
      end
    end
    return map_choices[ans.to_i-1]
  end
end
