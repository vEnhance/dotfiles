# MAILBOX + HOOK SETUP {{{
mailboxes ~/Mail/personal/Inbox
mailboxes ~/Mail/work/Inbox
mailboxes ~/Mail/records/Inbox

folder-hook ~/Mail/personal/[a-zA-Z]* source ~/.config/mutt/muttrc.0
folder-hook ~/Mail/work/[a-zA-Z]*     source ~/.config/mutt/muttrc.1
folder-hook ~/Mail/records/[a-zA-Z]*  source ~/.config/mutt/muttrc.2
folder-hook ~/Mail/[a-z]*/Trash   color indicator white  black
# }}}
# SETTINGS {{{
# General
set abort_noattach = ask-yes
set attach_save_dir = "~/Downloads/"
set auto_tag = yes
set collapse_unread = yes
set delete = yes
set mail_check = 60
set mailcap_path = "~/.config/mutt/mailcap"
set markers=no
set mbox_type = Maildir
set pager_context = 15
set pager_index_lines = 7
set pager_stop=yes
set pipe_decode = yes
set postpone=no
set quit = yes
set realname = "Evan Chen"
set simple_search = "~f %s | ~s %s | ~C %s"
set sleep_time = 0
set sort = threads
set sort_aux = last-date-received
set ssl_force_tls = yes
set ssl_starttls = yes
set text_flowed = yes
set use_from = yes
set wait_key = no
set wrap = 78

# Date format
set date_format = "%a %d日%m月"
set index_format = "%3C %[%b%d]%Z%M %-10.10L %?X?%X📌&?%s"
set pager_format = "%4C %Z %[%a %d日%m月%R] %.20n %s%* -- (%P)"
set display_filter="exec sed -r \"s/^Date:\\s*(([F-Wa-u]{3},\\s*)?[[:digit:]]{1,2}\\s+[A-Sa-y]{3}\\s+[[:digit:]]{4}\\s+[[:digit:]]{1,2}:[[:digit:]]{1,2}(:[[:digit:]]{1,2})?\\s+[+-][[:digit:]]{4}).*/date +'Date: %a %d日%m月 %R' -d '\\1'/e\""

# Composition settings
set abort_nosubject = yes
set attribution = "%f於%[%A%d日%m月%R]寫道："
set attribution_locale = "zh_TW.UTF-8"
set autoedit = yes
set edit_headers = yes
set editor = "vim"
set fast_reply = yes
set include = yes
set sig_on_top = yes
set signature = "~/.config/mutt/signature"
set use_from = yes
unset record
# }}}
# SIDEBAR CONFIG {{{
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
# }}}
# KEY BINDINGS {{{
# \043 is hashtag
bind index \043 noop

bind index,pager g noop
macro index,pager gi "<change-folder>=Inbox<enter>" "Go to inbox"
macro index,pager g\043 "<change-folder>=Trash<enter>" "Go to trash"
bind index,pager a group-reply
bind index,pager s view-attachments
macro index,pager z "<pipe-message>nvim -R -c \"set ft=mail\" -<enter>" "View in Vim"
macro index,pager e "<delete-message>$<enter-command>echo \"Archived selection\"<enter>" "Archive"
macro index,pager \043 "<save-message>=Trash<enter><enter><enter-command>echo \"Deleted selection\"<enter>" "Trash"
bind index,pager m noop

# bind escape to untag all
bind index . noop
macro index . "<untag-pattern>.<enter><limit>.<enter>" "Reset view"
bind index - collapse-thread
bind index _ collapse-all
bind index t tag-entry
bind index x tag-thread
macro pager t "<exit><tag-entry>" "Tag entry"
macro pager x "<exit><tag-thread>" "Tag thread"

# change mailbox
macro index,pager mu <change-folder>~/Mail/personal/Inbox/<enter><enter-command>source\ ~/.config/mutt/muttrc.0<enter> "Change to account 0"
macro index,pager m1 <change-folder>~/Mail/work/Inbox/<enter><enter-command>source\ ~/.config/mutt/muttrc.1<enter> "Change to account 1"
macro index,pager m2 <change-folder>~/Mail/records/Inbox/<enter><enter-command>source\ ~/.config/mutt/muttrc.2<enter> "change to account 2"

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
bind generic,pager d half-down
bind generic,pager u half-up

bind index d display-message
bind index gg first-entry
bind index G last-entry
bind index j next-entry
bind index k previous-entry
bind index J next-thread
bind index K previous-thread

