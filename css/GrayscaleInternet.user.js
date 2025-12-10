// ==UserScript==
// @name         Grayscale Internet
// @namespace    https://web.evanchen.cc/
// @version      1.2
// @description  Turn things to black and white
// @author       Evan Chen
// @match        http://*/*
// @match        https://*/*
// @exclude      https://docs.google.com/*
// @exclude      https://*.youtube.com/*
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
      /rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/,
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
})();
