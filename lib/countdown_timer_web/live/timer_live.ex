defmodule CountdownTimerWeb.TimerLive do
  use CountdownTimerWeb, :live_view

  def mount(_, _, socket) do
    {:ok, assign(socket, time_left: 0, running: false, paused: false)}
  end

  def handle_event("start", %{"minutes" => minutes}, socket) do
    time_left = String.to_integer(minutes) * 60
    schedule_tick()
    {:noreply, assign(socket, time_left: time_left, running: true)}
  end

  def handle_event("pause", _, socket) do
    {:noreply, assign(socket, _: true)}
  end

  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, time_left: 0, running: false, paused: false)}
  end

  @doc """
  update time_left every 1 min
  """
  def handle_info(
        :tick,
        %{assigns: %{time_left: time_left, paused: paused}} = socket
      ) do
    if !paused and time_left > 0 do
      schedule_tick()
      {:noreply, assign(socket, time_left: time_left - 1)}
    else
      {:noreply,
       socket
       |> push_event("timer-ended", %{})
       |> assign(running: false)}
    end
  end

  # Send :tick message to self() process, every 1000 ms
  defp schedule_tick do
    Process.send_after(self(), :tick, 1000)
  end

  defp format_time(sec) do
    "#{pad_zero(div(sec, 60))}:#{pad_zero(rem(sec, 60))}"
  end

  defp pad_zero(num) when num < 10, do: "0#{num}"
  defp pad_zero(num), do: "#{num}"
end