bind index,pager c mail
bind index,pager C compose-to-sender
bind index,pager r reply
bind index,pager a group-reply
macro index,pager A "<pipe-message>abook --add-email-quiet<enter>" "Add to contacts"
macro index,pager V <pipe-message>urlscan<enter>

bind generic,index,pager \Cf       next-page
bind generic,index,pager \Cb       previous-page
bind generic,index,pager \Cd       half-down
bind generic,index,pager \Cu       half-up

bind compose D noop
bind compose \043 detach-file
bind compose v view-attach
macro compose <Space> "<first-entry>\
<pipe-entry>python ~/.config/mutt/mutt-markdown.py<enter>\
<attach-file>/tmp/neomutt-alternative.html<enter>\
<toggle-unlink><toggle-disposition>\
<tag-entry><first-entry><tag-entry><group-alternatives>\
<send-message>\
<shell-escape>~/dotfiles/sh-scripts/noisemaker.sh 5<enter>" \
"Compile as markdown and send"

bind attach d noop
bind attach \043 delete-entry
bind attach s save-entry

# on quit also sync
bind index q noop
macro index q "<shell-escape>systemctl start evansync.service --user<enter><quit>"
bind index Q quit

# pipe in nvim
bind index p noop
macro index p "<display-message><view-attachments><first-entry><next-entry><pipe-message>nvim -R -<enter>" "Pipe in NVim"
bind pager p noop
macro pager p "<view-attachments><first-entry><next-entry><pipe-message>nvim -R -<enter>" "Pipe in NVim"
bind attach p noop
macro attach p "<pipe-message>nvim -R -<enter>" "Pipe in NVim"
bind pager z edit-raw-message
# }}}
# COLORS {{{
# Colour definitions when on a mono screen
mono bold      bold
mono underline underline
mono indicator reverse
mono header bold "^(From|Subject|X-Junked-Because|X-Virus-hagbard):"
mono index bold  ~N
mono index bold  ~O
mono index bold  ~F
mono index bold  ~T
mono index bold  ~D
mono body bold   "(http|https|ftp|news|telnet|finger)://[^ \">\t\r\n]*"
mono body bold   "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
mono body bold   "news:[^ \">\t\r\n]*"
mono body bold   "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"

# color hdrdefault black        cyan
color quoted     red          white
color signature  brightblack  white
# color indicator  brightwhite  red
color attachment black        green
color error      red          white
color message    color19         white
color search     brightwhite  magenta
# color status     brightyellow color19
color tree       color64          white
color normal     color19         white
color tilde      green        white
color bold       brightyellow white
color markers    red          white

# Colours for items in the reader
color header white  black "."
color header brightyellow black "^(From|Subject):"
color header red         black "^X-Junked-Because: "

# Colours for items in the index
color index color52     brightyellow  ~N
color index brightblack white         ~O
color index brightwhite magenta       ~F
color index black       cyan          ~T
color index brightwhite black         ~D

# URLs
color body brightcolor28 white "(http|https|ftp|news|telnet|finger)://[^ \">\t\r\n]*"
color body brightcolor28 white "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
color body brightcolor28 white "news:[^ \">\t\r\n]*"

# email addresses
color body brightcolor88  white "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"

# Various smilies and the like
color body brightgreen white "<[Gg]>"                                            # <g>
color body brightgreen white "<[Bb][Gg]>"                                        # <bg>
color body brightgreen white " [;:]-*[)>(<|]"                                    # :-) etc...
color body brightblue  white "(^|[[:space:]])\\*[^[:space:]]+\\*([[:space:]]|$)" # *Bold* text.
color body brightblue  white "(^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)"     # _Underlined_ text.
color body brightblue  white "(^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)"     # /Italic/ text.

# NeoMutt color settings
color index_author magenta       white        '.*'
color index_author brightblack   brightyellow ~N
color index_author black         white        ~O
color index_author brightblack   magenta      ~F
color index_author brightblack   cyan         ~T
color index_author brightmagenta black        ~D
color index_collapsed default brightblue
color index_date      green   black
color index_label     default brightgreen
color index_number    color90 white
color index_size      cyan    white

color sidebar_divider color19 white
# color sidebar_spoolfile color19 white
color sidebar_ordinary black white
color sidebar_flagged black white
color sidebar_new brightcyan white
color sidebar_unread brightblack white
# }}}

# vim: ft=neomuttrc fdm=marker
