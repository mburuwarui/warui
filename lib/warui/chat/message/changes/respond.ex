defmodule Warui.Chat.Message.Changes.Respond do
  use Ash.Resource.Change
  require Ash.Query

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatMistralAI

  @impl true
  def change(changeset, _opts, context) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      message = changeset.data

      messages =
        Warui.Chat.Message
        |> Ash.Query.filter(conversation_id == ^message.conversation_id)
        |> Ash.Query.filter(id != ^message.id)
        |> Ash.Query.limit(10)
        |> Ash.Query.select([:text, :source])
        |> Ash.Query.sort(inserted_at: :desc)
        |> Ash.read!()
        |> Enum.concat([%{source: :user, text: message.text}])

      system_prompt =
        LangChain.Message.new_system!("""
        You are a helpful chat bot.
        """)

      message_chain =
        Enum.map(messages, fn message ->
          if message.source == :agent do
            LangChain.Message.new_assistant!(message.text)
          else
            LangChain.Message.new_user!(message.text)
          end
        end)

      new_message_id = Ash.UUID.generate()

      %{
        llm:
          ChatMistralAI.new!(%{
            model: "mistral-medium-latest",
            stream: true,
            custom_context: Map.new(Ash.Context.to_opts(context))
          })
      }
      |> LLMChain.new!()
      |> LLMChain.add_message(system_prompt)
      |> LLMChain.add_messages(message_chain)
      # add the names of tools you want available in your conversation here.
      # i.e tools: [:lookup_weather]
      |> AshAi.setup_ash_ai(otp_app: :warui, tools: [], actor: context.actor)
      |> LLMChain.add_callback(%{
        on_llm_new_delta: fn _model, data ->
          if data.content && data.content != "" do
            Warui.Chat.Message
            |> Ash.Changeset.for_create(
              :upsert_response,
              %{
                id: new_message_id,
                response_to_id: message.id,
                conversation_id: message.conversation_id,
                text: data.content
              },
              actor: %AshAi{}
            )
            |> Ash.create!()
          end
        end,
        on_message_processed: fn _chain, data ->
          if data.content && data.content != "" do
            Warui.Chat.Message
            |> Ash.Changeset.for_create(
              :upsert_response,
              %{
                id: new_message_id,
                response_to_id: message.id,
                conversation_id: message.conversation_id,
                text: data.content,
                complete: true
              },
              actor: %AshAi{}
            )
            |> Ash.create!()
          end
        end
      })
      |> LLMChain.run(mode: :while_needs_response)

      changeset
    end)
  end
end
