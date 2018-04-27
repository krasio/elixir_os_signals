defmodule OsSignals do
  use GenServer

  def start_link(state \\ :running) do
    IO.inspect("Running with OS PID: #{:os.getpid()}.", label: label())
    :ok = :gen_event.swap_sup_handler(:erl_signal_server, {:erl_signal_handler, []}, {:os_signals_handler, [7_000, __MODULE__]})
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(:running) do
    IO.inspect("Init.", label: label())
    do_work()
    {:ok, :running}
  end

  def handle_info(:wake_up, :stopping) do
    IO.inspect("Wake up call, refusing to start work because stopping.", label: label())
    {:noreply, :stopping}
  end

  def handle_info(:wake_up, :running) do
    IO.inspect("Wake up call, starting to do some work.", label: label())
    do_work()
    {:noreply, :running}
  end

  def handle_info(:please_stop, :running) do
    IO.inspect("Asked to stop.", label: label())
    {:noreply, :stopping}
  end

  def handle_info(:please_stop, :stopping) do
    IO.inspect("Already stopping.", label: label())
    {:noreply, :stopping}
  end

  def do_work do
    IO.inspect("Work started.", label: label())
    Process.sleep(3 * 1_000)
    IO.inspect("Work done, going to sleep.", label: label())
    Process.send_after(self(), :wake_up, 2 * 1_000)
  end

  defp label do
    Kernel.inspect(self())
  end
end
