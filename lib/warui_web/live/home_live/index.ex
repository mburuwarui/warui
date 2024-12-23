defmodule WaruiWeb.HomeLive.Index do
  use WaruiWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <div class="relative grid w-full bg-zinc-200 dark:bg-zinc-800 h-96 lg:h-[32rem] place-items-center">
        <div class="flex flex-col items-center mx-auto text-center">
          <.h1 color="natural" font_weight="font-bold" class="md:text-5xl lg:text-7xl">Mburu Warui</.h1>

          <.p color="natural" size="medium" class="leading-5 md:text-2xl lg:text-3xl">
            Token Systems Architect & Cryptographic Infrastructure Engineer
          </.p>

          <a href="#about" class="mt-8 cursor-pointer animate-bounce">
            <svg
              width="53"
              height="53"
              viewBox="0 0 53 53"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <circle cx="27" cy="26" r="18" stroke="white" stroke-width="2" />
              <path
                d="M22.41 23.2875L27 27.8675L31.59 23.2875L33 24.6975L27 30.6975L21 24.6975L22.41 23.2875Z"
                fill="white"
              />
            </svg>
          </a>
        </div>
      </div>

      <svg
        class="fill-zinc-200 dark:fill-zinc-800"
        viewBox="0 0 1440 57"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M1440 0H0V57C720 0 1440 57 1440 57V0Z" />
      </svg>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16 " id="about">
      <div class="lg:flex lg:items-center lg:-mx-4">
        <.card variant="transparent" space="large" class="lg:w-1/2">
          <.card_content padding="large">
            <.h3 size="extra_large" color="natural" font_weight="font-bold" class="md:text-2xl xl:text-3xl mb-7">
              Building Private Bearer Asset Infrastructure & Sovereign Commerce Systems
            </.h3>

            <.p size="medium" color="silver">
              I architect and implement sovereign digital payment systems,
              specializing in private bearer token solutions for digital economies.
              My work centers on creating censorship-resistant transaction layers that 
              work as naturally as cash-in-hand exchanges, but for digital spaces.
              I build everything from player-to-player marketplaces and gaming economies
              to privacy-preserving reward systems and token-based payment infrastructure.
            </.p>
          </.card_content>
          <.card_content padding="large">
            <.p size="medium" color="silver">
              Drawing inspiration from Chaumian ecash principles, I design systems where
              transactions are instant, private by default, and where users maintain full
              custody of their digital assets. My implementations focus on minimizing trust
              requirements and eliminating the need for centralized user databases, protecting
              both users and operators from potential data breaches while enabling genuine
              peer-to-peer digital commerce.
            </.p>
          </.card_content>
        </.card>
        <.card variant="transparent" space="large" class="lg:w-1/2">
          <.video
            ratio="video"
            caption_bakcground="danger"
            caption_size="quadruple_large"
            controls
            autoplay
            loop
            rounded="large"
          >
            <:source
              src="https://mishka.tools/images/flower-a2b96faeb02581770a4736f61bd3b6b7.mp4?vsn=d"
              type="video/mp4"
            />
            <:source
              src="https://mishka.tools/images/flower-a2b96faeb02581770a4736f61bd3b6b7.mp4?vsn=d"
              type="video/mp4"
            />
          </.video>
        </.card>
      </div>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16">
      <.card variant="transparent" class="grid grid-cols-1 gap-8 xl:gap-12 md:grid-cols-2 xl:grid-cols-3">
        <%= for service <- @services do %>
          <div class="p-8 space-y-3 border-2 border-zinc-400 dark:border-zinc-600 rounded-lg">
            <span class="inline-block text-zinc-500 dark:text-zinc-400">
              <.icon name={service.icon} class="w-10 h-10" />
            </span>

            <.h3 color="natural" class="capitalize" font_weight="font-semibold">
              {service.title}
            </.h3>

            <.p color="silver">
              {service.description}
            </.p>
          </div>
        <% end %>
      </.card>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16">
      <.h3 font_weight="font-semibold" color="natural" class="md:text-2xl lg:text-3xl mb-7">
        Explore My Expertise
      </.h3>
      <.tabs id="tab-1" color="silver" rounded="large" padding="large" gap="small" variant="pills" horizontal class="dark:text-zinc-200">
        <:tab icon="hero-home" active-={true}>All</:tab>
        <:tab icon={Enum.at(@services, 0).icon} active-={true}>{Enum.at(@services, 0).title}</:tab>
        <:tab icon={Enum.at(@services, 1).icon}>{Enum.at(@services, 1).title}</:tab>
        <:tab icon={Enum.at(@services, 2).icon}>{Enum.at(@services, 2).title}</:tab>
        <:tab icon={Enum.at(@services, 3).icon}>{Enum.at(@services, 3).title}</:tab>
        <:panel>
          <.applications projects={@projects} />
        </:panel>
        <:panel>
          <.applications projects={[Enum.at(@projects, 0)]} />
        </:panel>
        <:panel>
          <.applications projects={[Enum.at(@projects, 1), Enum.at(@projects, 5)]} />
        </:panel>
        <:panel>
          <.applications projects={[Enum.at(@projects, 2)]} />
        </:panel>
        <:panel>
          <.applications projects={[Enum.at(@projects, 3), Enum.at(@projects, 4)]} />
         </:panel>
      </.tabs>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16">
      <.h3 font_weight="font-semibold" color="natural" class="md:text-2xl lg:text-3xl mb-4">
        Recent Blog Posts
      </.h3>

      <div class="grid grid-cols-1 gap-8 mt-8 md:mt-10 md:grid-cols-2 xl:grid-cols-3">
        <%= for post <- @posts do %>
          <div>
            <div class="relative overflow-hidden group">
              <.image
                class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110"
                src={post.image}
                alt=""
                loading="lazy"
                rounded="large"
              />
              <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
              </div>
              <div class="absolute bottom-0 flex p-3 bg-white dark:bg-zinc-900 ">
                <.image
                  class="object-cover object-center w-10 h-10"
                  src={post.author_image}
                  alt=""
                  rounded="full"
                  loading="lazy"

                />

                <div class="mx-4">
                  <.h1 color="natural" size="small">{post.author}</.h1>
                  <.p color="silver" size="small">{post.author_title}</.p>
                </div>
              </div>
            </div>

            <.h1 size="extra_large" color="natural" class="mt-6">
              {post.title}
            </.h1>

            <hr class="w-32 my-6 text-zinc-500 dark:text-zinc-400" />

            <.p color="silver" size="small">
              {post.description}
            </.p>

            <.link href={post.link}>
              <.small color="primary" size="small" class="underline">Read more</.small>
            </.link>
          </div>
        <% end %>
      </div>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :home, _params) do
    services = [
      %{
        icon: "hero-puzzle-piece",
        title: "Gaming Marketplaces",
        description:
          "I design and develop gaming marketplaces, in-game economies, player-to-player trading systems, and virtual asset exchanges."
      },
      %{
        icon: "hero-gift",
        title: "Loyalty and Rewards Systems",
        description:
          "I design and develop loyalty and rewards systems, including points and rewards tracking, multi-program support, real-time points balance updates, and automated reward distributions."
      },
      %{
        icon: "hero-building-storefront",
        title: "Enterprise Resource Management",
        description:
          "I design and develop enterprise resource management systems, including internal account management, department-wise budget tracking, project-based financial allocation, and real-time expense monitoring."
      },
      %{
        icon: "hero-shopping-bag",
        title: "Marketplace Payment Systems",
        description:
          "I design and develop marketplace payment systems, including escrow account management, split payments, multi-party transactions, and real-time settlement."
      }
    ]

    projects = [
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/17056773/media/00509f74e765da294440886db976943a.png?compress=1&resize=1000x750&vertical=top",
        title: "In-Game Economies and Trading Systems",
        description:
          "Design and development of in-game economies, player-to-player trading systems, and virtual asset exchanges for gaming marketplaces.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/userupload/3233220/file/original-e80767b5947df65a0f1ab4dab4964679.png?compress=1&resize=1024x768",
        title: "Multi-Program Loyalty and Rewards Systems",
        description:
          "Design and development of loyalty and rewards systems with multi-program support, real-time points balance updates, and automated reward distributions.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/14748860/media/25f53296059b741ac1c083be9f41745b.png?compress=1&resize=1000x750&vertical=top",
        title: "Department-Wise Budget Tracking and Financial Allocation",
        description:
          "Design and development of enterprise resource management systems with department-wise budget tracking, project-based financial allocation, and real-time expense monitoring.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/878428/screenshots/17307425/media/01782a518148ce7ef2e790473c888b1f.png?compress=1&resize=1000x750&vertical=top",
        title: "Escrow Account Management and Split Payments",
        description:
          "Design and development of marketplace payment systems with escrow account management, split payments, multi-party transactions, and real-time settlement.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1930709/screenshots/11466872/media/e50b0f02160a77397eb4a76782d23966.png?compress=1&resize=1000x750&vertical=top",
        title: "Virtual Asset Exchanges and Trading Systems",
        description:
          "Design and development of virtual asset exchanges and trading systems for gaming marketplaces, including in-game economies and player-to-player trading systems.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/14403641/media/21e305eb9c8255b6e3367f0ca52c6668.png?compress=1&resize=1000x750&vertical=top",
        title: "Automated Reward Distributions and Real-Time Points Balance Updates",
        description:
          "Design and development of loyalty and rewards systems with automated reward distributions, real-time points balance updates, and multi-program support.",
        link: "#"
      }
    ]

    posts = [
      %{
        image:
          "https://images.unsplash.com/photo-1624996379697-f01d168b1a52?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
        author_image: "/images/logo.jpg",
        author: "Mburu Warui",
        author_title: "Software Engineer",
        title: "What do you want to know about UI",
        description:
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Blanditiis fugit dolorum amet dolores praesentium, alias nam? Tempore",
        link: "#"
      },
      %{
        image:
          "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
        author_image: "/images/logo.jpg",
        author: "Mburu Warui",
        author_title: "Software Engineer",
        title: "All the features you want to know",
        description:
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Blanditiis fugit dolorum amet dolores praesentium, alias nam? Tempore",
        link: "#"
      },
      %{
        image:
          "https://images.unsplash.com/photo-1597534458220-9fb4969f2df5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80",
        author_image: "/images/logo.jpg",
        author: "Mburu Warui",
        author_title: "Software Engineer",
        title: "Which services you get from OLTP Applications",
        description:
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Blanditiis fugit dolorum amet dolores praesentium, alias nam? Tempore",
        link: "#"
      }
    ]

    socket
    |> assign(:services, services)
    |> assign(:projects, projects)
    |> assign(:posts, posts)
  end

  defp page_title(:home), do: "Mburu Warui"

  defp applications(assigns) do
    ~H"""
      <.card variant="transparent" class="grid grid-cols-1 gap-10 md:grid-cols-2 lg:grid-cols-3">
        <%= for project <- @projects do %>
          <.link href={project.link} class="flex-shrink-4 space-y-4">
            <div class="relative overflow-hidden rounded-lg group">
              <.image
                class="object-cover object-center w-full h-64 lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110"
                loading="lazy" 
                rounded="large"
                src={project.image}
                alt={project.title}
              />
              <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
              </div>
            </div>

            <.h4 color="natural">
              {project.title}
            </.h4>

            <.p color="silver" size="small">
              {project.description}
            </.p>
          </.link>
        <% end %>
      </.card>
    """
  end
end
