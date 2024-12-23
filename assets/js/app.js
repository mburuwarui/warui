// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// check for dom_id and notebook_id in debug event
// document.addEventListener("notebooks:debug", (e) => {
//   console.log("Debug info:", {
//     dom_id: e.detail.dom_id,
//     notebook_id: e.detail.notebook_id,
//   });
//
//   const element = document.getElementById(e.detail.dom_id);
//   console.log("Element found:", element);
//
//   if (!element) {
//     // Log all notebook elements for debugging
//     const allNotebookRows = document.querySelectorAll("#notebooks tr");
//     console.log("All notebook rows:", allNotebookRows);
//     console.log(
//       "Notebooks IDs:",
//       Array.from(allNotebookRows).map((row) => row.id),
//     );
//   }
// });

// Dark Mode
function darkExpected() {
  return (
    localStorage.theme === "dark" ||
    (!("theme" in localStorage) &&
      window.matchMedia("(prefers-color-scheme: dark)").matches)
  );
}

function initDarkMode() {
  console.log("initDarkMode called");
  // On page load or when changing themes, best to add inline in `head` to avoid FOUC
  if (darkExpected()) {
    document.documentElement.classList.add("dark");
    const icon = document.getElementById("icon");
    if (icon) {
      icon.setAttribute(
        "d",
        "M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z",
      );
      icon.classList.add("sun-icon");
    }
  } else {
    document.documentElement.classList.remove("dark");
    const icon = document.getElementById("icon");
    if (icon) {
      icon.setAttribute(
        "d",
        "M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z",
      );
      icon.classList.remove("sun-icon");
    }
  }
}

// function switchTheme(isDark) {
//   const header = document.querySelector("header");
//
//   if (isDark) {
//     header.classList.remove("bg-zinc-200");
//     header.classList.add("bg-zinc-800");
//   } else {
//     header.classList.remove("bg-zinc-800");
//     header.classList.add("bg-zinc-200");
//   }
// }

// Add event listener for phx:page-loading-start and phx:page-loading-stop
["phx:page-loading-start", "phx:page-loading-stop"].forEach((event) => {
  window.addEventListener(event, (info) => {
    initDarkMode();
  });
});

// Add event listener for phx:update
window.addEventListener("phx:update", () => {
  initDarkMode();
});

// Add event listener for toggle-darkmode
window.addEventListener("toggle-darkmode", (e) => {
  const isDark = !darkExpected();
  localStorage.theme = isDark ? "dark" : "light";
  initDarkMode();
});

initDarkMode();

// Allows to execute JS commands from the server
window.addEventListener("phx:js-exec", ({ detail }) => {
  document.querySelectorAll(detail.to).forEach((el) => {
    liveSocket.execJS(el, el.getAttribute(detail.attr));
  });
});
