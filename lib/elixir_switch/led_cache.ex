defmodule ElixirSwitch.LedCache do
  @moduledoc """
  The system entry point that maintains a collection of `LedSwitcher` instances
  and is responsible for their creation and retrieval. All clients issue
  requests to the single `LedCache` process.
  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  # ---
  # The client API
  # ---

  def start_link(_) do
    IO.puts("Starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Finds or creates a LED controller by LED tag.
  """
  def get_led_controller(led_tag) do
    GenServer.call(__MODULE__, {:get_led_controller, led_tag})
  end

  # ---
  # The server callbacks
  # ---

  def init(_) do
    # A map of LED tag to pid, initially blank. It will be something like:
    #
    #     %{"LED A" => #PID<0.208.0>, "LED B" => #PID<0.209.0>, ...}
    #
    led_controllers = %{}

    {:ok, led_controllers}
  end

  def handle_call({:get_led_controller, led_tag}, _caller_pid, led_controllers) do
    case find_or_create_led_controller(led_controllers, led_tag) do
      {:found, led_controller} ->
        {:reply, led_controller, led_controllers}

      {:created, led_controller} ->
        {:reply, led_controller, led_controllers |> Map.put(led_tag, led_controller)}
    end
  end

  defp find_or_create_led_controller(led_controllers, led_tag) do
    case Map.fetch(led_controllers, led_tag) do
      {:ok, led_controller} ->
        {:found, led_controller}

      :error ->
        {:ok, led_controller} = ElixirSwitch.LedController.start_link(led_tag)
        {:created, led_controller}
    end
  end
end
