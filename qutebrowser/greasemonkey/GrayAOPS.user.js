// ==UserScript==
// @name         Grayscale AoPS
// @namespace    https://web.evanchen.cc/
// @version      1.3
// @description  I seriously need to stop reading C&P
// @author       Evan Chen
// @match        https://artofproblemsolving.com/community/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// ==/UserScript==

(function () {
  "use strict";
  const head = document.getElementsByTagName("head")[0];
  const body = document.getElementsByTagName("body")[0];

  const oldbg = window
    .getComputedStyle(body, null)
    .getPropertyValue("background-color");
  function getRGB(str) {
    var match = str.match(
      /rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/
    );
    return match
      ? {
          red: Number(match[1]),
          green: Number(match[2]),
          blue: Number(match[3]),
        }
      : {};
  }

  const rgb = getRGB(oldbg);
  const avg = Math.round((rgb.red + rgb.green + rgb.blue) / 3) || 255;

  const elm = document.createElement("style");
  elm.innerHTML = `html { filter: grayscale(100%) brightness(80%) contrast(1.5); background-color: rgb(${avg}, ${avg}, ${avg}) }`;
  head.appendChild(elm);

  const aops = document.createElement("style");
  aops.innerHTML = `
    .cmty-topic-cell.topic-unread { background-color: #eaeaea; }
    .cmty-topic-cell.topic-unread .cmty-topic-cell-subject { font-weight: 400; }
    .cmty-post-thank-count { display: none; }
  `;
  head.appendChild(aops);
})();
