# -*-perl-*-
use strict;
use Data::Dumper;
use Test::More 
  #qw(no_plan); 
  tests => 42; 

my $map = "file:w3o.atm";

my $die_problem = 1; # there seems to be a problem dieing in an SAX handler, have to figure out how this works

open (STDERR, '>/dev/null'); # do not show warnings...

require_ok( 'XTM::Smile::SAX' );

sub mytest {
  my $slides = shift;
  my $s;
  {
    use XML::SAX::Writer;
    my $writer   = new XML::SAX::Writer          (Output   => \$s );
    use URI::file;
    my $expander = new XTM::Smile::SAX           (Handler          => $writer,
						  urlbase          => URI::file->cwd . "maps/",
						  default_format   => "%ti %ty %rd %ins %res",
						  tau_expr         => $map);
    use XML::SAX::ParserFactory;
    my $parser  = XML::SAX::ParserFactory->parser(Handler          => $expander,
						  RequiredFeatures => {
								       'http://xml.org/sax/features/validation' => 1,
								      }
						 );
    $parser->parse_string(qq|<?xml version="1.0" standalone="yes"?>
<slides name="Internet Technology II, 2001" 
	xmlns = "http://topicmaps.bond.edu.au/SlideML/"
        xmlns:astma = "http://topicmaps.bond.edu.au/astma/1.0/"
        xmlns:smile = "http://topicmaps.bond.edu.au/smile/1.0/">

  <institution>Bond University</institution>

$slides

</slides>|
		       );
}
#  print $s;
  {
    use XML::XPath;
    use XML::XPath::XMLParser;
    return XML::XPath->new(xml => $s);
  }
}

my $xp;

$xp = mytest ('');

is (@{ $xp->find ('/slides')}, 1, 'top level slides');
is (@{ $xp->find ('/slides/smile:slide')}, 0, 'no slide');
#is (@{ $xp->find ('/slides[@xmlns:smile]')}, 1, 'find namespace 1');

$xp = mytest (q|
  <astma:slide astma:tid="w3c-user-interface"/>
|);
is (@{ $xp->find ('/slides/smile:slide')},                              1, 'single slide, default map, default format');
is (@{ $xp->find ('/slides/smile:slide/smile:title')},                  1, 'title');
is (@{ $xp->find ('/slides/smile:slide/smile:types')},                  1, 'types');
is (@{ $xp->find ('/slides/smile:slide/smile:inlines')},                1, 'inlines');
is (@{ $xp->find ('/slides/smile:slide/smile:instances')},              1, 'instances');
is (@{ $xp->find ('/slides/smile:slide/smile:references')},             1, 'references');

$xp = mytest (q|
  <astma:default astma:tau_expr="file:w3o.atm"/>
  <astma:slide astma:tid="w3c-user-interface"/>
|);
is (@{ $xp->find ('/slides/smile:slide')},                              1, 'single slide, map, default format');
is (@{ $xp->find ('/slides/smile:slide/smile:title')},                  1, 'title');
is (@{ $xp->find ('/slides/smile:slide/smile:types')},                  1, 'types');
is (@{ $xp->find ('/slides/smile:slide/smile:inlines')},                1, 'inlines');
is (@{ $xp->find ('/slides/smile:slide/smile:instances')},              1, 'instances');
is (@{ $xp->find ('/slides/smile:slide/smile:references')},             1, 'references');

#default: %ti %ty %rd %ins %res

if (!$die_problem) {
eval {
  $xp = mytest (q|
		<astma:default astma:tau_expr="file:w3o.atmxxxxxx"/>
		<astma:slide astma:tid="w3c-user-interface"/>
		|);
  fail ("inexistent map: did not die -> not good");
}; if ($@) {
  pass ("inexistent map: died -> good!");   
}
}

