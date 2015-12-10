% BibTeX bibliography style `MLA' to conform to the MLA stylesheet
% 3/23/97 minor changes to @inproceedings
% modified on 10/21/95 copied much of the tricks of chicago.bst
%     now need use use chicago.sty when using this bibstyle
% modified on 3/13/94 converted note3 to "comment" field
% Modified from BibTeX standard bibliography style `plain' by Tom Weissert
% BibTeX standard bibliography style `plain'
        % version 0.99a for BibTeX versions 0.99a or later, LaTeX version 2.09.
        % Copyright (C) 1985, all rights reserved.
        % Copying of this file is authorized only if either
        % (1) you make absolutely no changes to your copy, including name, or
        % (2) if you do make changes, you name it something other than
        % btxbst.doc, plain.bst, unsrt.bst, alpha.bst, and abbrv.bst.
        % This restriction helps ensure that all standard styles are identical.
        % The file btxbst.doc has the documentation for this style.
% The following text is the header for chicago.bst:
% "Chicago" BibTeX style, chicago.bst
% ===================================
%
% BibTeX `chicago' style file for BibTeX version 0.99c, LaTeX version 2.09
% Place it in a file called chicago.bst in the BibTeX search path.
% You need to include chicago.sty as a \documentstyle option.
% (Placing it in the same directory as the LaTeX document should also work.)
% This "chicago" style is based on newapa.bst (American Psych. Assoc.)
% found at ymir.claremont.edu.
%
%   Citation format: (author-last-name year)
%             (author-last-name and author-last-name year)
%             (author-last-name, author-last-name, and author-last-name year)
%             (author-last-name et al. year)
%             (author-last-name)
%             author-last-name (year)
%             (author-last-name and author-last-name)
%             (author-last-name et al.)
%             (year) or (year,year)
%             year or year,year
%
%   Reference list ordering: alphabetical by author or whatever passes
%    for author in the absence of one.
%
% This BibTeX style has support for abbreviated author lists and for
%    year-only citations.  This is done by having the citations
%    actually look like
%
%    \citeauthoryear{full-author-info}{abbrev-author-info}{year}
%
% The LaTeX style has to have the following (or similar)
%
%     \let\@internalcite\cite
%     \def\fullcite{\def\citeauthoryear##1##2##3{##1, ##3}\@internalcite}
%     \def\fullciteA{\def\citeauthoryear##1##2##3{##1}\@internalcite}
%     \def\shortcite{\def\citeauthoryear##1##2##3{##2, ##3}\@internalcite}
%     \def\shortciteA{\def\citeauthoryear##1##2##3{##2}\@internalcite}
%     \def\citeyear{\def\citeauthoryear##1##2##3{##3}\@internalcite}
%
% These TeX macro definitions are found in chicago.sty. Additional
% commands to manipulate different components of a citation can be defined
% so that, for example, you can list author's names without parentheses
% if using a citation as a noun or object in a sentence.
%
% This file was originally copied from newapa.bst at ymir.claremont.edu.
%
% Features of chicago.bst:
% =======================
%
% - full names used in citations, but abbreviated citations are available
%   (see above)
% - if an entry has a "month", then the month and year are also printed
%   as part of that bibitem.
% - all conjunctions use "and" instead of "\&"
% - major modification from Chicago Manual of Style (13th ed.) is that
%   only the first author in a reference appears last name first-
%   additional authors appear as J. Q. Public.
% - pages are listed as "pp. xx-xx" in all entry types except
%   article entries.
% - book, inbook, and manual use "location: publisher" (or organization)
%   for address and publisher. All other types list publishers separately.
% - "pp." are used to identify page numbers for all entry types except
%   articles.
% - organization is used as a citation label if neither author nor editor
%   is present (for manuals).
% - "et al." is used for long author and editor lists, or when "others"
%   is used.
%
% Modifications and bug fixes from newapa.bst:
% ===========================================
%
%   - added month, year to bib entries if month is present
%   - fixed bug with In proceedings, added necessary comma after title
%   - all conjunctions changed to "and" from "\&"
%   - fixed bug with author labels in my.full.label: "et al." now is
%        generated when "others" is an author name
%   - major modification from Chicago Manual of Style (13th ed.) is that
%     only the first author in a reference appears last name first-
%     additional authors appear as J. Q. Public.
%   - pages are listed as "pp. xx-xx" in all entry types except
%     article entries. Unnecessary (IMHO) "()" around page numbers
%     were removed, and page numbers now don't end with a period.
%   - created chicago.sty for use with this bibstyle (required).
%   - fixed bugs in FUNCTION {format.vol.num.pages} for missing volume,
%     number, and /or pages. Renamed to format.jour.vol.
%   - fixed bug in formatting booktitles: additional period an error if
%     book has a volume.
%   - fixed bug: editors usually given redundant period before next clause
%     (format.editors.dot) removed.
%   - added label support for organizations, if both author and editor
%     are missing (from alpha.bst). If organization is too long, then
%     the key field is used for abbreviated citations.
%   - In proceedings or books of several volumes, no comma was written
%     between the "Volume x" and the page numbers (this was intentional
%     in newapa.bst). Fixed.
%   - Some journals may not have volumes/numbers, only month/year (eg.
%     IEEE Computer). Fixed bug in article style that assumed volume/number
%     was always present.
%
% Original documentation for newapa.sty:
% =====================================
%
% This version was made by modifying the master file made by
% Oren Patashnik (PATASHNIK@SCORE.STANFORD.EDU), and the 'named' BibTeX
% style of Peter F. Patel-Schneider.
%
% Copyright (C) 1985, all rights reserved.
% Copying of this file is authorized only if either
% (1) you make absolutely no changes to your copy, including name, or
% (2) if you do make changes, you name it something other than 'newapa.bst'.
% There are undoubtably bugs in this style.  If you make bug fixes,
% improvements, etc.  please let me know.  My e-mail address is:
%    spencer@cgrg.ohio.state.edu or 71160.3141@compuserve.com
%
% This style was made from 'plain.bst', 'named.bst', and 'apalike.bst',
% with lots of tweaking to make it look like APA style, along with tips
% from Young Ryu and Brian Reiser's modifications of 'apalike.bst'.
%
%
ENTRY
  { address
    author
    booktitle
    chapter
    comment
    edition
    editor
    howpublished
    institution
    journal
    key
    month
    note
    number
    organization
    pages
    publisher
    school
    series
    title
    type
    volume
    year
  }
  {}
% copied labels from Chicago
  { label.year extra.label sort.year sort.label }
% added "post.title" to integers
% just.space to integers
INTEGERS { output.state before.all mid.sentence after.sentence after.block
           post.title}
% added #4 below
FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
  #4 'post.title :=
}
% added u from chicago:
STRINGS { s t u }
% added outer if loop
FUNCTION {output.nonnull}
{ 's :=
   output.state post.title =
      { " " * write$
        newline$
        "\newblock " write$
        mid.sentence 'output.state :=
      }
      { output.state mid.sentence =
          { ", " * write$ }
          { output.state after.block =
              { add.period$ write$
                newline$
                "\newblock " write$
              }
              { output.state before.all =
                  'write$
                  { add.period$ " " * write$ }
                if$
              }
            if$
            mid.sentence 'output.state :=
          }
       if$
      }
    if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}
FUNCTION {putnodot}
{post.title 'output.state :=}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}
% removed original bibitem from here
% added the chicago version later in file
%FUNCTION {output.bibitem}
%{ newline$
%  "\bibitem{" write$
%  cite$ write$
%  "}" write$
%  newline$
%  ""
%  before.all 'output.state :=
%}
%
FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}
FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}
FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
        'skip$
        { after.sentence 'output.state := }
      if$
    }
  if$
}
FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}
FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}
FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}
FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}
FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}
FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}
FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}
FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}
FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "\emph{" swap$ * "}" * }
  if$
}
% moved format.date function to here for sort
FUNCTION {format.date}
{ year empty$
    { month empty$
        { "" }
        { "there's a month but no year in " cite$ * warning$
          month
        }
      if$
    }
    { month empty$
        'year
        { month " " * year * }
      if$
    }
  if$
}

