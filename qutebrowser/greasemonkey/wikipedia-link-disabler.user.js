// ==UserScript==
// @name        Wikipedia Link Disabler
// @namespace   https://web.evanchen.cc/
// @match       https://*.wikipedia.org/*
// @grant       none
// @version     1.0.0
// @author      user
// @description Disables all links on Wikipedia pages to prevent doomscrolling
// @license     MIT
// ==/UserScript==

(function () {
  "use strict";

  function isWikipediaArticleLink(link) {
    const href = link.getAttribute("href");
    if (!href) return false;

    // Check if it's a relative link to another Wikipedia article
    if (href.startsWith("/wiki/") && !href.includes(":")) {
      return true;
    }

    // Check if it's an absolute link to a Wikipedia article
    if (href.match(/^https?:\/\/[a-z-]+\.wikipedia\.org\/wiki\/[^:]+$/)) {
      return true;
    }

    return false;
  }

  function disableLinks() {
    const bodyContent = document.getElementById("bodyContent");
    if (!bodyContent) return;

    const links = bodyContent.querySelectorAll("a[href]");

    links.forEach((link) => {
      if (isWikipediaArticleLink(link)) {
        link.style.pointerEvents = "none";
        link.style.color = "#000000";
        link.style.textDecoration = "none";
        link.style.cursor = "default";

        link.addEventListener(
          "click",
          function (e) {
            e.preventDefault();
            e.stopPropagation();
            return false;
          },
          true,
        );
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", disableLinks);
  } else {
    disableLinks();
  }

  const observer = new MutationObserver(function (mutations) {
    const bodyContent = document.getElementById("bodyContent");
    if (!bodyContent) return;

    mutations.forEach(function (mutation) {
      mutation.addedNodes.forEach(function (node) {
        if (node.nodeType === Node.ELEMENT_NODE && bodyContent.contains(node)) {
          const newLinks = node.querySelectorAll
            ? node.querySelectorAll("a[href]")
            : [];
          newLinks.forEach((link) => {
            if (isWikipediaArticleLink(link)) {
              link.style.pointerEvents = "none";
              link.style.color = "#000000";
              link.style.textDecoration = "none";
              link.style.cursor = "default";

              link.addEventListener(
                "click",
                function (e) {
                  e.preventDefault();
                  e.stopPropagation();
                  return false;
                },
                true,
              );
            }
          });
        }
      });
    });
  });

  const bodyContent = document.getElementById("bodyContent");
  if (bodyContent) {
    observer.observe(bodyContent, {
      childList: true,
      subtree: true,
    });
  }
})();
