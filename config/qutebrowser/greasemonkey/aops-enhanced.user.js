// ==UserScript==
// @name        AoPS Enhanced 6
// @namespace   https://gitlab.com/epiccakeking
// @match       https://artofproblemsolving.com/*
// @grant       none
// @version     6.2.0
// @author      epiccakeking
// @description AoPS Enhanced adds and improves various features of the AoPS website.
// @license     MIT
// @icon        https://artofproblemsolving.com/online-favicon.ico?v=2
// ==/UserScript==

// Functions for settings UI elements
let settings_ui = {
  toggle: (label) => (name, value, settings_manager) => {
    let checkbox_label = document.createElement("label");
    let checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.name = name;
    checkbox.checked = value;
    checkbox.addEventListener("change", (e) =>
      settings_manager.set(name, e.target.checked),
    );
    checkbox_label.appendChild(checkbox);
    checkbox_label.appendChild(document.createTextNode(" " + label));
    return checkbox_label;
  },
  select: (label, options) => (name, value, settings_manager) => {
    let select_label = document.createElement("label");
    select_label.innerText = label + " ";
    let select = document.createElement("select");
    select.name = name;
    for (let option of options) {
      let option_element = document.createElement("option");
      option_element.value = option[0];
      option_element.innerText = option[1];
      select.appendChild(option_element);
    }
    select.value = value;
    select.addEventListener("change", (e) =>
      settings_manager.set(name, e.target.value),
    );
    select_label.appendChild(select);
    return select_label;
  },
};

let themes = {
  None: "",
  Mobile: `
.cmty-bbcode-buttons{
  display: block;
  height: auto;
  width: auto !important;
}
.cmty-posting-button-row{
  height: min-content !important;
  display: flow-root;
}
#feed-wrapper{
  display: inline;
}
#feed-topic{
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
.cmty-no-tablet{
  display: inline !important;
}
#feed-topic .cmty-topic-jump{
  position: fixed;
  top: 32px;
  bottom: auto;
  left: auto;
  right: 10px;
  z-index: 1000;
  font-size: 24px;
}
#feed-topic .cmty-topic-jump-top{
  right: 40px;
}
.cmty-upload-modal{
  display: inline;
}
.aops-modal-body{
  width: 100% !important;
}

#feed-tabs .cmty-postbox-inner-box{
  width: 100% !important;
  max-width: none !important;
}

#feed-topic .cmty-topic-posts-outer-wrapper > .aops-scroll-outer > .aops-scroll-inner {
  left: 0;
  width: 100% !important;
}

#feed-topic .cmty-postbox-inner-box {
  max-width: 100% !important;
}
`,
  Dark: `
.cmty-topic-jump{
color: #000;
}
*{
scrollbar-color: #04a3af #333533;
}
::-webkit-scrollbar-track{
background: #333533;
}
::-webkit-scrollbar-thumb{
background: #04a3af;
}
.cmty-topic-posts-top *:not(.cmty-item-tag){
color: black !important;
}
#page-wrapper img:not([class*='latex']):not([class*='asy']),
#feed-wrapper img:not([class*='latex']):not([class*='asy']){
filter: hue-rotate(180deg) invert(1);
}
.bbcode_smiley[src*='latex']{
filter: none !important;
}
.cmty-topic-posts-top,
.cmty-postbox-inner-box,
.cmty-topic-posts-bottom,
.aops-scroll-outer{
background: #ddd !important;
}
.aops-scroll-slider{
background: #222 !important;
}
iframe{
  filter: invert(1) hue-rotate(180deg);
}

#page-wrapper,
.aops-modal-wrapper,
#feed-wrapper > * > *{
filter: invert(1) hue-rotate(180deg);
}
body{
background: #111 !important;
}`,
};

