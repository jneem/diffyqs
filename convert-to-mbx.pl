print "running ...\n"; 



# regex playground tests
#$str = "uBu\nobo\noko";
#
#if ($str =~ m/^uBu/) { print "match ^ubu\n"; }
#if ($str =~ m/^obo/) { print "match ^obo\n"; }
#if ($str =~ m/^obo/s) { print "match ^obo s\n"; }
#if ($str =~ m/^obo/m) { print "match ^obo m\n"; }
#if ($str =~ m/obo$/) { print "match obo\$\n"; }
#if ($str =~ m/obo$/s) { print "match obo\$ s\n"; }
#if ($str =~ m/obo$/m) { print "match obo\$ m\n"; }
#if ($str =~ m/uBu.*?oko/) { print "match uBu.*?oko\n"; }
#if ($str =~ m/uBu.*?oko/s) { print "match uBu.*?oko s\n"; }
#if ($str =~ m/uBu.*?oko/m) { print "match uBu.*?oko m\n"; }
#if ($str =~ m/uBu[^p]*oko/) { print "match uBu[^p]*?oko\n"; }
#if ($str =~ m/uBu[^p]*oko/s) { print "match uBu[^p]*?oko s\n"; }
#if ($str =~ m/uBu[^p]*oko/m) { print "match uBu[^p]*?oko m\n"; }
#
#exit 1;
 
open(my $in,'<', "diffyqs.tex") or die $!; 
open(my $out, '>' ,"diffyqs-out.xml") or die $!; 
 
#my $line = <$in>; 
#
#chomp($line);
#
#$line =~ s/ /,/g; 
#print $out "$line"; 
#$line =<$in>;  
#print $out "$line"; 
#
#

$mbxignore = 0;

$commands = "";

print $out <<END;
<?xml version="1.0" encoding="UTF-8" ?>
<mathbook>
END

$docinfoextra = "";
$macrosextra = "";

while($line = <$in>)
{
	chomp($line);
	if ($line =~ m/^%mbxSTARTIGNORE/) {
		$mbxignore = 1;
	} elsif ($line =~ m/^%mbxENDIGNORE/) {
		$mbxignore = 0;
	} elsif ($line =~ m/^%mbx[ \t](.*)$/) {
		print $out "$1\n";
	} elsif ($line =~ m/^%mbxdocinfo[ \t](.*)$/) {
		$docinfoextra = $docinfoextra . "$1\n";
	} elsif ($line =~ m/^%mbxmacro[ \t](.*)$/) {
		$macrosextra = $macrosextra . "$1\n";
	} elsif ($line =~ m/^\\begin{document}/) {
		printf ("found begin document\n");
		last;
	} elsif ($mbxignore == 0 && $line =~ m/^\\renewcommand/) {
		$commands = $commands . "$line\n";
	} elsif ($mbxignore == 0 && $line =~ m/^\\newcommand/) {
		$commands = $commands . "$line\n";
	}
}

print $out "<docinfo>\n";

if ($docinfoextra ne "") {
	print $out $docinfoextra;
}

if ($commands ne "" || $macrosextra ne "") {
	print $out "  <macros>\n";
	print $out $commands;
	print $out $macrosextra;
	print $out "  </macros>\n";
}

print $out "</docinfo>\n";
print $out "<book xml:id=\"diffyqs\">\n";

$didp = 0;
$inchapter = 0;
$insection = 0;
$insubsection = 0;
$insubsubsection = 0;
$initem = 0;
$inparagraph = 0;

$chapter_num = 0;
$section_num = 0;
$subsection_num = 0;
$subsubsection_num = 0;

$exercise_num = 0;
$thm_num = 0;
$remark_num = 0;
$example_num = 0;

#FIXME: equation counter implement
$equation_num = 0;

print $out $commands;

sub close_paragraph {
	if ($inparagraph) {
		$inparagraph = 0;
		print $out "</p>\n"
	}
}
sub close_item {
	close_paragraph ();
	if ($initem) {
		$initem = 0;
		print $out "</li>\n"
	}
}
sub close_subsubsection {
	close_paragraph ();
	if ($insubsubsection) {
		$insubsubsection = 0;
		print $out "</subsubsection>\n\n"
	}
}
sub close_subsection {
	close_subsubsection ();
	if ($insubsection) {
		$insubsection = 0;
		print $out "</subsection>\n\n"
	}
}
sub close_section {
	close_subsection();
	if ($insection) {
		$insection = 0;
		print $out "</section>\n\n"
	}
}
sub close_chapter {
	close_section ();
	if ($inchapter) {
		$inchapter = 0;
		print $out "</chapter>\n\n"
	}
}
sub open_paragraph {
	close_paragraph ();
	$inparagraph = 1;
	print $out "<p>\n"
}
sub open_paragraph_if_not_open {
	if ($inparagraph == 0) {
		$inparagraph = 1;
		print $out "<p>\n"
	}
}
sub open_item {
	close_item ();
	$initem = 1;
	print $out "<li>\n"
}
sub open_subsubsection {
	my $theid = shift;
	close_subsubsection ();
	$insubsubsection = 1;
	$subsubsection_num = $subsubsection_num+1;

	if ($theid ne "") {
		print $out "\n<subsubsection xml:id=\"$theid\" number=\"$chapter_num.$section_num.$subsection_num.$subsubsection_num\">\n"
	} else {
		print $out "\n<subsubsection number=\"$chapter_num.$section_num.$subsection_num.$subsubsection_num\">\n"
	}
}
sub open_subsection {
	my $theid = shift;
	close_subsection ();
	$insubsection = 1;
	$subsection_num = $subsection_num+1;

	$subsubsection_num = 0;

	if ($theid ne "") {
		print $out "\n<subsection xml:id=\"$theid\" number=\"$chapter_num.$section_num.$subsection_num\">\n"
	} else {
		print $out "\n<subsection number=\"$chapter_num.$section_num.$subsection_num\">\n"
	}
}
sub open_section {
	my $theid = shift;
	close_section ();
	$insection = 1;
	$section_num = $section_num+1;

	$subsection_num = 0;
	$subsubsection_num = 0;

	$exercise_num = 0;
	$thm_num = 0;
	$remark_num = 0;
	$example_num = 0;

	if ($theid ne "") {
		print $out "\n<section xml:id=\"$theid\" number=\"$chapter_num.$section_num\">\n"
	} else {
		print $out "\n<section number=\"$chapter_num.$section_num\">\n"
	}
}