INTEGERS { nameptr namesleft numnames }
%
% This new function is a modified version of the old function
% the old function has been renamed format.names.alt below
% added if nameptr=1 option and changed format for first
%  author to last name first.
FUNCTION {format.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 =
        {  s nameptr "{ll}{, ff}{vv~}{,jj}" format.name$ 't := }
        {  s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't := }
      if$
      nameptr #1 >
        { namesleft #1 >
            { ", " * t * }
            { numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

% this is the original format.names function
FUNCTION {format.names.alt}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * t * }
            { numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}
% copied the following two from chicago
FUNCTION {my.full.label}
{ 's :=
  #1 'nameptr :=               % nameptr = 1;
  s num.names$ 'numnames :=    % numnames = num.name$(s);
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{vv~}{ll}" format.name$ 't :=  % get the next name
      nameptr #1 >
        { namesleft #1 >
              { ", " * t * }
              { numnames #2 >
                  { "," * }
                  'skip$
                if$
                t "others" =
                    { " et~al." * }
                    { " and " * t * } % from Chicago Manual of Style
                  if$
               }
               if$
             }
            't
        if$
        nameptr #1 + 'nameptr :=          % nameptr += 1;
        namesleft #1 - 'namesleft :=      % namesleft =- 1;
    }
  while$
}
FUNCTION {format.names.fml}
%
% Format names in "familiar" format, with first initial followed by
% last name. Like format.names, ALL names are formatted.
%
{ 's :=
  #1 'nameptr :=               % nameptr = 1;
  s num.names$ 'numnames :=    % numnames = num.name$(s);
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{f.~}{vv~}{ll}{, jj}" format.name$ 't :=
      nameptr #1 >
        { namesleft #1 >
              { ", " * t * }
               { numnames #2 >
                    { "," * }
                    'skip$
                  if$
                  t "others" =
                        { " et~al." * }
                        { " and " * t * }
%                       { " \& " * t * }
                      if$
                }
               if$
             }
            't
        if$
        nameptr #1 + 'nameptr :=          % nameptr += 1;
        namesleft #1 - 'namesleft :=      % namesleft =- 1;
    }
  while$
}
FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.names }
  if$
}
FUNCTION {format.key}
{ empty$
    { key field.or.null }
    { "" }
  if$
}
FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.names
      editor num.names$ #1 >
        { ", editors" * }
        { ", editor" * }
      if$
    }
  if$
}
% from chicago:
% Format editor names for use in the "in" types: inbook, incollection,
% inproceedings: first initial, then last names. When editors are the
% LABEL for an entry, then format.editor is used which lists editors
% by last name first.
%
FUNCTION {format.editors.fml}
{ editor empty$
    { "" }
    { editor format.names.fml
      editor num.names$ #1 >
    { " (Eds.)" * }
    { " (Ed.)" * }
      if$
    }
  if$
}
%
% this new function is a modified version of the original above
% with the additional use of format.names.alt when the editor
% is not the first name in the entry.
FUNCTION {format.editors.alt}
{ editor empty$
    { "" }
    { "Ed. " editor format.names.alt
      editor num.names$ #1 >
        {  * }
        {  * }
      if$
    }
  if$
}

