defmodule Warui.Treasury.Helpers.MoneyConverter do
  @doc """
  Converts an AshMoney/Money struct to a non_neg_integer suitable for TigerBeetle.

  TigerBeetle expects amounts as integer values representing the smallest useful unit
  of the currency (e.g., cents for USD with an asset scale of 2).

  ## Examples

      iex> money = Money.new(:USD, "200.01")
      iex> MoneyConverter.money_to_tigerbeetle_amount(money)
      20001
      
      iex> money = Money.new(:USD, "10.50")
      iex> MoneyConverter.money_to_tigerbeetle_amount(money)
      1050
      
      # Using a custom asset scale (e.g., 4 decimal places)
      iex> money = Money.new(:BTC, "0.12345678")
      iex> MoneyConverter.money_to_tigerbeetle_amount(money, 8)
      12345678
  """
  def money_to_tigerbeetle_amount(%Money{} = money, custom_scale \\ nil) do
    {_currency, integer_part, exponent, remainder} = Money.to_integer_exp(money)

    # The exponent from Money.to_integer_exp is negative for decimal places
    # For example, USD typically has exponent = -2 (2 decimal places)
    money_scale = abs(exponent)

    # If a custom scale is provided, use it, otherwise use the money's scale
    asset_scale = custom_scale || money_scale

    if asset_scale < money_scale do
      raise ArgumentError,
            "TigerBeetle asset scale (#{asset_scale}) cannot be less than money scale (#{money_scale}) as it would lose precision"
    end

    # Calculate the base amount (without remainder)
    base_amount = integer_part

    # If we need to scale to a higher precision than the Money type provides
    if asset_scale > money_scale and not Money.zero?(remainder) do
      # Handle the remainder by converting it to the smallest useful unit
      # Note: This is an approximation as we might not have the full precision
      remainder_str = to_string(remainder)
      # Extract just the decimal part from the remainder
      [_, decimal_part] = String.split(remainder_str, ".")
      # Pad with zeros if needed to match the asset scale
      decimal_part = String.pad_trailing(decimal_part, asset_scale - money_scale, "0")
      # Truncate if longer than needed
      decimal_part = String.slice(decimal_part, 0, asset_scale - money_scale)

      remainder_value = String.to_integer(decimal_part)
      base_amount * trunc(:math.pow(10, asset_scale - money_scale)) + remainder_value
    else
      # If we're using the same scale or don't have a remainder,
      # just adjust for any scale difference
      base_amount * trunc(:math.pow(10, asset_scale - money_scale))
    end
  end

  @doc """
  Converts a TigerBeetle integer amount back to a Money struct.

  ## Examples

      iex> MoneyConverter.tigerbeetle_amount_to_money(20001, :USD, 2)
      Money.new(:USD, "200.01")
      
      iex> MoneyConverter.tigerbeetle_amount_to_money(1050, :USD, 2)
      Money.new(:USD, "10.50")
      
      iex> MoneyConverter.tigerbeetle_amount_to_money(12345678, :BTC, 8)
      Money.new(:BTC, "0.12345678")
  """
  def tigerbeetle_amount_to_money(amount, currency, asset_scale)
      when is_integer(amount) and amount >= 0 do
    # Convert the amount to a string with the appropriate decimal places
    if asset_scale > 0 do
      # Convert to string and ensure it has the right number of digits
      amount_str = String.pad_leading(to_string(amount), asset_scale + 1, "0")

      # Calculate the position to insert the decimal point
      decimal_pos = String.length(amount_str) - asset_scale

      # Split the string and insert the decimal point
      {whole, fraction} = String.split_at(amount_str, decimal_pos)

      # Handle cases where the whole part is empty (amount < 1)
      whole = if whole == "", do: "0", else: whole

      # Create the formatted string with decimal point
      decimal_str = whole <> "." <> fraction

      # Create the Money struct from the decimal string
      Money.new(currency, decimal_str)
    else
      # If no decimal places, just convert directly
      Money.new(currency, to_string(amount))
    end
  end

  @doc """
  Get the asset scale that should be used for a given currency in TigerBeetle.
  This should be configured based on your application's needs.

  ## Examples

      iex> MoneyConverter.get_asset_scale_for_currency(:USD)
      2
      
      iex> MoneyConverter.get_asset_scale_for_currency(:BTC)
      8
  """
  def get_asset_scale_for_currency(currency) do
    # This is where you would define the asset scales for different currencies
    # This could be a configuration setting or a database lookup
    case currency do
      :KES -> 2
      :TZS -> 2
      :UGX -> 2
      :USD -> 2
      :EUR -> 2
      :GBP -> 2
      # No decimal places for Yen
      :JPY -> 0
      # Bitcoin often uses 8 decimal places (satoshis)
      :BTC -> 8
      # Ethereum uses 18 decimal places (wei)
      :ETH -> 18
      # Default to 2 decimal places for unknown currencies
      _ -> 2
    end
  end
end