sub open_chapter {
	my $theid = shift;
	close_chapter ();
	$inchapter = 1;

	$chapter_num = $chapter_num+1;
	$section_num = 0;
	$subsection_num = 0;
	$subsubsection_num = 0;

	$exercise_num = 0;
	$thm_num = 0;
	$remark_num = 0;
	$example_num = 0;

	$equation_num = 0;

	if ($theid ne "") {
		print $out "\n<chapter xml:id=\"$theid\" number=\"$chapter_num\">\n"
	} else {
		print $out "\n<chapter number=\"$chapter_num\">\n"
	}
}

sub modify_id {
	my $theid = shift;
	$theid =~ s/^([0-9])/X$1/;
	$theid =~ s/:/_/g;
	return $theid;
}

sub do_line_subs {
	my $line = shift;

	if ($line =~ s|~|<nbsp/>|g) {
		print "substituted nbsps\n";
	}
	if ($line =~ s|---|&#x2014;|g) {
		print "substituted emdashes\n";
	}
	if ($line =~ s|--|&#x2013;|g) {
		print "substituted endashes\n";
	}
	##FIXME: should we do this?
	#if ($line =~ s|-|&#x2010;|g) {
	#print "substituted hyphens\n";
	#}
	
	return $line;
}

sub print_line {
	my $line = shift;

	if ($inparagraph == 0 && $line =~ m/[^ \r\n\t]/) {
		open_paragraph ();
	}
	$line = do_line_subs($line);
	print "line -- >$line<\n";
	print $out $line;
}

sub do_thmtitle_subs {
	my $title = shift;

	$title =~ s|\\href{(.*?)}{(.*?)}|<url href=\"$1\">$2</url>|s;

	#Assuming single footnote in title
	$title =~ s|\\footnote{(.*)}|<fn>$1</fn>|s;

	$title = do_line_subs($title);

	return $title;
}

sub get_exercise_number {
	if ($insection) {
		return "$chapter_num.$section_num.$exercise_num";
	} elsif ($inchapter) {
		return "$chapter_num.$exercise_num";
	} else {
		return "$exercise_num";
	}
}

sub get_thm_number {
	if ($insection) {
		return "$chapter_num.$section_num.$thm_num";
	} elsif ($inchapter) {
		return "$chapter_num.$thm_num";
	} else {
		return "$thm_num";
	}
}

sub get_remark_number {
	if ($insection) {
		return "$chapter_num.$section_num.$remark_num";
	} elsif ($inchapter) {
		return "$chapter_num.$remark_num";
	} else {
		return "$remark_num";
	}
}

sub get_example_number {
	if ($insection) {
		return "$chapter_num.$section_num.$example_num";
	} elsif ($inchapter) {
		return "$chapter_num.$example_num";
	} else {
		return "$example_num";
	}
}

sub get_equation_number {
	return "$equation_num";
}

sub get_size_of_svg {
	my $thefile = shift;
	$thesizestr = qx!cat $thefile | grep '^<svg ' | sed 's/^.*\\(width="[^"]*"\\) *\\(height="[^"]*"\\).*\$/\\1 \\2/'!;
	chomp($thesizestr);
	print "the size string of $thefile >$thesizestr<\n";
	return $thesizestr
}

sub ensure_svg_version {
	my $thefile = shift;

	print "ENSURE $thefile.svg\n";
	if ((not -e "$thefile.svg") and (-e "$thefile.pdf")) {
		print "MAKING $thefile.svg from PDF\n";
		system("pdf2svg $thefile.pdf $thefile.svg");
	}
}

sub ensure_mbx_png_version {
	my $thefile = shift;

	print "ENSURE $thefile-mbx.png\n";
	if ((not -e "$thefile-mbx.png") and (-e "$thefile.pdf")) {
		print "MAKING $thefile-mbx.png from PDF\n";
		system("./pdftopng.sh $thefile.pdf $thefile-mbx.png 192");
	}
}

sub read_paragraph {
	$para = "";
	$read_something = 0;
	while($line = <$in>) {

		chomp($line);

		#things that should go into the mbx to be processed (not raw MBX
		#as %mbx) but should be ignored by latex
		$line =~ s/^%mbxlatex //;

		if ($line =~ m/^%mbxSTARTIGNORE/) {
			$mbxignore = 1;
		} elsif ($line =~ m/^%mbxENDIGNORE/) {
			$mbxignore = 0;

		#This will only work right if the paragraphs are separated, that is if it is
		#in the middle of a paragraph it put the %mbx line in the wrong place
		} elsif ($line =~ m/^%mbx[ \t](.*)$/) {
			$thembxline = $1;
			#FIXME: this is a terrible hack, but the only way I can get this
			#hardcoded number stuff to work
			#This will only work right if the paragraphs are separated, that is if it is
			#in the middle of a paragraph it will get the numbers wrong.
			while ($thembxline =~ m/%MBXEQNNUMBER%/) {
				$equation_num = $equation_num+1;
				$the_num = get_equation_number ();
				$thembxline =~ s/%MBXEQNNUMBER%/$the_num/;
			}
			print $out "$thembxline\n";
		} elsif ($line =~ m/^\\documentclass/ ||
			$line =~ m/^\\usepackage/ ||
			$line =~ m/^\\addcontentsline/) {
			# do nothing
			;
		} elsif ($line =~ m/^%mbxBACKMATTER/) {
			close_chapter ();
		} elsif ($mbxignore == 0) {
			$newline = 1;
			if ($line =~ m/^%/ || $line =~ m/[^\\]%/) {
				$newline = 0;
			}
			$line =~ s/^%.*$//;
			$line =~ s/([^\\])%.*$/$1/;

			if ($line =~ m/^[ \t]*$/ && $newline) {
				if ($read_something) {
					$para = $para . $line; # . " ";
					last;
				}
			}

			$read_something = 1;

			if ($newline) {
				$para = $para . $line . "\n";
			} else {
				$para = $para . $line;
			}
		}
	}

	#Do simple substitutions
	$para =~ s/\\"{o}/ö/g;
	$para =~ s/\\"o/ö/g;
	$para =~ s/\\c{S}/Ş/g;
	$para =~ s/\\u{g}/ğ/g;
	$para =~ s/\\v{r}/ř/g;
	$para =~ s/\\c{c}/ç/g;
	$para =~ s/\\'e/é/g;
	$para =~ s/\\'{e}/é/g;
	$para =~ s/\\`e/è/g;
	$para =~ s/\\`{e}/è/g;
	$para =~ s/\\`a/à/g;
	$para =~ s/\\`{a}/à/g;
	$para =~ s/\\'i/í/g;
	$para =~ s/\\'{i}/í/g;
	$para =~ s/\\'E/É/g;
	$para =~ s/\\'{E}/É/g;
	$para =~ s/\\S([^a-zA-Z])/§$1/g;

	$para =~ s/&/&amp;/g;
	$para =~ s/>/&gt;/g;
	$para =~ s/</&lt;/g;

	#strip leading and trailing spaces
	#$para =~ s/^ *//;
	#$para =~ s/[ \n]*$//;

	#Also strip some nonsensical spaces
	#$para =~ s/[ \n](\\end{(exercise|example|thm|equation|align|equation\*|align\*)})/$1/g;
	

	return $para;
}