% removed change.case$ operation on title
FUNCTION {format.title}
{ title empty$
    { "" }
    { title }
%    { title "t" change.case$ }
  if$
}
% new function copied from above added quote marks and
% period inside quotes for articles
FUNCTION {format.title.article}
{ title empty$
    { "" }
    { "``" title * ".''" * }
  if$
}
% new function copied from above added quote marks and
% period inside quotes for chapter title in type INBOOK
FUNCTION {format.chapter.inbook}
{ chapter empty$
    { "" }
    { "``" chapter * ".''" * }
  if$
}


FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { t #1 #2 substring$ "--" = not
            { "--" *
              t #2 global.max$ substring$ 't :=
            }
            {   { t #1 #1 substring$ "-" = }
                { "-" *
                  t #2 global.max$ substring$ 't :=
                }
              while$
            }
          if$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}
% moved format.data function from here
FUNCTION {format.btitle}
{ title emphasize }

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}
FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}
FUNCTION {format.bvolume}
{ volume empty$
    { series empty$
        { "" }
        { series }
      if$
    }
    { "Volume" volume tie.or.space.connect
      series empty$
        {" " * }
        { " of " * series * }
      if$
      "volume and number" number either.or.check
    }
  if$
}
FUNCTION {format.number.series}
{ volume empty$
    { number empty$
        { series field.or.null }
        { output.state mid.sentence =
            { "number" }
            { "Number" }
          if$
          number tie.or.space.connect
          series empty$
            { "there's a number but no series in " cite$ * warning$ }
            { " in " * series * }
          if$
        }
      if$
    }
    { "" }
  if$
}
FUNCTION {format.edition}
{ edition empty$
    { "" }
    { output.state mid.sentence =
        { edition "l" change.case$ " edition" * }
        { edition "t" change.case$ " edition" * }
      if$
    }
  if$
}
INTEGERS { multiresult }
FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}
FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
        { " " pages n.dashify tie.or.space.connect }
        { " " pages tie.or.space.connect }
      if$
    }
  if$
}
% added the if year empty block to below
FUNCTION {format.vol.num.pages}
{ volume field.or.null
  year empty$
    { month empty$
        { "" *}
        { "there's a month but no year in " cite$ * warning$ }
      if$
    }
    { month empty$
        { " (" year * ")" * * }
        { " (" month * " " * year * ")" * * }
      if$
    }
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
        { pop$ format.pages }
        { ": " * pages n.dashify * }
      if$
    }
  if$
}

