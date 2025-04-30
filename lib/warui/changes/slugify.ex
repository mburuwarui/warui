defmodule Warui.Changes.Slugify do
  use Ash.Resource.Change

  @doc """
  Generate and populate a `slug` attribute while inserting a new records
  When the action type is create
  """
  def change(%{action_type: :create} = changeset, _opts, context) do
    Ash.Changeset.force_change_attribute(changeset, :slug, generate_slug(changeset, context))
  end

  def change(changeset, _opts, _context), do: changeset

  # Genarates a slug based on the name attribute. If the slug exists already,
  # Then make it unique by prefixing the `-count` at the end of the slug
  defp generate_slug(%{attributes: %{name: name}} = changeset, context) when not is_nil(name) do
    # 1. Generate a slug based on the namae
    slug = slugify(name)

    # Add the count if slug exists
    case count_similar_slugs(changeset, slug, context) do
      {:ok, 0} ->
        slug

      {:ok, count} ->
        "#{slug}-#{count}"

      {:error, error} ->
        raise error
    end
  end

  #
  defp generate_slug(_changeset, _context), do: Ash.UUIDv7

  # Generate a lowcase slug based on the string passed
  defp slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
  end

  # Get a number of existing slugs
  defp count_similar_slugs(changeset, slug, context) do
    require Ash.Query

    changeset.resource
    |> Ash.Query.filter(slug == ^slug)
    |> Ash.count(Ash.Context.to_opts(context))
  end
end