@cltags = ();

while(1)
{
	if ($para eq "") {
		$para = read_paragraph ();
	}

	#print "\n\nparagraph: [[[$para]]]\n";

	if ($para =~ m/^\\end{document}/) {
		last;

	#copy whitespace
	} elsif ($para =~ s/^([ \n\r\t])//) {
		print $out "$1";

	} elsif ($para =~ s/^\$([^\$]+)\$//) {
		$line = $1;
		open_paragraph_if_not_open ();
		print $out "<m>$line</m>";

	} elsif ($para =~ s/^\\chapter\*{([^}]*)}[\n ]*\\label{([^}]*)}[ \n]*//) {
		#FIXME: un-numbered
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		$chapter_num = $chapter_num-1; #hack
		open_chapter($theid);
		print "(chapter >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
		print "PARA:>$para<\n";
	} elsif ($para =~ s/^\\chapter\*{([^}]*)}[ \n]*//) {
		$name = $1;
		#FIXME: un-numbered
		$chapter_num = $chapter_num-1; #hack
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_chapter("");
		print "(chapter >$name<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\chapter{([^}]*)}[\n ]*\\label{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_chapter($theid);
		print "(chapter >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\chapter{([^}]*)}[ \n]*//) {
		$name = 1;
		open_chapter("");
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		print "(chapter >$name<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\section{([^}]*)}[ \n]*\\label{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_section($theid);
		print "(section >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\section{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_section();
		print "(section >$name<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\subsection{([^}]*)}[ \n]*\\label{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsection($theid);
		print "(subsection >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\subsection{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsection("");
		print "(subsection >$name<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\subsubsection{([^}]*)}[ \n]*\\label{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsubsection($theid);
		print "(subsubsection >$name< label >$theid<)\n";
		print $out "<title>$name</title>\n"; 
	} elsif ($para =~ s/^\\subsubsection{([^}]*)}[ \n]*//) {
		$name = $1;
		$theid = modify_id($2);
		$name =~ s|\$(.*?)\$|<m>$1</m>|gs;
		open_subsubsection("");
		print "(subsubsection >$name<)\n";
		print $out "<title>$name</title>\n"; 

	# this assumes sectionnotes come in their own $para
	} elsif ($para =~ s/^\\sectionnotes{(.*)}[ \n\t]*//s) {
		$secnotes = $1;
		$secnotes =~ s|\\cite{([^}]*)}|<xref ref=\"biblio-$1\"/>|g;
		$secnotes =~ s|\\BDref{([^}]*)}|$1|g;
		$secnotes =~ s|\\EPref{([^}]*)}|$1|g;
		print "(secnotes $secnotes)\n";
		print "(cite $secnotes)\n";
		print $out "<p><em>$secnotes</em></p>\n"; 

	} elsif ($para =~ s/^\\setcounter{exercise}{(.*?)}[ \n\t]*//s) {
		$exercise_num=$1;

	} elsif ($para =~ s/^\\href{([^}]*)}{([^}]*)}//) {
		open_paragraph_if_not_open ();
		print "(link $1 $2)\n";
		print $out "<url href=\"$1\">$2</url>"; 
	} elsif ($para =~ s/^\\url{([^}]*)}//) {
		open_paragraph_if_not_open ();
		print "(url $1)\n";
		print $out "<url>$1</url>"; 
	} elsif ($para =~ s/^\\cite{([^}]*)}//) {
		open_paragraph_if_not_open ();
		print "(cite $1)\n";
		print $out "<xref ref=\"biblio-$1\"/>"; 

	} elsif ($para =~ s/^\\index{([^}]*)}//) {
		open_paragraph_if_not_open ();
		print "(index $1)\n";
		$index = $1;
		$index =~ s|\$(.*?)\$|<m>$1</m>|sg;
		$index =~ s|^(.*)!(.*)$|<main>$1</main><sub>$2</sub>|s;
		print $out "<index>$index</index>"; 
	} elsif ($para =~ s/^\\myindex{([^}]*)}//) {
		open_paragraph_if_not_open ();
		print "(myindex $1)\n";
		$index = $1;
		$index =~ s|\$(.*?)\$|<m>$1</m>|sg;
		print $out "$index<index>$index</index>"; 

	} elsif ($para =~ s/^\\eqref{([^}]*)}//) {
		open_paragraph_if_not_open ();
		$theid = modify_id($1);
		print "(eqref $theid)\n";
		print $out "<xref ref=\"$theid\"/>";
	} elsif ($para =~ s/^\\ref{([^}]*)}//) {
		open_paragraph_if_not_open ();
		$theid = modify_id($1);
		print "(ref $theid)\n";
		print $out "<xref ref=\"$theid\"/>";
	} elsif ($para =~ s/^\\chapterref{([^}]*)}// ||
		$para =~ s/^\\chaptervref{([^}]*)}// ||
		$para =~ s/^\\Chapterref{([^}]*)}// ||
		$para =~ s/^\\sectionref{([^}]*)}// ||
		$para =~ s/^\\sectionvref{([^}]*)}// ||
		$para =~ s/^\\thmref{([^}]*)}// ||
		$para =~ s/^\\thmvref{([^}]*)}// ||
		$para =~ s/^\\tableref{([^}]*)}// ||
		$para =~ s/^\\tablevref{([^}]*)}// ||
		$para =~ s/^\\figureref{([^}]*)}// ||
		$para =~ s/^\\figurevref{([^}]*)}// ||
		$para =~ s/^\\exampleref{([^}]*)}// ||
		$para =~ s/^\\examplevref{([^}]*)}// ||
		$para =~ s/^\\exerciseref{([^}]*)}// ||
		$para =~ s/^\\exercisevref{([^}]*)}//) {
		$theid = modify_id($1);
		open_paragraph_if_not_open ();
		print "(named ref $theid)\n";
		print $out "<xref ref=\"$theid\" autoname=\"yes\"/>";
	} elsif ($para =~ s/^\\hyperref\[([^[]*)\]{([^}]*)}//) {
		$name = $2;
		$theid = modify_id($1);
		open_paragraph_if_not_open ();
		print "(hyperref $theid $name)\n";
		print $out "<xref ref=\"$theid\" autoname=\"title\">$name</xref>";
	} elsif ($para =~ s/^\\emph{//) {
		print "(em start)\n";
		open_paragraph_if_not_open();
		print $out "<em>"; 
		push @cltags, "em";
	} elsif ($para =~ s/^\\myquote{//) {
		print "(myquote start)\n";
		open_paragraph_if_not_open();
		print $out "<q>"; 
		push @cltags, "myquote";

	} elsif ($para =~ s/^\\textbf{(.*?)}//s) {
		print "(textbf $1)\n";
		open_paragraph_if_not_open ();
		print $out "<alert>$1</alert>";

	} elsif ($para =~ s/^\\texttt{(.*?)}//s) {
		print "(texttt $1)\n";
		open_paragraph_if_not_open ();
		print $out "<c>$1</c>"; 

	} elsif ($para =~ s/^\\unit{(.*?)}//s) {
		print "(unit $1)\n";
		open_paragraph_if_not_open ();
		print $out "$1"; 
	} elsif ($para =~ s/^\\unit\[(.*?)\]{(.*?)}//s) {
		$txt = $1;
		$unit = $2;
		$txt =~ s|\$(.*?)\$|<m>$1</m>|gs;
		print "(unit $txt $unit)\n";
		open_paragraph_if_not_open ();
		print $out "$txt $unit"; 
	} elsif ($para =~ s/^\\unitfrac{(.*?)}{(.*?)}//s) {
		print "(unitfrac $1/$2)\n";
		open_paragraph_if_not_open ();
		print $out "<m>\\nicefrac{\\text{$1}}{\\text{$2}}</m>"; 
	} elsif ($para =~ s/^\\unitfrac\[(.*?)\]{(.*?)}{(.*?)}//s) {
		$txt = $1;
		$unitnum = $2;
		$unitden = $3;

		$txt =~ s|\$(.*?)\$|<m>$1</m>|gs;
		print "(unitfrac $txt $unitnum/$unitden)\n";
		open_paragraph_if_not_open ();
		print $out "$txt <m>\\nicefrac{\\text{$unitnum}}{\\text{$unitden}}</m>"; 

	} elsif ($para =~ s/^\\begin{align\*}[ \n]*//) {
		print "(ALIGN*)\n";
		if ($para =~ s/^(.*?)\\end{align\*}[ \n]*//s) {
			$eqn = $1;

			#FIXME: Is wrapping in aligned all kosher?
			print $out "<me>\n";
			print $out "\\begin{aligned}\n";
			print "(wrapping in aligned) EQ = $eqn\n";
			print $out "$eqn";
			print $out "\\end{aligned}\n";
			print $out "</me>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end align*!\n\n$para\n\n";
		}
	} elsif ($para =~ s/^\\begin{align}[ \n]*//) {
		print "(ALIGN)\n";
		if ($para =~ s/^(.*?)\\end{align}[ \n]*//s) {
			$eqn = $1;
			#$theid = "";
			#if ($para =~ s/^ *\\label{(.*?)} *//) {
			#	$theid = $1;
			#}

			print $out "<md>\n";
			print $out "<mrow>\n";

			#FIXME: this will mess up things with cases
			# But currently I only have one single {align} with numbers
			# that will need to get handled
			$eqn =~ s|\\\\|</mrow>\n<mrow>\n|g;
			print "EQ = $eqn\n";

			print $out "$eqn";

			print $out "</mrow>\n";
			print $out "</md>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end align!\n\n$para\n\n";
		}

	} elsif ($para =~ s/^\\begin{multline\*}[ \n]*//) {
		print "(MULTLINE*)\n";
		if ($para =~ s/^(.*?)\\end{multline\*}[ \n]*//s) {
			$eqn = $1;

			print $out "<me latexenv=\"multline*\">\n";
			print "EQ(multline*) = $eqn\n";
			print $out "$eqn";
			print $out "</me>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end multline*!\n\n$para\n\n";
		}
	} elsif ($para =~ s/^\\begin{multline}[ \n]*//) {
		print "(MULTLINE)\n";
		if ($para =~ s/^(.*?)\\end{multline}[ \n]*//s) {
			$eqn = $1;
			$theid = "";
			if ($eqn =~ s/^[ \n]*\\label{(.*?)}[ \n]*//s) {
				$theid = modify_id($1);
			}

			$equation_num = $equation_num+1;
			$the_num = get_equation_number ();

			if ($theid eq "") {
				print $out "<men number=\"$the_num\" latexenv=\"multline\">\n";
			} else {
				print $out "<men xml:id=\"$theid\" number=\"$the_num\" latexenv=\"multline\">\n";
			}
			print "EQ(multline) = $eqn\n";
			print $out "$eqn";
			print $out "</men>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end multline!\n\n$para\n\n";
		}

	} elsif ($para =~ s/^\\begin{equation\*}[ \n]*//) {
		print "(EQUATION*)\n";
		if ($para =~ s/^(.*?)\\end{equation\*}[ \n]*//s) {
			$eqn = $1;
			print $out "<me>\n";
			print "EQ = $eqn\n";
			print $out "$eqn</me>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end equation*!\n\n$para\n\n";
		}
	} elsif ($para =~ s/^\\begin{equation}[ \n]*//) {
		print "(EQUATION)\n";
		if ($para =~ s/^(.*?)\\end{equation}[ \n]*//s) {
			$eqn = $1;
			$theid = "";
			if ($eqn =~ s/^[ \n]*\\label{(.*?)}[ \n]*//s) {
				$theid = modify_id($1);
			}
			$equation_num = $equation_num+1;
			$the_num = get_equation_number ();

			if ($theid eq "") {
				print $out "<men number=\"$the_num\">\n";
			} else {
				print $out "<men xml:id=\"$theid\" number=\"$the_num\">\n";
			}
			print "EQ = $eqn\n";
			print $out "$eqn</men>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end equation!\n\n$para\n\n";
		}

	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on contents and/or caption
	} elsif ($para =~ s/^\\begin{table}(\[.*?\])?[ \n]*//) {
		print "(TABLE)\n";
		if ($para =~ s/^(.*?)\\end{table}[ \n]*//s) {
			$table = $1;

			# FIXME possibly not ok within math?
			$table =~ s|~|<nbsp/>|g;

			$caption = "";
			$theid = "";
			if ($table =~ s/\\caption{(.*?)[ \n]*\\label{(.*?)}}[ \n]*//s) {
				$caption = $1;
				$theid = modify_id($2);
				$caption =~ s|\$(.*?)\$|<m>$1</m>|sg;
			} else {
				print "\n\n\nHUH?\n\n\nNo caption/label!\n\n$para\n\n";
			}
			# kill centering and the rules and the tabular 
			$table =~ s/\\begin{center}[ \n]*//;
			$table =~ s/\\end{center}[ \n]*//;
			$table =~ s/\\capstart[ \n]*//g;
			$table =~ s/\\(mid|bottom|top)rule[ \n]*//g;
			$table =~ s/\\begin{tabular}.*[ \n]*//;
			$table =~ s/\\end{tabular}[ \n]*//;

			close_paragraph ();
			print $out "<table xml:id=\"$theid\">\n";
			print $out "  <caption>$caption</caption>\n";
			print $out "  <tabular top=\"major\" halign=\"left\">\n";

			if ($table =~ s/^(.*?)[ \n]*\\\\(\[.*?\])?[ \n]*//s) {
				$fline = $1;
				$fline =~ s|[ \n]*\&amp;[ \n]*|</cell><cell>|g;
				$fline =~ s|\$(.*?)\$|<m>$1</m>|sg;
				print $out "    <row bottom=\"minor\"><cell>$fline</cell></row>\n";
			} else {
				print "\n\n\nHUH?\n\n\nNo first line!\n\n$para\n\n";
			}
			print $out "    <row><cell>";

			# kill trailing line end
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*$||;

			$table =~ s|\$(.*?)\$|<m>$1</m>|sg;

			$table =~ s|[ \n]*\&amp;[ \n]*|</cell><cell>|g;
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*|</cell></row>\n    <row><cell>|g;

			# last row should have bottom minor
			$table =~ s|<row>(.*?)$|<row bottom=\"minor\">$1|;

			print $out "$table</cell></row>\n  </tabular>\n</table>\n";
		} else {
			print "\n\n\nHUH?\n\n\nNo end table!\n\n$para\n\n";
		}
		#
	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on contents and/or caption
	} elsif ($para =~ s/^(\\begin{center}[ \n]*)?\\begin{tabular}.*[ \n]*//) {
		print "(TABULARONLY)\n";
		$docenter = 0;
		if ($1 =~ m/^\\begin{center}/) {
			$docenter = 1;
		}
		if ($para =~ s/^(.*?)\\end{tabular}[ \n]*(\\end{center}[ \n]*)?//s) {
			$table = $1;

			# FIXME possibly not ok within math?
			$table =~ s|~|<nbsp/>|g;

			# kill the rules 
			$table =~ s/\\capstart[ \n]*//g;
			if ($table =~ s/\\(mid|bottom|top)rule[ \n]*//g) {
				$dorules = 1;
			} else {
				$dorules = 0;
			}

			if ($docenter && $inparagraph == 0) {
				#FIXME: this doesn't work!
				#print $out "<p halign=\"center\">\n";
				print $out "<table>\n";
			}
			if ($dorules) {
				print $out "<tabular top=\"major\" halign=\"left\">\n";
			} else {
				print $out "<tabular halign=\"left\">\n";
			}

			if ($dorules) {
				if ($table =~ s/^(.*?)[ \n]*\\\\(\[.*?\])?[ \n]*//s) {
					$fline = $1;
					$fline =~ s|[ \n]*\&amp;[ \n]*|</cell><cell>|g;
					$fline =~ s|\$(.*?)\$|<m>$1</m>|sg;
					print $out "  <row bottom=\"minor\"><cell>$fline</cell></row>\n";
				} else {
					print "\n\n\nHUH?\n\n\nNo first line!\n\n$para\n\n";
				}
			}
			print $out "  <row><cell>";

			# kill trailing line end
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*$||;

			$table =~ s|\$(.*?)\$|<m>$1</m>|sg;

			$table =~ s|[ \n]*\&amp;[ \n]*|</cell><cell>|g;
			$table =~ s|[ \n]*\\\\(\[.*?\])?[ \n]*|</cell></row>\n  <row><cell>|g;

			# last row should have bottom minor
			if ($dorules) {
				$table =~ s|<row>(.*?)$|<row bottom=\"minor\">$1|;
			}

			print $out "$table</cell></row>\n</tabular>\n";
			if ($docenter && $inparagraph == 0) {
				#print $out "</p>\n";
				print $out "</table>\n";
			}
		} else {
			print "\n\n\nHUH?\n\n\nNo end tabular/center!\n\n$para\n\n";
		}
		
	#FIXME:Assuming that diffyfloatingfigure(r) never has a caption
	#FIXME:Assuming that diffyfloatingfigure(r) is always just an inputpdft
	} elsif ($para =~ s/^\\begin{diffyfloatingfigurer?}{.*?}{(.*?)}[ \n]*//) {
		$thesize = $1;
		print "(DIFFYFLOATINGFIGURE)\n";
		if ($para =~ s/^(.*?)\\end{diffyfloatingfigurer?}[ \n]*//s) {
			$fig = $1;

			# kill unneccesaray things
			$fig =~ s/\\\\[ \n]*//g;
			$fig =~ s/\\noindent[ \n]*//g;
			$fig =~ s/\\bigskip[ \n]*//g;
			$fig =~ s/\\medskip[ \n]*//g;

			if ($fig =~ m/^[ \n]*\\inputpdft{(.*?)}[ \n]*$/) {
				$thefile = $1;
				$thesizestr = get_size_of_svg("$thefile-tex4ht.svg");
				open_paragraph ();
				if ($thesizestr ne "") {
					print $out "<image source=\"$thefile-tex4ht\" $thesizestr />\n";
				} else {
					print $out "<image source=\"$thefile-tex4ht\" width=\"$thesize\" />\n";
				}
				close_paragraph ();
			} else {
				print "\n\n\nHUH?\n\n\nDiffyfloatingfigure(r) not just an inputpdft!\n\nFIG=>$fig<\n\n";
			}
		} else {
			print "\n\n\nHUH?\n\n\nNo end diffyfloatingfigurer?\n\n$para\n\n";
		}

	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\begin{center}[ \n]*\\inputpdft{(.*?)}[ \n]*\\end{center}[ \n]*//) {
		$thefile = $1;
		print "(CENTERED inputpdft)\n";
		open_paragraph ();
		$thesizestr = get_size_of_svg("$thefile-tex4ht.svg");
		open_paragraph ();
		if ($thesizestr ne "") {
			print $out "<image source=\"$thefile-tex4ht\" $thesizestr />\n";
		} else {
			#FIXME
			print "\n\n\nHUH?\n\n\nCan't figure out the size of $thefile\n\n";
			print $out "<image source=\"$thefile-tex4ht\" height=\"1in\" />\n";
		}
		close_paragraph ();
		#
	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\\\[ \n]*\\includegraphics\[width=(.*?)\]{(.*?)}[ \n]*\\\\[ \n]*//) {
		$width = $1;
		$thefile = $2;
		print "(BRed image >$width< >$thefile<\n)";
		#ensure_svg_version ($thefile);
		ensure_mbx_png_version ($thefile);
		open_paragraph ();
		#FIXME: diffyqsinlineimage can't do PNG!!
		print "\n\n\nHUH???\n\n\ndiffyqsinlineimage can't PNG yet\n\n\n"
		print $out "<diffyqsinlineimage source=\"$thefile-mbx.png\" width=\"$width\" />\n";
		close_paragraph ();

	#FIXME: this is based entirely too much on my usage :)
	} elsif ($para =~ s/^\\parbox\[c\]{.*?}{\\includegraphics\[width=(.*?)\]{(.*?)}}[ \n]*//) {
		$width = $1;
		$thefile = $2;
		print "(PARBOXED image >$width< >$thefile<\n)";
		#ensure_svg_version ($thefile);
		ensure_mbx_png_version ($thefile);
		print $out "<diffyqsinlineimage source=\"$thefile-mbx.png\" width=\"$width\" />\n";

	#FIXME: not all substitutions are made, so check if more processing needs to be done
	#on caption
	} elsif ($para =~ s/^\\begin{figure}(\[.*?\])?[ \n]*// ||
	         $para =~ s/^\\begin{diffyfloatingfigurepdfonly}{.*?}[ \n]*//) {
		print "(FIGURE)\n";
		if ($para =~ s/^(.*?)\\end{figure}[ \n]*//s ||
		    $para =~ s/^(.*?)\\end{diffyfloatingfigurepdfonly}[ \n]*//s) {
			$figure = $1;

			#print "FIGFIG >$figure<\n";
			
			$figure =~ s/\\begin{center}[ \n]*//g;
			$figure =~ s/\\end{center}[ \n]*//g;
			$figure =~ s/\\capstart[ \n]*//g;
			$figure =~ s/\\noindent[ \n]*//g;
			$figure =~ s/\\diffypdfversion{\\vspace\*{.*?}}[ \n]*//g;

			@figs = ();

			#print "FIGFIG2 >$figure<\n";

			#FIXME: this is really my own particular usage!
			if ($figure =~ m/\\parbox/) {
				$foundsome = 0;
				print "found figure boxes\n";
				while ($figure =~ s/\\parbox\[t\]{(.*?)}{(.*?)\n *}//sm) {
					#print "FIGI >$1< >$2<\n";
					push @figs, $2;
					$foundsome = 1;
					print "got figure\n";
				}
				if (not $foundsome) {
					print "\n\n\nHUH?\n\n\nNo figure parboxes!\n\nFIG=$figure";
				}
				if ($figure =~ m/\\parbox/) {
					print "\n\n\nHUH?\n\n\nFigure parboxes left over!\n\nFIG=$figure";
				}
			} else {
				@figs = ($figure);
			}

			#print @figs;

			foreach (@figs) {
				$fig = $_;

				#print "FIGFIG3 >$fig<\n";
				
				$caption = "";
				$theid = "";
				if ($fig =~ s/\\caption(\[.*?\])?{(.*?)[ \n]*\\label{(.*?)}}[ \n]*//s) {
					$caption = $2;
					$theid = modify_id($3);

					print "figure id $theid\n";
			
					# FIXME possibly not ok within math?
					$caption =~ s|~|<nbsp/>|g;
			
					$caption =~ s|\$(.*?)\$|<m>$1</m>|sg;
				} else {
					print "\n\n\nHUH?\n\n\nNo caption/label!\n\nFIG=>$fig<\n\n";
				}

				close_paragraph ();
				$fig =~ s/\\quad[ \n]*//g;
				$fig =~ s/\\qquad[ \n]*//g;
				$fig =~ s/\\(med|big|small)skip[ \n]*//g;
				$fig =~ s/\\par[ \n]*//g;

				print $out "<figure xml:id=\"$theid\">\n";
				print $out "  <caption>$caption</caption>\n";

				if ($fig =~ m/^[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*$/) {
					$thefile = $1;
					#ensure_svg_version ($thefile);
					ensure_mbx_png_version ($thefile);
					print $out "  <image source=\"$thefile-mbx.png\" width=\"100\%\" />\n";
					#if ($thesize ne "") {
					#print $out "  <image source=\"$thefile\" width=\"$thesize\" />\n";
					#} else {
					#$thesizestr = get_size_of_svg("$thefile.svg");
					#print $out "  <image source=\"$thefile\" $thesizestr />\n";
					#}
				} elsif ($fig =~ m/^[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*\\\\[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*$/) {
					$thefile1 = $1;
					$thefile2 = $2;
					#ensure_svg_version ($thefile1);
					#ensure_svg_version ($thefile2);
					ensure_mbx_png_version ($thefile1);
					ensure_mbx_png_version ($thefile2);
					print $out "  <image source=\"$thefile1-mbx.png\" width=\"100\%\" />\n";
					print $out "  <image source=\"$thefile2\" width=\"100\%\" />\n";
				#2 picture version FIXME: removing these, adding hand-done guys
				#} elsif ($fig =~ m/^[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*$/) {
				#$thefile1 = $1;
				#$thefile2 = $2;
				#print "DOUBLEFIGURE!\n"
				#ensure_svg_version ($thefile1);
				#ensure_svg_version ($thefile2);
				#print $out "<sidebyside xml:id=\"$theid\">\n";
				#print $out "  <caption>$caption</caption>\n";
				#print $out "  <figure>\n";
				#print $out "    <image source=\"$thefile1\" />\n";
				#print $out "  </figure>\n";
				#print $out "  <figure>\n";
				#print $out "    <image source=\"$thefile2\" />\n";
				#print $out "  </figure>\n";
				#print $out "</sidebyside>\n";
					#if ($thesize1 ne "") {
					#print $out "  <image source=\"$thefile1\" width=\"$thesize1\" />\n";
					#} else {
					#$thesizestr = get_size_of_svg("$thefile1.svg");
					#print $out "  <image source=\"$thefile1\" $thesizestr />\n";
					#}
					#if ($thesize2 ne "") {
					#print $out "  <image source=\"$thefile2\" width=\"$thesize2\" />\n";
					#} else {
					#$thesizestr = get_size_of_svg("$thefile2.svg");
					#print $out "  <image source=\"$thefile2\" $thesizestr />\n";
					#}
				#4 picture version FIXME: removing these, adding hand-done guys
				#} elsif ($fig =~ m/^[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*\\diffyincludegraphics{[^}]*?}{[^}]*?}{([^}]*?)}[ \n]*$/) {
				#$thefile1 = $1;
				#$thefile2 = $2;
				#$thefile3 = $3;
				#$thefile4 = $4;
				#print "QUADFIGURE!\n"
				#ensure_svg_version ($thefile1);
				#ensure_svg_version ($thefile2);
				#ensure_svg_version ($thefile3);
				#ensure_svg_version ($thefile4);
				#print $out "<figure xml:id=\"$theid\">\n";
				#print $out "  <caption>$caption</caption>\n";
				#print $out "  <image source=\"$thefile1\" />\n";
				#print $out "  <image source=\"$thefile2\" />\n";
				#print $out "  <image source=\"$thefile3\" />\n";
				#print $out "  <image source=\"$thefile4\" />\n";
					#$thesizestr = get_size_of_svg("$thefile1.svg");
					#print $out "  <image source=\"$thefile1\" $thesizestr />\n";
					#$thesizestr = get_size_of_svg("$thefile2.svg");
					#print $out "  <image source=\"$thefile2\" $thesizestr />\n";
					#$thesizestr = get_size_of_svg("$thefile3.svg");
					#print $out "  <image source=\"$thefile3\" $thesizestr />\n";
					#$thesizestr = get_size_of_svg("$thefile4.svg");
					#print $out "  <image source=\"$thefile4\" $thesizestr />\n";
					#print $out "</figure>\n";
				} elsif ($fig =~ m/^[ \n]*\\inputpdft{(.*?)}[ \n]*$/) {
					$thefile = $1;
					$thesizestr = get_size_of_svg("$thefile-tex4ht.svg");
					print $out "<image source=\"$thefile-tex4ht\" $thesizestr />\n";
				} else {
					print "\n\n\nHUH?\n\n\nFigure too complicated!\n\nFIG=>$fig<\n\n";
				}
				print $out "</figure>\n";

			}
		} else {
			print "\n\n\nHUH?\n\n\nNo end figure!\n\n$para\n\n";
		}

	} elsif ($para =~ s/^\\begin{theorem}[ \n]*//) {
		close_paragraph();
		if ($para =~ s/^\[(.*?)\][ \n]*//s) {
			$title = do_thmtitle_subs($1);
		} else {
			$title = "";
		}

		$thm_num = $thm_num+1;
		$the_num = get_thm_number ();

		$theid = "";
		if ($para =~ s/^[ \n]*\\label{(.*?)}[ \n]*//s) {
			$theid = modify_id($1);
		}

		#FIXME: hack because I sometime switch index and label
		$indexo = "";
		while ($para =~ s/^[ \n]*\\index{(.*?)}[ \n]*//s) {
			$term = $1;
			$term =~ s|^(.*)!(.*)$|<main>$1</main><sub>$2</sub>|s;
			$term =~ s|\$(.*?)\$|<m>$1</m>|sg;
			$indexo = $indexo . "<index>$term</index>\n";
		}

		#FIXME: hack because I sometime switch index and label
		if ($para =~ s/^[ \n]*\\label{(.*?)}[ \n]*//s) {
			$theid = modify_id($1);
		}

		if ($theid ne "") {
			print $out "<theorem xml:id=\"$theid\" number=\"$the_num\">\n";
		} else {
			print $out "<theorem number=\"$the_num\">\n";
		}
		if ($title ne "") {
			print $out "<title>$title</title>\n";
		}
		if ($indexo ne "") {
			print $out "$indexo\n";
		}
		print $out "<statement>\n";

		open_paragraph();

	} elsif ($para =~ s/^\\end{theorem}[ \n]*//) {
		close_paragraph();
		print $out "</statement>\n</theorem>\n";



	} elsif ($para =~ s/^\\begin{exercise}\[(easy|challenging|tricky|computer project|project|little harder|harder|more challenging)\][ \n]*//) {
		$note = $1;
		close_paragraph();
		$exercise_num = $exercise_num+1;
		$the_num = get_exercise_number ();
		if ($para =~ s/^\\label{([^}]*)}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start note >$note< id >$theid< $the_num)\n";
			print $out "<exercise xml:id=\"$theid\" number=\"$the_num\">\n<statement>\n";
		} else {
			print "(exercise start note >$note< $the_num)\n";
			print $out "<exercise number=\"$the_num\">\n<statement>\n";
		}

		open_paragraph();
		print $out "<em>($note)</em><nbsp/><nbsp/>\n";

	} elsif ($para =~ s/^\\begin{exercise}\[(.*?)\][ \n]*//s) {
		$title = $1;
		$title =~ s|\$(.*?)\$|<m>$1</m>|sg;
		$index = "";
		if ($title =~ s/\\myindex{(.*?)}/$1/) {
			$index = $1;
		}
		close_paragraph();
		$exercise_num = $exercise_num+1;
		$the_num = get_exercise_number ();
		if ($para =~ s/^\\label{([^}]*)}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start title >$title< id >$theid< $the_num)\n";
			print $out "<exercise xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<title>$title</title>\n";
		} else {
			print "(exercise start title >$title< $the_num)\n";
			print $out "<exercise number=\"$the_num\">\n";
			print $out "<title>$title</title>\n";
		}
		if ($index ne "") {
			print $out "<index>$index</index>\n";
		}
		print $out "<statement>\n";
		open_paragraph();


	} elsif ($para =~ s/^\\begin{exercise}[ \n]*//) {
		close_paragraph();
		$exercise_num = $exercise_num+1;
		$the_num = get_exercise_number ();
		if ($para =~ s/^\\label{([^}]*)}[ \n]*//) {
			$theid = modify_id($1);
			print "(exercise start >$theid< $the_num)\n";
			print $out "<exercise xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<statement>\n";
		} else {
			print "(exercise start $the_num)\n";
			print $out "<exercise number=\"$the_num\">\n";
			print $out "<statement>\n";
		}
		open_paragraph();

	} elsif ($para =~ s/^\\end{exercise}[ \n]*\\exsol{//) {
		print "(exercise end)\n";
		print "(exsol start)\n";
		close_paragraph();
		print $out "</statement>\n<answer>\n"; 
		push @cltags, "exsol";
	} elsif ($para =~ s/^\\end{exercise}[ \n]*//) {
		print "(exercise end)\n";
		close_paragraph();
		print $out "</statement>\n</exercise>\n";

	} elsif ($para =~ s/^\\begin{example}[ \n]*//) {
		close_paragraph();
		$example_num = $example_num+1;
		$the_num = get_example_number ();
		if ($para =~ s/^\\label{([^}]*)}[ \n]*//) {
			$theid = modify_id($1);
			print "(example start >$theid<)\n";
			print $out "<example xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<statement>\n";
		} else {
			print "(example start)\n";
			print $out "<example number=\"$the_num\">\n";
			print $out "<statement>\n";
		}
		open_paragraph();
	} elsif ($para =~ s/^\\end{example}[ \n]*//) {
		close_paragraph();
		print $out "</statement>\n</example>\n";

	} elsif ($para =~ s/^\\begin{remark}[ \n]*//) {
		close_paragraph();
		$remark_num = $remark_num+1;
		$the_num = get_remark_number ();
		if ($para =~ s/^\\label{([^}]*)}[ \n]*//) {
			$theid = modify_id($1);
			print "(remark start >$theid<)\n";
			print $out "<remark xml:id=\"$theid\" number=\"$the_num\">\n";
			print $out "<statement>\n";
		} else {
			print "(remark start)\n";
			print $out "<remark number=\"$the_num\">\n";
			print $out "<statement>\n";
		}
		open_paragraph();
	} elsif ($para =~ s/^\\end{remark}[ \n]*//) {
		close_paragraph();
		print $out "</statement>\n</remark>\n";

	} elsif ($para =~ s/^\\begin{itemize}[ \n]*//) {
		close_paragraph();
		print "(begin itemize)\n";
		print $out "<ul>\n";
	} elsif ($para =~ s/^\\end{itemize}[ \n]*//) {
		close_item();
		print $out "</ul>\n";

	} elsif ($para =~ s/^\\begin{enumerate}\[(.*?)\][ \n]*//) {
		close_paragraph();
		print "(begin enumerate label >$1<)\n";
		print $out "<ol label=\"$1\">\n";
	} elsif ($para =~ s/^\\begin{enumerate}[ \n]*//) {
		close_paragraph();
		print "(begin enumerate)\n";
		print $out "<ol>\n";
	} elsif ($para =~ s/^\\end{enumerate}[ \n]*//) {
		close_item();
		print $out "</ol>\n";

	} elsif ($para =~ s/^\\item[ \n]*//) {
		print "(item)\n";
		open_item();
		open_paragraph();

	} elsif ($para =~ s/^([^\$\\{]*?)\}//) {
		$line = $1;
		print "closing tag after >$line<\n\n";
		print_line($line);
		$tagtoclose = pop @cltags;
		if ($tagtoclose eq "em") {
			print $out "</em>";
		} elsif ($tagtoclose eq "myquote") {
			print $out "</q>";
		} elsif ($tagtoclose eq "exsol") {
			print "(exsol end)\n";
			close_paragraph ();
			print $out "</answer>\n</exercise>\n";
		} elsif ($tagtoclose eq "footnote") {
			#FIXME: nested paragraphs??  Does this work?
			print $out "</fn>";
		} else {
			print "\n\nHUH???\n\nNo (or unknown =\"$tagtoclose\") tag to close\n\n";
		}



	} elsif ($para =~ s/^\\ldots//) {
		open_paragraph_if_not_open ();
		print "...\n";

	} elsif ($para =~ s/^\\noindent//) {
		print "(noindent do nothing)\n";
	} elsif ($para =~ s/^\\sectionnewpage//) {
		print "(sectionnewpage do nothing)\n";
	} elsif ($para =~ s/^\\nopagebreak(\[.\])?//) {
		print "(nopagebreak do nothing)\n";
	} elsif ($para =~ s/^\\pagebreak(\[.\])?//) {
		print "(pagebreak do nothing)\n";

	} elsif ($para =~ s/^\\ //) {
		print "( )\n";
		print $out " "; 
	} elsif ($para =~ s/^\\-//) {
		print "(-)\n";
		open_paragraph_if_not_open ();
		print $out "-"; 
	} elsif ($para =~ s/^\\medskip *//) {
		print "(medskip)\n";
		if ($inparagraph) {
			#print $out "</p><p><nbsp/></p><p><!--FIXME:this seems an ugly solution-->\n"; 
			print $out "</p><p><!--FIXME:this seems an ugly solution-->\n"; 
			
			# already skipping some space if not in paragraph?
			#} else {
			#print $out "<p><nbsp/></p><!--FIXME:this seems an ugly solution-->\n"; 
		}
	} elsif ($para =~ s/^\\bigskip *//) {
		print "(bigskip)\n";
		if ($inparagraph) {
			#print $out "</p><p><nbsp/></p><p><!--FIXME:this seems an ugly solution-->\n"; 
			print $out "</p><p><!--FIXME:this seems an ugly solution-->\n"; 

			# already skipping some space if not in paragraph?
			#} else {
			#print $out "<p><nbsp/></p><!--FIXME:this seems an ugly solution-->\n"; 
		}
	} elsif ($para =~ s/^\\\\//) {
		print "(BR)\n";
		if ($inparagraph) {
			#print $out "</p><p><!--FIXME:this seems an ugly solution-->"; 
			print $out "<diffyqsbr/>";
		}
		#FIXME: What to do if not in paragraph?  Is that even reasonable?
	} elsif ($para =~ s/^\\quad//) {
		print "(quad)\n";
		open_paragraph_if_not_open ();
		print $out "<nbsp/><nbsp/><nbsp/>"; 
	} elsif ($para =~ s/^\\qquad//) {
		print "(qquad)\n";
		open_paragraph_if_not_open ();
		print $out "<nbsp/><nbsp/><nbsp/><nbsp/><nbsp/><nbsp/>"; 
	} elsif ($para =~ s/^\\LaTeX//) {
		print "(LaTeX)\n";
		open_paragraph_if_not_open ();
		print $out "<latex />"; 

	} elsif ($para =~ s/^\\footnote{//) {
		print "(FOOTNOTE start)\n";
		open_paragraph_if_not_open ();
		print $out "<fn>"; 
		push @cltags, "footnote";



	} elsif ($para =~ s/^([^\\]+?)\$/\$/) {
		$line = $1;
		print_line($line);
	} elsif ($para =~ s/^([^\\]+?)\\/\\/) {
		$line = $1;
		print_line($line);
	} elsif ($para =~ s/^(\\[^ \n\r\t{]*)//) {
		print "\n\nHUH???\n\nUNHANDLED escape $1!\n$para\n\n";
		print_line($1);
		#$para = "";
	} else {
		print_line($para);
		$para = "";
	}
	if ($para eq "") {
		close_paragraph ();
	}
}

close_chapter ();

print $out <<END;
</book>
</mathbook>
END

close ($in); 
close ($out); 
 
print "\nDone!\n"; 