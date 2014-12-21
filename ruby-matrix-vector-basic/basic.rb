require 'matrix'
require 'csv'

def avg(v)
  v.inject(:+) / v.size
end

def var(v)
  sx2 = v.map(&->(x) { x**2 }).inject(:+)
  sx  = v.inject(:+)
  n   = v.size

  ss  = sx2 - sx**2 / n
  ss / (n - 1)
end

def sd(v)
  Math.sqrt(var(v))
end

def scale(v)
  avg = avg(v)
  sd  = sd(v)
  v.map(&->(x) { (x - avg) / sd })
end

def tsv_table(src, &block)
  CSV.foreach(src, col_sep: "\t", return_headers: false, headers: :first_row, &block)
end

