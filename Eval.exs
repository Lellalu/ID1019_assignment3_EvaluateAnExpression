defmodule Eval do
  @type literal() :: {:num, number()} | {:var, atom()}
  @type expr() :: literal()
  | {:add, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:sub, expr(), expr()}
  | {:divi, expr(), expr()}
  | {:q, expr(), expr()}

  def eval({:num,n}, _) do {:num, n} end
  def eval({:var, v}, env) do
    Env.lookup(env, v)
  end

  def eval({:add, e1, e2}, env) do
    add(eval(e1, env), eval(e2, env))
  end
  def eval({:sub, e1, e2}, env) do
    sub(eval(e1, env), eval(e2, env))
  end
  def eval({:mul, e1, e2}, env) do
    mul(eval(e1, env), eval(e2, env))
  end
  def eval({:divi, e1, e2}, env) do
    divi(eval(e1, env), eval(e2, env))
  end
  def eval({:q, e1, e2}, env) do
    {:q, eval(e1, env), eval(e2, env)}
  end
  def eval({:q, {:num,n1}, {:num,n2}}, _) do
    {:q, {:num,n1}, {:num,n2}}
  end
  def eval({:q, {:num,n}, {:var,v}}, _) do
    {:q, {:num,n}, {:var,v}}
  end
  def eval({:q, {:var,v}, {:num,n}}, _) do
    {:q, {:var,v}, {:num,n}}
  end

  def add({:num, n1}, {:num, n2}) do {:num, n1 + n2} end
  def add({:q, {:num, n1}, {:num, n2}}, {:num, m}) do
    simplify_q({:q, {:num, m*n2+n1}, {:num, n2}})
  end
  def add({:num, m}, {:q, {:num, n1}, {:num, n2}}) do
    simplify_q({:q, {:num, m*n2+n1}, {:num, n2}})
  end
  def add({:q, {:num, n1}, {:num, n2}}, {:q, {:num, n3}, {:num, n2}}) do
    simplify_q({:q, {:num, n1+n3}, {:num, n2}})
  end
  def add({:q, {:num, n1}, {:num, n2}}, {:q, {:num, n3}, {:num, n4}}) do
    simplify_q({:q, {:num, n4*n1+n3*n2}, {:num, n2*n4}})
  end

  def sub({:num, n1}, {:num, n2}) do {:num, n1 - n2} end
  def sub({:q, {:num, n1}, {:num, n2}}, {:num, m}) do
    simplify_q({:q, {:num, n1-m*n2}, {:num, n2}})
  end
  def sub({:num, m}, {:q, {:num, n1}, {:num, n2}}) do
    simplify_q({:q, {:num, m*n2-n1}, {:num, n2}})
  end
  def sub({:q, {:num, n1}, {:num, n2}}, {:q, {:num, n3}, {:num, n4}}) do
    simplify_q({:q, {:num, n4*n1-n3*n2}, {:num, n2*n4}})
  end


  def mul({:num, n1}, {:num, n2}) do {:num, n1*n2} end
  def mul({:q, {:num, n1}, {:num, n2}}, {:num, m}) do
    simplify_q({:q, {:num, n1*m}, {:num, n2}})
  end
  def mul({:num, m}, {:q, {:num, n1}, {:num, n2}}) do
    simplify_q({:q, {:num, n1*m}, {:num, n2}})
  end
  def mul({:q, {:num, n1}, {:num, n2}}, {:q, {:num, n3}, {:num, n4}}) do
    simplify_q({:q, {:num, n1*n3}, {:num, n2*n4}})
  end

  def divi({:num, n1}, {:num, n2}) do simplify_q({:q, {:num,n1}, {:num,n2}}) end

  def simplify_q({:q, {:num,n1}, 1}) do {:num, n1} end
  def simplify_q({:q, {:num,n1}, {:num,n2}}) do
    gcd = gcd(n1, n2)
    if(n2/gcd == 1) do
      {:num, trunc(n1/gcd)}
    else
      {:q, {:num,trunc(n1/gcd)}, {:num,trunc(n2/gcd)}}
    end
  end

  def gcd(n1, 0) do n1 end
  def gcd(n1, n2) do gcd(n2, rem(n1, n2)) end

  def test1() do
    env = Env.new([{:x, {:num, 2}}, {:y, {:num, 6}}])
    expr = {:add, {:q, {:num, 1}, {:num, 2}}, {:mul, {:num, 2}, {:var, :x}}}
    eval(expr, env)
  end

  def test2() do
    env = Env.new([{:x, {:num, 2}}, {:y, {:num, 6}}, {:z, {:num, 4}}])
    expr = {:add, {:q, {:divi, {:num, 8}, {:var, :z}}, {:num, 2}}, {:mul, {:num, 2}, {:var, :x}}}
    eval(expr, env)
  end

  def test3() do
    env = Env.new([{:x, {:num, 3}}, {:y, {:num, 2}}, {:z, {:num, 6}}])
    expr = {:divi, {:mul, {:divi, {:num, 8}, {:var, :y}}, {:var, :z}}, {:add, {:num, 2}, {:sub, {:num, 7}, {:var, :x}}}}
    eval(expr, env)
  end
end
