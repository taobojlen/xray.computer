import "../css/app.css";

import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";

import Prism from "prismjs";

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

const addClickListenersToLineNumbers = () => {
  Array.from(document.getElementsByClassName("prism-line")).forEach(
    (element) => {
      const lineNumber = element.getAttribute("data-line-number");
      element.addEventListener("click", () => {
        Array.from(document.getElementsByClassName("selected-line")).forEach(
          (otherElement) => {
            otherElement.classList.remove("selected-line");
          }
        );
        element.classList.add("selected-line");
        window.location.hash = `L${lineNumber}`;
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
        target?.scrollIntoView();
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
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
(window as any).liveSocket = liveSocket;
