require 'csv'
require 'matrix'
require 'gnuplot'
require './basic.rb'

xs = [[], [], [], []]
tsv_table("data/tests.tsv") do |row|
  (0..3).each {|i| xs[i] << row[i + 1].to_f }
end

n = xs[0].size
X = Matrix.columns(xs)
Xs = Matrix.columns(X.column_vectors.map {|c| scale(c) })

R = (Xs.t * Xs) / (n - 1)

P, D, _ = R.eigensystem

ratio = (D[3, 3] + D[2, 2]) / D.tr
puts ratio

Sc = Xs * P

pc1 = Sc.column_vectors[3]
pc2 = Sc.column_vectors[2]

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title "tests"
    plot.set "grid"
    plot.xrange "[-3:+3]"
    plot.yrange "[-3:+3]"
    plot.data << Gnuplot::DataSet.new([pc1.to_a, (-pc2).to_a]) do |ds|
      ds.notitle
    end
  end
end

