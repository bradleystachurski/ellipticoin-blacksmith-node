defmodule NativeContracts.BaseToken do
  def transfer(state, env, recipient, amount) do
    redis = Map.get(state, :redis)
    sender_amount = Redix.command(redis, [
      "GET",
      env.address <> env.contract_id <> env.sender
    ])
      |> elem(1)
      |> :binary.decode_unsigned

    if amount > sender_amount do
      {:reply, {:error, "insufficient funds"}, state}
    else
      Redix.command(redis, [
        "BITFIELD",
        env.address <> env.contract_id <> env.sender,
        "INCRBY",
        "i64",
        0,
        -amount
      ])

      Redix.command(redis, [
        "BITFIELD",
        env.address <> env.contract_id <> recipient,
        "INCRBY",
        "i64",
        0,
        amount
      ])

      {:reply, {:ok, ""}, state}
    end
  end
end
