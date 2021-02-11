import Prism from "prismjs";
import { decode } from "html-entities";

import splitLines from "./splitLines";

export default (element: HTMLElement) => {
  const extension = element.dataset.extension;
  if (!extension) {
    return;
  }
  let text = [...element.querySelectorAll(".line-content")]
    .map((e) => e.innerHTML)
    .join("\n");
  text = decode(text);

  const grammar = Prism.languages[extension];
  if (grammar) {
    const tokens = Prism.tokenize(text, grammar);
    splitLines(tokens).forEach((tokens, index) => {
      const html = Prism.Token.stringify(tokens, extension);
      const line = document.getElementById(`line-${index}`);
      if (!line) {
        throw new Error(
          `Expected to find #line-${index}, but it doesn't exist`
        );
      }
      line.innerHTML = html;
    });
  }
};