let quote_schemes = {
  AoPS: AoPS.Community
    ? AoPS.Community.Views.Post.prototype.onClickQuote
    : function () {
        alert("Quoting failed");
      }, // Uses dummy function as a fallback when community is undefined.
  Enhanced: function () {
    this.topic.appendToReply(
      '[quote name="' +
        this.model.get("username") +
        '" url="/community/p' +
        this.model.get("post_id") +
        '"]\n' +
        this.model.get("post_canonical").trim() +
        "\n[/quote]\n\n",
    );
  },
  Link: function () {
    this.topic.appendToReply(
      `@[url=https://aops.com/community/p${this.model.get("post_id")}]${this.model.get("username")} (#${this.model.get("post_number")}):[/url]`,
    );
  },
  Hide: function () {
    this.topic
      .appendToReply(`[hide=Post #${this.model.get("post_number")} by ${this.model.get("username")}]
[url=https://aops.com/community/user/${this.model.get("poster_id")}]${this.model.get("username")}[/url] [url=https://aops.com/community/p${this.model.get("post_id")}](view original)[/url]
${this.model.get("post_canonical").trim()}
[/hide]

`);
  },
};

class EnhancedSettingsManager {
  /** Default settings */
  DEFAULTS = {
    notifications: true,
    post_links: true,
    feed_moderation: true,
    kill_top: false,
    quote_primary: "Enhanced",
    quote_secondary: "Enhanced",
    theme: "None",
  };

  /**
   * Constructor
   * @param {string} storage_variable - Variable to use when reading or writing settings
   */
  constructor(storage_variable) {
    this.storage_variable = storage_variable;
    this._settings = JSON.parse(
      localStorage.getItem(this.storage_variable) || "{}",
    );
    this.hooks = {};
  }

  /**
   * Retrieves a setting.
   * @param {string} setting - Setting to retrieve
   */
  get = (setting) =>
    (setting in this._settings ? this._settings : this.DEFAULTS)[setting];

  /**
   * Sets a setting.
   * @param {string} setting - Setting to change
   * @param {*} value - Value to set
   */
  set(setting, value) {
    this._settings[setting] = value;
    localStorage.setItem(this.storage_variable, JSON.stringify(this._settings));
    // Run hooks
    if (setting in this.hooks)
      for (let hook of this.hooks[setting]) hook(value);
  }

  /**
   * Add a hook that will be called when the associated setting is changed.
   * @param {string} setting - Setting to add a hook to
   * @param {function} callback - Callback to run when the setting is changed
   * @param {boolean} run_on_add - Whether to immediately run the hook
   */
  add_hook(setting, callback, run_on_add = true) {
    setting in this.hooks
      ? this.hooks[setting].push(callback)
      : (this.hooks[setting] = [callback]);
    if (run_on_add) callback(this.get(setting));
  }

  // No functions for removing hooks, do it manually by modifying the hooks attribute.
}

let enhanced_settings = new EnhancedSettingsManager("enhanced_settings");
// Old settings adapter
for (let setting of ["quote_primary", "quote_secondary"]) {
  let setting_value = enhanced_settings.get(setting);
  if (setting_value.toLowerCase() == setting_value)
    enhanced_settings.set(
      setting,
      setting_value[0].toUpperCase() + setting_value.slice(1),
    );
}

// Themes
{
  const theme_element = document.createElement("style");

  enhanced_settings.add_hook("theme", (value) => {
    theme_element.textContent = themes[value];
    if (value != "None") {
      document.head.appendChild(theme_element);
    } else if (theme_element.parentNode)
      theme_element.parentNode.removeChild(theme_element);
    window.dispatchEvent(new Event("resize")); // Recalculate sizes of elements
  });
}

// Simplified header
{
  const menubar_wrapper = document.querySelector(".menubar-links-outer");
  const login_wrapper = document.querySelector(".menu-login-wrapper");
  if (!(menubar_wrapper && login_wrapper)) return (_) => null;
  let kill_element = document.createElement("style");
  const menubar_wrapper_normal_position = menubar_wrapper.nextSibling;
  const login_wrapper_normal_position = login_wrapper.nextSibling;
  kill_element.textContent = `
#header {
  display: none !important;
}
.menubar-links-outer {
  position: absolute;
  z-index: 1000;
  top: 0;
  right: 0;
  flex-direction: row-reverse;
}

.menubar-labels{
  line-height: 10px;
  margin-right: 10px;
}

.menubar-label-link.selected{
  color: #fff !important;
}

.menu-login-item {
  color: #fff !important;
}
#small-footer-wrapper {
  display: none !important;
}
.login-dropdown-divider {
  display:none !important;
}
.login-dropdown-content {
  padding: 12px 12px 12px !important;
  border-top: 2.4px #009fad solid;
}

.menu-login-wrapper .login-dropdown-label {
  color: #606060;
}

.menu-login-wrapper {
  height: 35px;
  margin-bottom: -35px; /* Hack to  fix neighboring .site heights */
}
`;

  enhanced_settings.add_hook("kill_top", (value) => {
    if (value) {
      document.getElementById("header-wrapper").before(menubar_wrapper);
      document
        .querySelector(".sharedsite-links > .site:last-child")
        .after(login_wrapper);
      document.head.appendChild(kill_element);
    } else {
      menubar_wrapper_normal_position.before(menubar_wrapper);
      login_wrapper_normal_position.before(login_wrapper);
      if (kill_element.parentNode)
        kill_element.parentNode.removeChild(kill_element);
    }
    window.dispatchEvent(new Event("resize")); // Recalculate sizes of elements
  });
}

