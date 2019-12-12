#!/usr/bin/env ruby
class ResultRecord
  attr_accessor :name, :total, :line

  def initialize(name, total, line)
    @name  = name
    @total = total.to_f.round(2)
    @line  = line
  end
end

class ResultTxt
  def self.file_exists?(week=nil)
    return false if week.nil?
    File.exist?(File.join(File.dirname(__FILE__), "..", "stage", "results#{week.pos}.txt"))
  end

  def self.records(file="")
    return nil unless File.exist?(file)
    records = []
    f = File.open(file, "r")
    f.each do |line|
      name = line.split(/\s+/)[0..(line.split(/\s+/).size - 2)].join(' ')
      total = line.split(/\s+/)[-1].to_f.round(2)
      rec = ResultRecord.new(name, total, line)
      records << rec
    end
    f.close
    return records
  end

  def self.names(file="")
    return nil unless File.exist?(file)
    return self.records(file).map(&:name)
  end
end
