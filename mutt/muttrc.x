set realname = "Evan Chen"
set use_from = yes
set signature = "~/.config/mutt/signature"

mailboxes ~/Mail/personal/Inbox
# mailboxes ~/Mail/personal/All
mailboxes ~/Mail/personal/Blocked
mailboxes ~/Mail/personal/Defer
mailboxes ~/Mail/personal/Pinned
# mailboxes ~/Mail/personal/Sent
# mailboxes ~/Mail/personal/Trash

mailboxes ~/Mail/work/Inbox
# mailboxes ~/Mail/work/All
mailboxes ~/Mail/work/Blocked
mailboxes ~/Mail/work/Defer
mailboxes ~/Mail/work/Pinned
# mailboxes ~/Mail/work/Sent
# mailboxes ~/Mail/work/Trash

mailboxes ~/Mail/records/Inbox
# mailboxes ~/Mail/records/All
mailboxes ~/Mail/records/Blocked
mailboxes ~/Mail/records/Defer
mailboxes ~/Mail/records/Pinned
# mailboxes ~/Mail/records/Sent
# mailboxes ~/Mail/records/Trash

folder-hook ~/Mail/personal/[a-zA-Z]* source ~/.config/mutt/muttrc.0
folder-hook ~/Mail/work/[a-zA-Z]*     source ~/.config/mutt/muttrc.1
folder-hook ~/Mail/records/[a-zA-Z]*  source ~/.config/mutt/muttrc.2
folder-hook ~/Mail/[a-z]*/All     color indicator black  yellow
folder-hook ~/Mail/[a-z]*/Trash   color indicator white  black
folder-hook ~/Mail/[a-z]*/Sent    color indicator black  brightwhite

## General settings
set mbox_type = Maildir
set sort = threads
set sort_aux = last-date-received
set text_flowed = yes
set auto_tag = yes
set collapse_unread = yes
set pager_context = 15
set pager_index_lines = 7
set mail_check = 60
set quit = yes
set wrap = 80
set attach_save_dir = "~/Downloads/"
set abort_noattach = ask-yes
set sleep_time = 0
set simple_search = "~f %s | ~s %s | ~C %s"
set pipe_decode = yes
set delete = yes

set date_format = "%a %m月%d日"
set index_format = "%3C %[%b%d]%Z%M %-10.10L %?X?%X📌&?%s"
set pager_format = "%4C %Z %[%a %m月%d日%R] %.20n %s%* -- (%P)"
set display_filter="exec sed -r \"s/^Date:\\s*(([F-Wa-u]{3},\\s*)?[[:digit:]]{1,2}\\s+[A-Sa-y]{3}\\s+[[:digit:]]{4}\\s+[[:digit:]]{1,2}:[[:digit:]]{1,2}(:[[:digit:]]{1,2})?\\s+[+-][[:digit:]]{4}).*/date +'Date: %a %m月%d日%R' -d '\\1'/e\""

## SIDEBAR
set sidebar_visible = yes
set sidebar_width = 12
set sidebar_short_path = yes
set sidebar_component_depth = 4
set sidebar_delim_chars = '/.'
set sidebar_folder_indent = yes
set sidebar_new_mail_only = no
set sidebar_non_empty_mailbox_only = no
set sidebar_next_new_wrap = no
set sidebar_on_right = no
set sidebar_divider_char = '∥'
set sidebar_indent_string = ' ➤'
set mail_check_stats
# Display the Sidebar mailboxes using this format string.
set sidebar_format = '%D%* %?N?%N/?%S'
set sidebar_sort_method = 'unsorted'

## Bindings
bind index \043 noop
macro index,pager e "<save-message>=All<enter><enter>$<enter-command>echo \"Archived selection\"<enter>" "Archive"
macro index,pager \043 "<save-message>=Trash<enter><enter><enter-command>echo \"Deleted selection\"<enter>" "Trash"

# bind escape to untag all
bind index . noop
macro index . "<untag-pattern>.<enter><limit>.<enter>" "Reset view"

bind index,pager a group-reply
bind index - collapse-thread
bind index _ collapse-all

macro index,pager z "<pipe-message>vim -R -c \"set ft=mail\" -<enter>" "View in Vim"

bind index,pager g noop
macro index,pager gi "<change-folder>=Inbox<enter>" "Go to inbox"
macro index,pager ga "<change-folder>=All<enter>" "Go to all mail"
macro index,pager ge "<change-folder>=All<enter>" "Go to all mail"
macro index,pager gt "<change-folder>=Sent<enter>" "Go to sent"
macro index,pager g\043 "<change-folder>=Trash<enter>" "Go to trash"
macro index,pager gd "<change-folder>=Defer<enter>" "Go to deferred"
macro index,pager gb "<change-folder>=Blocked<enter>" "Go to blocked"
macro index,pager gp "<change-folder>=Pinned<enter>" "Go to pinned"


bind index,pager m noop
macro index,pager mi "<save-message>=Inbox<enter><enter>$<enter-command>echo \"Inboxed selection\"<enter>" "Move to inbox"
macro index,pager ma "<save-message>=All<enter><enter>$<enter-command>echo \"Archived selection\"<enter>" "Archive"
macro index,pager me "<save-message>=All<enter><enter>$<enter-command>echo \"Archived selection\"<enter>" "Archive"
macro index,pager m\043 "<save-message>=Trash<enter><enter><enter-command>echo \"Deleted selection\"<enter>" "Trash"
macro index,pager md "<save-message>=Defer<enter><enter>$<enter-command>echo \"Deferred selection\"<enter>" "Defer"
macro index,pager mb "<save-message>=Blocked<enter><enter>$<enter-command>echo \"Blocked selection\"<enter>" "Block"
macro index,pager mp "<save-message>=Pinned<enter><enter>$<enter-command>echo \"Pinned selection\"<enter>" "Pin"

