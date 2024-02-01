defmodule Env do
  def new(list) do
    Enum.into(list, %{})
  end

  def lookup(env, variable_name) do
    env[variable_name]
  end

  def test1() do
    env = Env.new([{:x, 2}, {:y, 6}])
    Env.lookup(env, :z)
  end

end