// Feed moderator icon
{
  const style = document.createElement("style");
  style.textContent =
    "#feed-topic .cmty-topic-moderate{ display: inline !important; }";
  enhanced_settings.add_hook(
    "feed_moderation",
    (value) => {
      if (value) {
        document.head.appendChild(style);
      } else {
        if (style.parentNode) style.parentNode.removeChild(style);
      }
    },
    true,
  );
}

// Notifications
{
  let notify_functions = [
    AoPS.Ui.Flyout.display,
    (a) => {
      var textextract = document.createElement("div");
      textextract.innerHTML = a.replace("<br>", "\n");
      var y = $(textextract).text();
      var notification = new Notification("AoPS Enhanced", {
        body: y,
        icon: "https://artofproblemsolving.com/online-favicon.ico",
        tag: y,
      });
      setTimeout(notification.close.bind(notification), 5000);
    },
  ];

  enhanced_settings.add_hook(
    "notifications",
    (value) => {
      if (value && Notification.permission != "granted")
        Notification.requestPermission();
      AoPS.Ui.Flyout.display = notify_functions[+value];
    },
    true,
  );
}

function show_enhanced_configurator() {
  UI_ELEMENTS = {
    notifications: settings_ui.toggle("Notifications"),
    post_links: settings_ui.toggle("Post links"),
    feed_moderation: settings_ui.toggle("Feed moderate icon"),
    kill_top: settings_ui.toggle("Simplify UI"),
    quote_primary: settings_ui.select(
      "Primary quote",
      Object.keys(quote_schemes).map((k) => [k, k]),
    ),
    quote_secondary: settings_ui.select(
      "Ctrl quote",
      Object.keys(quote_schemes).map((k) => [k, k]),
    ),
    theme: settings_ui.select(
      "Theme",
      Object.keys(themes).map((k) => [k, k]),
    ),
  };
  let settings_modal = document.createElement("div");
  for (let key in UI_ELEMENTS) {
    settings_modal.appendChild(
      UI_ELEMENTS[key](key, enhanced_settings.get(key), enhanced_settings),
    );
    settings_modal.appendChild(document.createElement("br"));
  }
  alert(settings_modal);
}

// Add "Enhanced" option to login dropdown
{
  const el = document.querySelector(".login-dropdown-content");
  if (el === null) return;
  let enhanced_settings_element = document.createElement("a");
  enhanced_settings_element.classList.add("menu-item");
  enhanced_settings_element.innerText = "Enhanced";
  enhanced_settings_element.addEventListener("click", (e) => {
    e.preventDefault();
    show_enhanced_configurator();
  });
  el.appendChild(enhanced_settings_element);
}

// Prevent errors when trying to modify AoPS Community on pages where it doesn't exist
if (AoPS.Community) {
  AoPS.Community.Views.Post.prototype.onClickQuote = function (e) {
    quote_schemes[
      enhanced_settings.get(e.ctrlKey ? "quote_secondary" : "quote_primary")
    ].call(this);
  };

  // Direct links
  (() => {
    let real_onClickDirectLink =
      AoPS.Community.Views.Post.prototype.onClickDirectLink;
    function direct_link_function(e) {
      let url = "https://aops.com/community/p" + this.model.get("post_id");
      navigator.clipboard.writeText(url);
      AoPS.Ui.Flyout.display(`URL copied: ${url}`);
    }
    AoPS.Community.Views.Post.prototype.onClickDirectLink = function (e) {
      (enhanced_settings.get("post_links")
        ? direct_link_function
        : real_onClickDirectLink
      ).call(this, e);
    };
  })();
}