bind index t tag-entry
bind index x tag-thread
macro pager t "<exit><tag-entry>" "Tag entry"
macro pager x "<exit><tag-thread>" "Tag thread"

# change mailbox
macro index,pager mu <change-folder>~/Mail/personal/Inbox/<enter> "Change to account 0"
macro index,pager m1 <change-folder>~/Mail/work/Inbox/<enter> "Change to account 1"
macro index,pager m2 <change-folder>~/Mail/records/Inbox/<enter> "change to account 2"
macro index,pager mt <change-folder>

bind index gg first-entry
bind index G last-entry
bind index j next-entry
bind index k previous-entry
bind index J next-thread
bind index K previous-thread

bind pager i noop
bind pager j next-line
bind pager k previous-line
bind pager <down> next-line
bind pager <up> previous-line
bind pager J next-undeleted
bind pager K previous-undeleted
bind pager <enter> next-undeleted
bind pager gg top
bind pager G bottom
bind pager E edit-raw-message

bind index,pager r reply
bind index,pager a group-reply
#bind index,pager a noop
#macro index,pager r "<pipe-message>abook --add-email<enter><reply>" "Reply"
#macro index,pager a "<pipe-message>abook --add-email<enter><group-reply>" "Reply all"
macro index,pager A "<pipe-message>abook --add-email-quiet<enter>" "Add to contacts"
set wait_key = no

bind index,pager c mail
bind index,pager C compose-to-sender
macro pager V <pipe-message>urlscan<enter>

bind compose v view-attach
macro compose <Space> "<first-entry><pipe-message>python ~/.config/mutt/mutt-markdown.py<enter><attach-file>/tmp/neomutt-alternative.html<enter><tag-entry><first-entry><tag-entry><group-alternatives><send-message><shell-escape>~/dotfiles/sh-scripts/noisemaker.sh 5<enter>" "Compile as markdown and send"

bind generic,index,pager \Cf       next-page
bind generic,index,pager \Cb       previous-page
bind generic,index,pager \Cd       half-down
bind generic,index,pager \Cu       half-up

bind attach d noop
bind attach D delete-entry

## Hooks

# ----------------------------------------------
# COMPOSITION SETTINGS

set edit_headers = yes
set autoedit = yes
set fast_reply = yes
set use_from = yes
set include = yes
set editor = "vim"
set sig_on_top = yes
set attribution_locale = "zh_TW.UTF-8"
set attribution = "%f 於%[%A%m月%d日%R]寫道："
set abort_nosubject = yes
unset record

# ----------------------------------------------
#  Viewing settings  #

set markers=no
set wrap=78
set pager_stop=yes
set mailcap_path = "~/.config/mutt/mailcap"

# ----------------------------------------------

color hdrdefault black        cyan
color quoted     red          white
color signature  brightblack  white
# color indicator  brightwhite  red
color attachment black        green
color error      red          white
color message    blue         white
color search     brightwhite  magenta
# color status     brightyellow blue
color tree       red          white
color normal     blue         white
color tilde      green        white
color bold       brightyellow white
color markers    red          white

# Colour definitions when on a mono screen
mono bold      bold
mono underline underline
mono indicator reverse

# Colours for items in the reader
color header white  black "."
color header brightyellow black "^(From|Subject):"
color header red         black "^X-Junked-Because: "
mono  header bold             "^(From|Subject|X-Junked-Because|X-Virus-hagbard):"

# Colours for items in the index
color index brightblue  brightyellow  ~N
color index brightblue  white   ~O
color index brightwhite magenta ~F
color index black       cyan  ~T
color index brightwhite black ~D
mono  index bold              ~N
mono  index bold              ~O
mono  index bold              ~F
mono  index bold              ~T
mono  index bold              ~D

# Highlights inside the body of a message.

# URLs
color body brightblue  white "(http|https|ftp|news|telnet|finger)://[^ \">\t\r\n]*"
color body brightblue  white "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
color body brightblue  white "news:[^ \">\t\r\n]*"
mono  body bold              "(http|https|ftp|news|telnet|finger)://[^ \">\t\r\n]*"
mono  body bold              "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
mono  body bold              "news:[^ \">\t\r\n]*"

# email addresses
color body brightblue  white "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
mono  body bold              "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"

# Various smilies and the like
color body brightgreen white "<[Gg]>"                                            # <g>
color body brightgreen white "<[Bb][Gg]>"                                        # <bg>
color body brightgreen white " [;:]-*[)>(<|]"                                    # :-) etc...
color body brightblue  white "(^|[[:space:]])\\*[^[:space:]]+\\*([[:space:]]|$)" # *Bold* text.
color body brightblue  white "(^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)"     # _Underlined_ text.
color body brightblue  white "(^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)"     # /Italic/ text.

# NeoMutt color settings
color index_author magenta white '.*'
color index_author brightblack brightyellow ~N
color index_author black white ~O
color index_author brightblack magenta ~F
color index_author brightblack cyan ~T
color index_author brightmagenta black ~D

color index_collapsed default brightblue
color index_date green black
color index_label default brightgreen

color index_number magenta white
color index_size cyan white

color sidebar_divider blue white
# color sidebar_spoolfile blue white
color sidebar_ordinary black white
color sidebar_flagged black white
color sidebar_new brightcyan white
color sidebar_unread brightblack white

# vim: ft=neomuttrc
