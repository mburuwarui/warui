defmodule Warui.Accounts.Organization.Changes.SetOwnerCurrentOrganization do
  use Ash.Resource.Change

  def change(changeset, _team, _context) do
    Ash.Changeset.after_action(changeset, &set_owner_current_organization/2)
  end

  defp set_owner_current_organization(_changeset, organization) do
    opts = [authorize?: false]

    {:ok, _user} =
      Warui.Accounts.User
      |> Ash.get!(organization.owner_user_id, opts)
      |> Ash.Changeset.for_update(:set_current_organization, %{organization: organization.domain})
      |> Ash.update(opts)

    {:ok, organization}
  end
end
