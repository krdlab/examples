require 'csv'
require 'matrix'
require 'gnuplot'
require './basic.rb'

x_vals = []
y_vals = []
tsv_table("data/cars.txt") do |row|
  x_vals << row[1].to_i
  y_vals << row[2].to_i
end

x = Vector[*x_vals]
y = Vector[*y_vals]

X = Matrix.columns([[1] * x.size, x])

b = (X.t * X).inv * X.t * y

b0 = b[0].to_f
b1 = b[1].to_f

puts "b0 = #{b0}"
puts "b1 = #{b1}"

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title "cars"
    plot.set "grid"
    plot.data << Gnuplot::DataSet.new([x_vals, y_vals]) do |ds|
      ds.notitle
    end
    plot.data << Gnuplot::DataSet.new("#{b0}+#{b1}*x") do |ds|
      ds.notitle
      ds.linewidth = 3
    end
  end
end

