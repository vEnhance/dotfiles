// ==UserScript==
// @name         Grayscale Internet
// @namespace    https://web.evanchen.cc/
// @version      1.1.8
// @description  Turn things to black and white
// @author       Evan Chen
// @match        http://*/*
// @match        https://*/*
// @exclude      https://github.com/*
// @exclude      https://*.djangoproject.com/*
// @exclude      https://calendar.google.com/*
// @exclude      https://drive.google.com/*
// @exclude      https://docs.google.com/*
// @exclude      https://console.cloud.google.com/*
// @exclude      https://images.google.com/*
// @exclude      https://jamboard.google.com/*
// @exclude      https://duckduckgo.com/images*
// @exclude      http://127.0.0.*
// @exclude      https://nerdcave.com/*
// @exclude      https://www.youtube.com/*
// @exclude      https://*.twitch.tv/*
// @exclude      https://*.netflix.com/*
// @exclude      https://stackoverflow.com/*
// @exclude      https://*.evanchen.cc/*
// @exclude      https://*.wolframalpha.com/
// @exclude      https://*.galacticpuzzlehunt.com/*
// @exclude      https://*.pythonanywhere.com/*
// @exclude      https://hanabi.github.io/*
// @exclude      https://discord.com/*
// @exclude      https://tools.qhex.org/*
// @exclude      https://taskwarrior.org/*
// @exclude      https://*.gradescope.com/*
// @exclude      https://*.readthedocs.io/*
// @exclude      https://*.github.io/*
// @exclude      https://getbootstrap.com/*
// @exclude      https://wordpress.com/*
// @exclude      https://usamo.wordpress.com/*
// @exclude      https://*.archlinux.org/*
// @exclude      http://localhost:*/*
// @exclude      https://*.mailchimp.com/*
// @exclude      https://mailchimp.com/*
// @exclude      https://zapier.com/*
// @exclude      https://ifttt.com/*
// @exclude      http://usaco.org/*
// @exclude      http://*.usaco.org/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// ==/UserScript==

(function() {
  'use strict';
  const head = document.getElementsByTagName('head')[0];
  const body = document.getElementsByTagName('body')[0];

  const oldbg = window.getComputedStyle(body, null).getPropertyValue("background-color");
  function getRGB(str){
    var match = str.match(/rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/);
    return match ? {
      red: Number(match[1]),
      green: Number(match[2]),
      blue: Number(match[3])
    } : {};
  }

  const rgb = getRGB(oldbg);
  const avg = Math.round((rgb.red + rgb.green + rgb.blue) / 3) || 255;
  const elm = document.createElement('style');
  elm.innerHTML = `html { filter: grayscale(100%) brightness(80%) contrast(1.5); background-color: rgb(${avg}, ${avg}, ${avg}) }`;
  head.appendChild(elm);
})();
