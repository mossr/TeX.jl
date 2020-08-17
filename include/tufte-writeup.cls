\ProvidesClass{tufte-writeup}
\RequirePackage{luatex85}

\LoadClass[justified,nobib]{tufte-handout}
\ProcessOptions\relax

\expandafter\def\csname PY@tok@err\endcsname{}

\geometry{
	paperheight=11in,
	top=3pc,
	bottom=6pc,
	paperwidth=8.5in,
	inner=3pc,
	outer=3pc,
	marginparsep=1pc,
	marginparwidth=10pc,
	includehead,
	includemp
}
\setcounter{secnumdepth}{2}
\usepackage{titlecaps}
\usepackage{suffix}
\Addlcwords{et de la le a an the at is by for in of on to up and as but it or nor all with for from to about across against along among before below given into like near next off on out over past per round than toward unlike until unto upon via within}

\usepackage[american]{babel} % to fix http://tex.stackexchange.com/questions/315532/bblmainlanguage-error-in-biblatex
\usepackage{fontspec}
\usepackage{realscripts}
\usepackage{amsmath,bm,amssymb}
\usepackage{amsthm}
\usepackage{bbm}
\usepackage{booktabs}
\setfloatalignment{t}
\usepackage{comment}
\usepackage{pgfplots}
\usepackage{datetime2}
\usepackage[group-digits=integer,group-minimum-digits=4,group-separator={,},detect-all]{siunitx}
\usepackage[noend]{algpseudocode}
\usepackage{enumitem}
\newcommand{\bulletdescriptionlabel}[1]{\itshape #1.~}
\setlist[description]{before=\let\makelabel\bulletdescriptionlabel}

\setmonofont{DejaVu Sans Mono}[Scale=MatchLowercase]
\usepackage{newunicodechar}
\newfontface{\calligraphic}{Latin Modern Math}[Scale=0.85]
\newunicodechar{𝒪}{{\normalfont\calligraphic 𝒪}}
\newunicodechar{ℬ}{{\normalfont\calligraphic ℬ}}
\newunicodechar{𝒜}{{\normalfont\calligraphic 𝒜}}
\newunicodechar{𝒟}{{\normalfont\calligraphic 𝒟}}
\newunicodechar{𝒮}{{\normalfont\calligraphic 𝒮}}
\newunicodechar{𝔼}{{\normalfont\calligraphic 𝔼}}
\newunicodechar{⋮}{{\normalfont ⋮}}
\newunicodechar{φ}{ϕ} % switched
\newunicodechar{ϕ}{φ} % switched
\newunicodechar{𝐰}{$\mathbf{w}$}
\newunicodechar{𝐯}{$\mathbf{v}$}
\newunicodechar{𝐕}{$\mathbf{V}$}
\newunicodechar{𝐡}{$\mathbf{h}$}
\newunicodechar{𝐠}{$\mathbf{g}$}
\newunicodechar{𝚺}{{\normalfont\calligraphic 𝚺}}
\newunicodechar{𝕀}{$\mathbb{I}$}
\newunicodechar{ℯ}{{\normalfont\calligraphic ℯ}}


\input{arrows_and_braces}


\usepackage[usefamily={jl,julia}]{pythontex}

\usepackage{microtype}

\fvset{baselinestretch=0.8}

\newfontfeature{Microtype}{protrusion=default;expansion=default;}

\renewcommand\allcapsspacing[1]{{\addfontfeature{LetterSpace=15}#1}}
\renewcommand\smallcapsspacing[1]{{\addfontfeature{LetterSpace=5}#1}} % tighter smallcaps spacing (was 10)

\newcommand{\todo}[1]{\textbf{\textcolor{magenta}{#1}}}
\newcommand{\needcite}{\todo{cite}}

\newcommand{\true}{\text{true}}
\newcommand{\false}{\text{false}}
\newcommand{\transpose}{\top}


\usepackage{mathtools}
\DeclarePairedDelimiter{\paren}{\lparen}{\rparen}
\DeclarePairedDelimiter{\brock}{\lbrack}{\rbrack}
\DeclarePairedDelimiter{\curly}{\{}{\}}
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
\DeclarePairedDelimiter{\abs}{\lvert}{\rvert}
\DeclarePairedDelimiter{\anglebrackets}{\langle}{\rangle}
\DeclarePairedDelimiter{\ceil}{\lceil}{\rceil}
\DeclarePairedDelimiter{\floor}{\lfloor}{\rfloor}

\newcommand{\minimize}{\operatornamewithlimits{minimize}}
\newcommand{\maximize}{\operatornamewithlimits{maximize}}
\newcommand{\supremum}{\operatornamewithlimits{supremum}}
\newcommand{\argmin}{\operatornamewithlimits{arg\,min}}
\newcommand{\argmax}{\operatornamewithlimits{arg\,max}}
\newcommand{\subjectto}{\operatorname{subject~to}}
\newcommand{\for}{\text{for} \;}
\newcommand{\gaussian}[2]{\mathcal{N}(#1, #2)}
\DeclareMathOperator{\sign}{sign}
\DeclareMathOperator{\Real}{\text{Re}}
\DeclareMathOperator{\Imag}{\text{Im}}
\DeclareMathOperator{\nil}{\textsc{nil}}
\DeclareMathOperator{\Expectation}{\mathbb{E}}
\DeclareMathOperator{\Variance}{\mathrm{Var}}
\DeclareMathOperator{\Normal}{\mathcal{N}}
\DeclareMathOperator{\Uniform}{\mathcal{U}}
\DeclareMathOperator{\atantwo}{atan2}
\DeclareMathOperator{\modOne}{mod_1}

% remove empty lines from juliaconsole
% from: https://github.com/gpoore/pythontex/issues/98#issuecomment-318078264
\makeatletter
\AtBeginEnvironment{juliaconsole}{%
	\def\FV@@PreProcessLine{%
		\expandafter\ifstrempty\expandafter{\FV@Line}{}{%
			\FV@StepLineNo
			\FV@Gobble
			\expandafter\FV@ProcessLine\expandafter{\FV@Line}}}%
}
\makeatother

% Handle the Example and Algorithm floats
\usepackage{mdframed}
\definecolor{shadecolor}{rgb}{1,0.8,0.3}
\newcounter{example}[section]
\newcommand\examplename{Example}
\newcommand\listexamplename{List of Examples}
\makeatletter
\newcommand\listofexamples{%
	\ifthenelse{\equal{\@tufte@class}{book}}%
	{\section*{\listexamplename}}%
	{\section*{\listexamplename}}%
	%  \begin{fullwidth}%
	\@starttoc{loe}%
	%  \end{fullwidth}%
}
\renewcommand\theexample
{\ifnum \c@section>\z@ \thesection.\fi \@arabic\c@example}
\def\fps@example{tbp}
\def\ftype@example{1}
\def\ext@example{loe}
\def\fnum@example{\examplename\nobreakspace\theexample}
\newenvironment{example}[1][htbp]
{\begin{@tufte@float}[#1]{example}{}
		\begin{mdframed}[backgroundcolor=black!5,rightline=false,leftline=false]\setlength{\parindent}{1.0pc}\ignorespaces}
		{\end{mdframed}\end{@tufte@float}}
\makeatother
\newcounter{algorithm}[section]
\newcommand\algorithmname{Algorithm}
\newcommand\listalgorithmname{List of Algorithms}
\makeatletter
\newcommand\listofalgorithms{%
	\ifthenelse{\equal{\@tufte@class}{book}}%
	{\section*{\listalgorithmname}}%
	{\section*{\listalgorithmname}}%
	%  \begin{fullwidth}%
	\@starttoc{loa}%
	%  \end{fullwidth}%
}
\renewcommand\thealgorithm
{\ifnum \c@section>\z@ \thesection.\fi \@arabic\c@algorithm}
\def\fps@algorithm{tbp}
\def\ftype@algorithm{1}
\def\ext@algorithm{loa}
\def\fnum@algorithm{\algorithmname\nobreakspace\thealgorithm}
\newenvironment{algorithm}[1][htbp]
	{\begin{mdframed}[backgroundcolor=black!5,rightline=false,leftline=false]}
	{\end{mdframed}}
\makeatother

%\makeatletter
%\titleformat{\section}%
%[hang]% shape
%{}% format applied to label+text
%	{\itshape\huge\thesection}% label
%	{1em}% horizontal separation between label and title body
%	{\huge\rmfamily\itshape}% before the title body
%
%\ifthenelse{\boolean{@tufte@toc}}{%
%	\titlecontents{section}%
%	[0em] % distance from left margin
%	{\vspace{\baselineskip}\begin{fullwidth}\LARGE\rmfamily\itshape} % above (global formatting of entry)
%		{\hspace*{0em}\contentslabel{0em}\hspace*{0.5in}} % before w/label (label = ``2'')
%		{\hspace*{0em}} % before w/o label
%		{\rmfamily\upshape\qquad\thecontentspage} % filler + page (leaders and page num)
%		[\end{fullwidth}] % after
%	\titlecontents{section}% FIXME
%	[0em] % distance from left margin
%	{\vspace{0\baselineskip}\begin{fullwidth}\Large\rmfamily\itshape} % above (global formatting of entry)
%		{\hspace*{0.5in}\contentslabel{0.5in}} % before w/label (label = ``2.6'')
%		{\hspace*{0.5in}} % before w/o label
%		{\rmfamily\upshape\qquad\thecontentspage} % filler + page (leaders and page num)
%		[\end{fullwidth}] % after
%}{}\makeatother

\usepackage[style=ieee,backend=bibtex,mincitenames=1,doi=false,url=false,isbn=false]{biblatex}

\usepackage[noabbrev]{cleveref}
\crefname{algorithm}{algorithm}{algorithms}

\theoremstyle{definition}
\newtheorem{thm}{Theorem}[section]
\newtheorem{question}[thm]{Exercise}
\newenvironment{solution}{\noindent\textit{Solution:}}{}

% Change Figure X: to Figure X.
\makeatletter
\long\def\@caption#1[#2]#3{%
	\par%
	\addcontentsline{\csname ext@#1\endcsname}{#1}%
	{\protect\numberline{\csname the#1\endcsname}{\ignorespaces #2}}%
	\begingroup%
	\@parboxrestore%
	\if@minipage%
	\@setminipage%
	\fi%
	\@tufte@caption@font\@tufte@caption@justification%
	\noindent\csname fnum@#1\endcsname. \ignorespaces#3\par%
	%\@makecaption{\csname fnum@#1\endcsname}{\ignorespaces #3}\par
	\endgroup}
\makeatother

\makeatletter
% BASED ON JAIR TEMPLATE
\newlength\aftertitskip     \newlength\beforetitskip
\newlength\interauthorskip  \newlength\aftermaketitskip
\setlength\aftertitskip{0.1in plus 0.2in minus 0.2in}
\setlength\beforetitskip{0.05in plus 0.08in minus 0.08in}
\setlength\interauthorskip{0.08in plus 0.1in minus 0.1in}
\setlength\aftermaketitskip{0.2in plus 0.1in minus 0.1in}
\def\maketitle{\par
	\begingroup
	\def\thefootnote{\fnsymbol{footnote}}
	\def\@makefnmark{\hbox to 0pt{$^{\@thefnmark}$\hss}}
	\@maketitle \@thanks
	\endgroup
	\setcounter{footnote}{0}
	\let\maketitle\relax \let\@maketitle\relax
	\gdef\@thanks{}\gdef\@author{}\gdef\@title{}\let\thanks\relax}
\def\@startauthor{\noindent \normalsize\bf}
\def\@endauthor{}
\def\@maketitle{\vbox{\hsize\textwidth
		\linewidth\hsize \vskip \beforetitskip
		{\noindent\LARGE\bfseries\itshape \@title \par} \vskip \aftertitskip
		{\def\and{\unskip\enspace{\rm and}\enspace}%
			\def\addr{\small\it}%
			\def\email{\hfill\small\sc}%
			\def\name{\normalsize\normalfont}%
			\def\AND{\@endauthor\rm\hss \vskip \interauthorskip \@startauthor}
			\@startauthor \@author \@endauthor}
		\vskip \aftermaketitskip
		\thispagestyle{plain}
}}

\def\addr{\small}%
\def\email{\hfill\small\sc}%
\def\name{\normalsize\it}%
\def\AND{\@endauthor\rm\hss \vskip \interauthorskip \@startauthor}
\makeatother

\ExecuteBibliographyOptions{
	sorting = nyt,
	useprefix
}

\AtEveryBibitem{\clearfield{series}}
\AtEveryCitekey{\clearfield{series}}
\AtEveryBibitem{\clearlist{language}}
\AtEveryCitekey{\clearlist{language}}
\AtEveryBibitem{\clearlist{address}}
\AtEveryCitekey{\clearlist{address}}
\AtEveryBibitem{\clearlist{location}}
\AtEveryCitekey{\clearlist{location}}
\AtEveryBibitem{\clearfield{month}}
\AtEveryCitekey{\clearfield{month}}
\AtEveryCitekey{\ifentrytype{inproceedings}{\clearfield{pages}}{}}
\AtEveryBibitem{\ifentrytype{inproceedings}{\clearfield{pages}}{}}
\AtEveryCitekey{\ifentrytype{inproceedings}{\clearlist{publisher}}{}}
\AtEveryBibitem{\ifentrytype{inproceedings}{\clearlist{publisher}}{}}
\AtEveryCitekey{\ifentrytype{inproceedings}{\clearname{editor}}{}}
\AtEveryBibitem{\ifentrytype{inproceedings}{\clearname{editor}}{}}
\AtEveryCitekey{\ifentrytype{inproceedings}{\clearlist{organization}}{}}
\AtEveryBibitem{\ifentrytype{inproceedings}{\clearlist{organization}}{}}



% See: http://tex.stackexchange.com/questions/43196/biblatex-fullcite-produces-different-result-from-bibliography-entry
\DeclareCiteCommand{\fullcite}
{\usebibmacro{prenote}}
{\usedriver
	{\defcounter{minnames}{6}%
		\defcounter{maxnames}{6}}
	{\thefield{entrytype}}.}
{\multicitedelim}
{\usebibmacro{postnote}}


\DeclareFieldFormat{labelnumberwidth}{#1.}
\DefineBibliographyStrings{english}{
  andothers   = et al\adddot,
  editor      = ed\adddot,
  editors     = eds\adddot,
}
\defbibheading{subbibliography}[\refname]{%
 \section*{#1}%
 \addcontentsline{toc}{reference}{References}%
 \markright{\thechapter: References}}



\DeclareFieldFormat{titlecase}{\titlecap{\textnc{#1}}}
\renewbibmacro*{title}{%
  \ifboolexpr{
    test {\iffieldundef{title}}
    and
    test {\iffieldundef{subtitle}}
  }
    {}
    {%
      \printtext[title]{%
        \printfield[titlecase]{title}%
        \setunit{\subtitlepunct}%
        \printfield[titlecase]{subtitle}%
      }%
      \newunit
    }%
  \printfield{titleaddon}%
}

\setcounter{biburlnumpenalty}{1000}
\setcounter{biburlucpenalty}{1000}
\setcounter{biburllcpenalty}{1000}

\bibsetup{
  \setcounter{abbrvpenalty}{0}
  \setcounter{highnamepenalty}{0}
  \setcounter{lownamepenalty}{0}
}

\DeclareFieldFormat{doi}{%
  \textsc{doi}\addcolon\space
  \ifhyperref
    {\href{http://dx.doi.org/#1}{\nolinkurl{#1}}}
    {\nolinkurl{#1}}}

\setcounter{biburlnumpenalty}{100}
\setcounter{biburlucpenalty}{100}
\setcounter{biburllcpenalty}{100}
\renewrobustcmd*{\bibinitdelim}{\addnbthinspace} % add thin space between author initials

\renewcommand*{\bibfont}{\small}

\renewbibmacro*{bbx:savehash}{} % remove dashes for repeated authors


\begin{jlcode}
	cur_plot = nothing
	function plot_pgfplots(args...; kwags...)
		global cur_plot
		cur_plot = PGFPlots.plot(args...; kwags...)
	end
	function plot_gadfly(args...; kwags...)
		global cur_plot
		cur_plot = Gadfly.plot(args...; kwags...)
	end
\end{jlcode}

\DeclareRobustCommand{\plot}[1]{
\IfFileExists{#1.tex}{}{\newwrite\file
	\immediate\openout\file=#1.tex
	\closeout\file}
	\jlc{save("#1.tex", cur_plot, include_preamble=false)}\input{#1}}
\jlc{using PGFPlots}
\jlc{plot(args...; kwags...) = plot_pgfplots(args...; kwags...)}

\RequirePackage{xparse}
\RequirePackage{bm,upgreek}

\ExplSyntaxOn
\NewDocumentCommand\vect{m}
{
	\commexo_vector:n { #1 }
}

\cs_new_protected:Npn \commexo_vector:n #1
{
	\tl_map_inline:nn { #1 }
	{
		\commexo_vector_inner:n { ##1 }
	}
}

\cs_new_protected:Npn \commexo_vector_inner:n #1
{
	\tl_if_in:VnTF \g_commexo_latin_tl { #1 }
	{% we check whether the argument is a Latin letter
		\mathbf { #1 } % a Latin letter
	}
	{% if not a Latin letter, we check if it's an uppercase Greek letter
		\tl_if_in:VnTF \g_commexo_ucgreek_tl { #1 }
		{
			\bm { #1 } % a Greek uppercase letter
		}
		{% if not, we check if it's a lowercase Greek letter
			\tl_if_in:VnTF \g_commexo_lcgreek_tl { #1 }
			{
				\commexo_makeboldupright:n { #1 }
			}
			{% none of the above, just issue #1
				\tl_if_in:VnTF \g_commexo_other_tl { #1 }
				{
					\boldsymbol { #1 }
				}
				{% none of the above, just issue #1
					#1 % fall back
				}
			}
		}
	}
}

\cs_new_protected:Npn \commexo_makeboldupright:n #1
{
	\bm { \use:c { up \cs_to_str:N #1 } }
}

\tl_new:N \g_commexo_latin_tl
\tl_new:N \g_commexo_ucgreek_tl
\tl_new:N \g_commexo_lcgreek_tl
\tl_gset:Nn \g_commexo_latin_tl
{
	ABCDEFGHIJKLMNOPQRSTUVWXYZ
	abcdefghijklmnopqrstuvwxyz
	0123456789
}
\tl_gset:Nn \g_commexo_ucgreek_tl
{
	\Gamma\Delta\Theta\Lambda\Pi\Sigma\Upsilon\Phi\Chi\Psi\Omega
}
\tl_gset:Nn \g_commexo_lcgreek_tl
{
	\alpha\beta\gamma\delta\epsilon\zeta\eta\theta\iota\kappa
	\lambda\mu\nu\xi\pi\rho\sigma\tau\upsilon\phi\chi\psi\omega
	\varepsilon\vartheta\varpi\varphi\varsigma\varrho
}
\tl_gset:Nn \g_commexo_other_tl
{
	\ell
}

\ExplSyntaxOff

\renewcommand{\cite}[2][0pt]{\sidenote[][#1]{\fullcite{#2}.}}

\renewcommand{\vec}[1]{\vect{#1}}
\newcommand{\mat}[1]{\vect{#1}}
