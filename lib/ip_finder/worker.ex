defmodule IpFinder.Worker do
  @backends [
    IpFinder.Backend.WhatIsMyIpAddressCom,
    IpFinder.Backend.DuckDuckGoCom,
    IpFinder.Backend.MyIpAddressCom,
    IpFinder.Backend.MxToolboxCom,
    IpFinder.Backend.DynDnsOrg,
    IpFinder.Backend.WtfIsMyIpCom,
    IpFinder.Backend.IfConfigMe,
    IpFinder.Backend.ICanHazIpCom,
    IpFinder.Backend.IpEchoCom
  ]

  # def start_link(backend, ref, owner, limit) do
  #   backend.start_link(ref, owner, limit)
  # end
  #
  def start_link(backend, ref, owner, start_time) do
    backend.start_link(ref, owner, start_time)
  end

  def get_ip(opts \\ []) do
    limit     = opts[:limit] || 10
    timeout   = opts[:timeout] || 10_000
    backends  = get_backends(opts)

    backends
    |> Enum.map(&spawn_query/1)
    |> await_results(timeout, limit)
    |> Enum.take(limit)
  end

  defp spawn_query(backend) do
    ref = make_ref()
    start_time = :erlang.system_time
    opts = [backend, ref, self, start_time]
    {:ok, pid} = Supervisor.start_child(IpFinder.Supervisor, opts)
    monitor = Process.monitor(pid)
    {pid, monitor, ref}
  end

  defp await_results(children, timeout, limit) do
    timer = Process.send_after(self(), :timedout, timeout)
    results = await_result(children, [], :infinity, limit)
    cleanup(timer)
    results
  end

  defp await_result([head|tail], acc, _timeout, limit) when length(acc) > limit do
    {pid, monitor_ref, _query_ref} = head
    kill(pid, monitor_ref)
    await_result(tail, acc, 0, limit)
  end
  defp await_result([head|tail], acc, timeout, limit) do
    {pid, monitor_ref, query_ref} = head

    receive do
      {:results, ^query_ref, results} ->
        Process.demonitor(monitor_ref, [:flush])
        await_result(tail, results ++ acc, timeout, limit)
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        await_result(tail, acc, timeout, limit)
      :timedout ->
        kill(pid, monitor_ref)
        await_result(tail, acc, 0, limit)
    after
      timeout ->
        kill(pid, monitor_ref)
        await_result(tail, acc, 0, limit)
    end
  end

  defp await_result([], acc, _, _) do
    acc
  end

  defp kill(pid, ref) do
    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)
  end

  defp cleanup(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end

  defp get_backends(opts) do
    case opts[:backends] do
      nil -> @backends
      _   ->
        opts[:backends]
        |> Enum.filter(&(Enum.member?(@backends, &1)))
    end
  end
end