$xp = mytest (q|
  <astma:default astma:tau_expr="file:w3o.atm"/>
  <astma:default astma:format="%ti"/>
  <astma:slide astma:tid="w3c-activity"/>
|);
is (@{ $xp->find ('/slides/smile:slide')},                              1, 'single slide');
is (@{ $xp->find ('/slides/smile:slide[@smile:tid = "w3c-activity"]')}, 1, 'tid');
is (@{ $xp->find ('/slides/smile:slide/smile:title')},                  1, 'title');

$xp = mytest (q|
  <astma:default astma:map="file:w3o.atm"/>
  <astma:default astma:format="%ti %xxx %ins[3-"/>
  <astma:slide astma:tid="w3c-activity"/>
|);
is (@{ $xp->find ('/slides/smile:slide')},                              1, 'single slide, buggy format');
is (@{ $xp->find ('/slides/smile:slide[@smile:tid = "w3c-activity"]')}, 1, 'tid');
is (@{ $xp->find ('/slides/smile:slide/smile:title')},                  1, 'title');

$xp = mytest (q|
  <astma:slide astma:tid="w3c-user-interface" astma:format="%ti %res"/>
|);
is (@{ $xp->find ('/slides/smile:slide')},                              1, 'single slide, override');
is (@{ $xp->find ('/slides/smile:slide/smile:title')},                  1, 'title');
is (@{ $xp->find ('/slides/smile:slide/smile:references')},             1, 'references');

foreach my $n (1..3) {
  foreach my $m ($n..3) {
    $xp = mytest (qq|
		  <astma:default astma:tau_expr="$map"/>
		  <astma:slide astma:tid="w3c-user-interface" astma:format="%in[$n-$m] %res[$n-$m]"/>
|);
    is (@{ $xp->find ('/slides/smile:slide')},                              1, "single slide, [$n-$m]");
    is (@{ $xp->find ('/slides/smile:slide//smile:reference')},       $m-$n+1, 'references');
    is (@{ $xp->find ('/slides/smile:slide//smile:instance')},        $m-$n+1, 'instances');
  }
}

__END__


exit;
#is (@{ $xp->find ('')}, 1, '');
is (@{ $xp->find ('')}, 1, '');
is (@{ $xp->find ('')}, 1, '');


#is (@{}, 1, '');



  <astma:slide astma:tid="w3c-activity" astma:continue="yes"/>
 
 
           my $nodeset = $xp->find('/html/body/p'); 



<!--
  <astma:default astma:format="<ul>/<text>%in(<ul>/<desc>%rd)[2-4]  %i %i[3-4] %<xxx>io[3-4] "/>
  <astma:default astma:format="%<ul>/<text>/<ul>/<desc>inrd[2-4]"/>
  <astma:default astma:format="%inrd[2-4]"/>
  <astma:default astma:format="%ty[2-4]"/>
  <astma:default astma:format="%in[2-4]"/>
  <astma:default astma:format="%ti"/>
-->


  <astma:slide astma:tid="w3c-user-interface" astma:continue="yes"/>

  <astma:slide astma:tid="w3c-activity" />


<!--
  <astma:slide astma:tid="w3c-activity" astma:continue="yes"/>
  <astma:slide astma:tid="w3c-activity" astma:format="" astma:continue="yes"/>
-->

<!--
  <astma:topic-template astma:parameter="t">
     FOR $r IN $t//resourceData
       <text>{$r}</text>
  </astma:topic-template>

  <slide title="web programming">
     <astma:topic-expand astma:tid="web-programming"/>
  </slide>
		      
  <slide title="web programming">
     <astma:topic astma:tid="web-programming">
        FOR $r IN $t//resourceData
          <text>{$r}</text>
     </astma:topic>
  </slide>
-->


<!--  
  <slide title="web programming">
     <astma:query>
        IN xxxx
        WHERE SOME $t SATISFIES [ tid: tosca ]
        RETURN
           FOR $b IN $t/baseName
              <name>{$b}</name>
      </astma:query>
    sfsfs
  </slide>
-->