FUNCTION {format.vol.num.pages.mag}
{ volume field.or.null
  year empty$
    { month empty$
        { "" *}
        { "there's a month but no year in " cite$ * warning$ }
      if$
    }
    { month empty$
        { " " year " " * * }
        { " " month * ". " * year * " " * * }
      if$
    }
  if$
  pages empty$
    {'skip$}
    { duplicate$ empty$
        { pop$ format.pages }
        { ": " * pages n.dashify * }
      if$
    }
  if$
}
FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
        { "chapter" }
        { type "l" change.case$ }
      if$
      chapter tie.or.space.connect
      pages empty$
        'skip$
        { ", " * format.pages *  }
      if$
    }
  if$
}
% modified to use format.editors.alt instead of format.editors
FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { editor empty$
        { " " booktitle emphasize * ". " * }
        { " "  booktitle emphasize * ". " * format.editors.alt * }
      if$
    }
  if$
}
FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}
FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}
FUNCTION {format.tr.number}
{ type empty$
    { "Technical Report" }
    'type
  if$
  number empty$
    { "t" change.case$ }
    { number tie.or.space.connect }
  if$
}
FUNCTION {format.article.crossref}
{ "See"
  "\citeN{" * crossref * "}" *
}
FUNCTION {format.crossref.editor}
{ editor #1 "{vv~}{ll}" format.name$
  editor num.names$ duplicate$
  #2 >
    { pop$ " et~al." * }
    { #2 <
        'skip$
        { editor #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
            { " et~al." * }
            { " and " * editor #2 "{vv~}{ll}" format.name$ * }
          if$
        }
      if$
    }
  if$
}
FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
      "In "
    }
    { "Volume" volume tie.or.space.connect
      " of " *
    }
  if$
  editor empty$
    editor field.or.null author field.or.null =
    or
    { key empty$
        { series empty$
            { "need editor, key, or series for " cite$ * " to crossref " *
              crossref * warning$
              "" *
            }
            { "\emph{" * series * "}" * }
          if$
        }
        { key * }
      if$
    }
    { format.crossref.editor * }
  if$
  " \citeN{" * crossref * "}" *
}
FUNCTION {format.incoll.inproc.crossref}
{"See" " \citeN{" * crossref * "}" * }
%
% created this function
FUNCTION {format.publishing}
{ address empty$
      {publisher}
      {address ": " * publisher * }
  if$
}
%
% Stole the following label generation
% routines for chicago-like labels in
% the bbl file:
FUNCTION {format.lab.names}
{ 's :=
  s num.names$ 'numnames :=
  numnames #2 >    % change number to number of others allowed before
         % forcing "et al".
    { s #1 "{vv~}{ll}" format.name$ " et~al." * }
    {
      numnames #1 - 'namesleft :=
      #2 'nameptr :=
      s #1 "{vv~}{ll}" format.name$
   { namesleft #0 > }
   { nameptr numnames =
       { s nameptr "{ff }{vv }{ll}{ jj}" format.name$ "others" =
      { " et~al." * }
      { " and " * s nameptr "{vv~}{ll}" format.name$ * }
         if$
       }
       { ", " * s nameptr "{vv~}{ll}" format.name$ * }
     if$
     nameptr #1 + 'nameptr :=
     namesleft #1 - 'namesleft :=
   }
      while$
    }
  if$
}
FUNCTION {author.key.label}
{ author empty$
    { key empty$
          { "no key, author in " cite$ * warning$
            cite$ #1 #3 substring$ }
         'key
      if$
    }
    { author format.lab.names }
  if$
}
FUNCTION {editor.key.label}
{ editor empty$
    { key empty$
          { "no key, editor in " cite$ * warning$
            cite$ #1 #3 substring$ }
          'key
        if$
     }
     { editor format.lab.names }
  if$
}
FUNCTION {author.key.organization.label}
%
% added - gnp. Provide label formatting by organization if author is null.
%
{ author empty$
    { organization empty$
   { key empty$
       { "no key, author or organization in " cite$ * warning$
              cite$ #1 #3 substring$ }
       'key
     if$
   }
        { organization }
      if$
    }
    { author format.lab.names }
  if$
}
FUNCTION {editor.key.organization.label}
%
% added - gnp. Provide label formatting by organization if editor is null.
%
{ editor empty$
    { organization empty$
   { key empty$
       { "no key, editor or organization in " cite$ * warning$
              cite$ #1 #3 substring$ }
       'key
     if$
   }
        { organization }
      if$
    }
    { editor format.lab.names }
  if$
}
FUNCTION {author.editor.key.label}
{ author empty$
    { editor empty$
          { key empty$
               { "no key, author, or editor in " cite$ * warning$
                 cite$ #1 #3 substring$ }
             'key
           if$
         }
          { editor format.lab.names }
      if$
    }
    { author format.lab.names }
  if$
}
FUNCTION {calc.label}
%
% Changed - GNP. See also author.organization.sort, editor.organization.sort
% Form label for BibTeX entry. The classification of which fields are used
% for which type of entry (book, inbook, etc.) are taken from alpha.bst.
% The change here from newapa is to also include organization as a
% citation label if author or editor is missing.
%
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.key.label
    { type$ "proceedings" =
   'editor.key.organization.label
   { type$ "manual" =
       'author.key.organization.label
       'author.key.label
     if$
   }
      if$
    }
  if$
  author empty$  % generate the full label citation information.
    { editor empty$
        { organization empty$
           { "no author, editor, or organization in " cite$ * warning$
             "??" }
           { organization }
           if$
        }
        { editor my.full.label }
        if$
    }
    { author my.full.label }
  if$
% leave label on the stack, to be popped when required.
  "}{" * swap$ * "}{" *
%  year field.or.null purify$ #-1 #4 substring$ *
%
% save the year for sort processing afterwards (adding a, b, c, etc.)
%
  year field.or.null purify$ #-1 #4 substring$
  'label.year :=
}
FUNCTION {output.bibitem}
{ newline$
  "\bibitem[\protect\citeauthoryear{" write$
  calc.label write$
  sort.year write$
  "}]{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}
%
% changes to article:
% format.title to format.title.article
FUNCTION {article}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output % from chicago
  new.block
  format.title.article
  "title" output.check
  putnodot
  note empty$
    {}
    { note output
      new.block
    }
  if$
% Added from chicago:
    crossref missing$
    { journal emphasize "journal" output.check
      putnodot
    }
    { format.article.crossref output.nonnull
      format.pages output
    }
  if$
  format.vol.num.pages output
  new.block
  comment output
  fin.entry
}
FUNCTION {book}
{ output.bibitem
  author empty$
    { format.editors "editor" output.check
      new.block
      crossref missing$
         { format.btitle "title" output.check }
         { format.book.crossref output.nonnull }
      if$
    }
    { format.authors output.nonnull
      new.block
      crossref missing$
        { format.btitle "title" output.check }
        { format.book.crossref output.nonnull }
      if$
      new.block
      format.editors.alt output
    }
  if$
  new.block
  note output
  new.block
  format.edition output
  new.block
  format.bvolume output
  new.block
  format.publishing "address and publisher" output.check
  format.date "year" output.check
  new.block
  comment output
  fin.entry
}
FUNCTION {booklet}
{ output.bibitem
  format.authors output
  author format.key output %from chicago
  new.block
  format.title "title" output.check
  new.block
  howpublished address new.block.checkb
  howpublished output
  address output
  format.date output
  note output
  new.block
  comment output
  fin.entry
}
FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  new.block
  format.chapter.inbook output
  putnodot
  format.btitle
  "title" output.check
  crossref missing$
    { format.edition output
      new.block
      format.bvolume output
      new.block
      format.publishing "address and publisher" output.check
    }
    { format.chapter.pages "chapter and pages" output.check
      new.block
      format.book.crossref output.nonnull
    }
  if$
  new.block
  note output
  format.date "year" output.check
  comment output
  new.block
  format.pages output
  fin.entry
}
FUNCTION {incollection}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output %from chicago
  new.block
  format.title.article
  "title" output.check
  putnodot
  crossref missing$
    {format.in.ed.booktitle
     "booktitle" output.check
     new.block
     format.edition output
     new.block
     note output
     format.bvolume output
     new.block
     format.publishing "address and publisher" output.check
     format.date output
     new.block
     format.chapter.pages output
   }
   { format.incoll.inproc.crossref
     output.nonnull
     format.date output
     new.block
     format.chapter.pages output
   }
  if$
  new.block
  comment output
  fin.entry
}
FUNCTION {inproceedings}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output %chicago
  new.block
  format.title.article
  "title" output.check
  putnodot
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
%      organization missing$
%        {}
%        {" Proceedings of " organization * output}
%      if$
      new.block
      putnodot
      note output
      format.publishing "address and publisher" output.check
    }
    { format.incoll.inproc.crossref output.nonnull}
  if$
  format.date "year" output.check
  format.pages output
  new.block
  comment output
  fin.entry
}
FUNCTION {conference} { inproceedings }
FUNCTION {manual}
{ output.bibitem
  author empty$
    { organization empty$
        'skip$
        { organization output.nonnull
          address output
        }
      if$
    }
    { format.authors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  author empty$
    { organization empty$
        { address new.block.checka
          address output
        }
        'skip$
      if$
    }
    { organization address new.block.checkb
      organization output
      address output
    }
  if$
  format.edition output
  format.date output
  new.block
  note output
  fin.entry
}

FUNCTION {mastersthesis}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output
  new.block
  format.title
  "title" output.check
  new.block
  "Master's thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check
  new.block
  note output
  fin.entry
}

FUNCTION {misc}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output
  new.block
  format.title.article
  "title" output.check
  putnodot
  journal emphasize
  "journal" output.check
  putnodot
  format.vol.num.pages.mag output
  new.block
  note output
  new.block
  comment output
  fin.entry
}
FUNCTION {phdthesis}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output
  new.block
  format.btitle
  "title" output.check
  new.block
  "PhD thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check
  new.block
  note output
  fin.entry
}
FUNCTION {proceedings}
{ output.bibitem
  editor empty$
    { organization output
      organization format.key output }
    { format.editors output.nonnull }
  if$
  new.block
  format.btitle
  "title" output.check
  note output
  format.publishing
  "address and publisher" output.check
  format.date
  "year" output.check
  format.bvolume output
  format.number.series output
  new.block
  comment output
  fin.entry
}
FUNCTION {techreport}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output
  new.block
  format.title
  "title" output.check
  new.block
  format.tr.number output.nonnull
  institution
  "institution" output.check
  address output
  format.date
  "year" output.check
  new.block
  note output
  fin.entry
}
FUNCTION {unpublished}
{ output.bibitem
  format.authors
  "author" output.check
  author format.key output
  new.block
  format.title
  "title" output.check
  new.block
  note "note" output.check
  format.date output
  new.block
  comment output
  fin.entry
}
FUNCTION {default.type} { book }
MACRO {jan} {"January"}
MACRO {feb} {"February"}
MACRO {mar} {"March"}
MACRO {apr} {"April"}
MACRO {may} {"May"}
MACRO {jun} {"June"}
MACRO {jul} {"July"}
MACRO {aug} {"August"}
MACRO {sep} {"September"}
MACRO {oct} {"October"}
MACRO {nov} {"November"}
MACRO {dec} {"December"}
READ
FUNCTION {sortify}
{ purify$
  "l" change.case$
}
INTEGERS { len }
FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
        { "   " * }
        'skip$
      if$
      s nameptr "{vv{ } }{ll{ }}{  ff{ }}{  jj{ }}" format.name$ 't :=
      nameptr numnames = t "others" = and
        { "et al" * }
        { t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}
FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}
FUNCTION {author.sort}
{ author empty$
    { key empty$
        { "to sort, need author or key in " cite$ * warning$
          "" }
        { key sortify }
      if$
    }
    { author sort.format.names }
  if$
}
FUNCTION {editor.sort}
{ editor empty$
    { key empty$
         { "to sort, need editor or key in " cite$ * warning$
           ""
         }
         { key sortify }
      if$
    }
    { editor sort.format.names }
  if$
}
FUNCTION {author.editor.sort}
{ author empty$
    { "missing author in " cite$ * warning$
      editor empty$
        { key empty$
            { "to sort, need author, editor, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}
FUNCTION {author.organization.sort}
{ author empty$
    { organization empty$
        { key empty$
            { "to sort, need author, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { author sort.format.names }
  if$
}
FUNCTION {editor.organization.sort}
{ editor empty$
    { organization empty$
        { key empty$
            { "to sort, need editor, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { editor sort.format.names }
  if$
}
FUNCTION {presort}
% added first 4 lines from chicago for labels:
{ calc.label sortify % recalculate bibitem label
  year field.or.null purify$ #-1 #4 substring$ * % add year
  "    "
  *
  type$ "book" =
  type$ "inbook" =
  or
    'author.editor.sort
    { type$ "proceedings" =
        'editor.organization.sort
        { type$ "manual" =
            'author.organization.sort
            'author.sort
          if$
        }
      if$
    }
  if$
  #1 entry.max$ substring$        % added for newapa
  'sort.label :=                  % added for newapa
  sort.label                      % added for newapa
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}
ITERATE {presort}
% replace entire sort procedure with the one from chicago:
SORT             % by label, year, author/editor, title
STRINGS { last.label next.extra }
INTEGERS { last.extra.num }
FUNCTION {initialize.extra.label.stuff}
{ #0 int.to.chr$ 'last.label :=
  "" 'next.extra :=
  #0 'last.extra.num :=
}
FUNCTION {forward.pass}
%
% Pass through all entries, comparing current entry to last one.
% Need to concatenate year to the stack (done by calc.label) to determine
% if two entries are the same (see presort)
%
{ last.label
  calc.label year field.or.null purify$ #-1 #4 substring$ * % add year
  #1 entry.max$ substring$ =     % are they equal?
     { last.extra.num #1 + 'last.extra.num :=
       last.extra.num int.to.chr$ 'extra.label :=
     }
     { "a" chr.to.int$ 'last.extra.num :=
       "" 'extra.label :=
       calc.label year field.or.null purify$ #-1 #4 substring$ * % add year
       #1 entry.max$ substring$ 'last.label := % assign to last.label
     }
  if$
}
FUNCTION {reverse.pass}
{ next.extra "b" =
    { "a" 'extra.label := }
     'skip$
  if$
  label.year extra.label * 'sort.year :=
  extra.label 'next.extra :=
}
EXECUTE {initialize.extra.label.stuff}
ITERATE {forward.pass}
REVERSE {reverse.pass}
FUNCTION {bib.sort.order}
{ sort.label
  "    "
  *
  year field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}
ITERATE {bib.sort.order}
SORT             % by sort.label, year, title --- giving final bib. order.

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{}" write$ newline$
}

EXECUTE {begin.bib}
EXECUTE {init.state.consts}
ITERATE {call.type$}
FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}
EXECUTE {end.bib}
