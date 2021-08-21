import "../css/app.css";

import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";

import Prism from "prismjs";
import Alpine from "alpinejs";
import "focus-visible";

(window as any).Alpine = Alpine;

Alpine.start();

Prism.hooks.add("lines-register", (env) => {
  let counter = 0;
  env.listeners.push({
    onNewLine({ line }: { line: HTMLElement }) {
      counter++;
      line.setAttribute("data-line-number", counter.toString());
      line.setAttribute("id", `L${counter}`);
    },
  });
});

// We add line numbers via data attributes and CSS, so we need JS to
// handle clicks
const addClickListenersToLineNumbers = () => {
  const removeSelectedLineClass = () => {
    Array.from(document.getElementsByClassName("selected-line")).forEach(
      (element) => {
        element.classList.remove("selected-line");
      }
    );
  };

  // Source
  Array.from(document.getElementsByClassName("prism-line")).forEach(
    (element) => {
      const lineNumber = element.getAttribute("data-line-number");
      element.addEventListener("click", () => {
        removeSelectedLineClass();
        element.classList.add("selected-line");
        window.history.pushState(null, "", `#L${lineNumber}`)
      });
    }
  );
  // Diff
  Array.from(document.querySelectorAll(".diff-line > td.line-number")).forEach(
    (element) => {
      if (element.classList.contains("line-header")) return;

      element.addEventListener("click", () => {
        removeSelectedLineClass();
        element.parentElement?.classList.add("selected-line");
        // window.location.hash = element.parentElement?.id || "";
        window.history.pushState(null, "", `#${element.parentElement?.id}`)
      });
    }
  );
};

const hooks = {
  codeUpdated: {
    mounted() {
      Prism.highlightAll();
      addClickListenersToLineNumbers();
      // For some reason the scroll-to-anchor doesn't happen (probably because the anchor element
      // isn't present on initial load) so we manually scroll to it. Similarly, we add the
      // `selected-line` class to highlight it because the :target CSS selector also doesn't work.
      if (window.location.hash) {
        const target = document.getElementById(window.location.hash.slice(1));
        target?.classList.add("selected-line");
        target?.scrollIntoView({ block: "center" });
      }
    },
    updated() {
      Prism.highlightAll();
      addClickListenersToLineNumbers();
    },
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  ?.getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", () => NProgress.start());
window.addEventListener("phx:page-loading-stop", () => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
if (process.env.NODE_ENV === "development") {
  liveSocket.enableDebug();
  // liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
  // liveSocket.disableLatencySim()
}
(window as any).liveSocket = liveSocket;
