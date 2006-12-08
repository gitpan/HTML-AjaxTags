=head1 NAME

HTML::AjaxTags - AjaxTags implementation

=head1 SYNOPSIS

  use HTML::AjaxTags;

=head1 DESCRIPTION

HTML::AjaxTags is a re-write of AjaxTags (http://ajaxtags.sourceforge.net/index.html) for perl.

Most of the following documentation was taken directly from the AjaxTags web site.  Changes were made to accommodate for calling AjaxTags methods though perl instead of jsp tags.

=cut


=head1 PARAMETER DESCRIPTIONS

=over 

The following parameters can be used in multiple HTML::AjaxTags methods.  The avilabiliy and required use of each parameter will be listed under the description for the method itself.

=item * baseUrl

=over

URL of server-side action or servlet that processes search and returns list of values used in autocomplete dropdown; expression language (EL) is supported for this field

=back

=item * source

=over

Text field where label of autocomplete selection will be populated; also the field in which the user types out the search string

=back

=item * sourceClass

=over

The CSS class name of the elements to which the callout will be attached

=back


=item * target

=over

Text field where value of autocomplete selection will be populated

=back

=item * parameters

=over

A comma-separated list of parameters to pass to the server-side action or servlet

=back

=item * eventType 

=over

Specifies the event type to attach to the source field(s)

=back

=item * postFunction

=over

Function to execute after Ajax is finished, allowing for a chain of additional functions to execute

=back

=item * emptyFunction

=over

Function to execute if there is an empty response

=back

=item * errorFunction

=over

Function to execute if there is a server exception (non-200 HTTP response)

=back



=back

=cut


package HTML::AjaxTags;

use strict;
use warnings;

our $VERSION = '0.04';

sub new {
    my $class = shift;
        bless {}, $class;

}


=head2 B<autoComplete(%params)>

=over

The autocomplete tag allows one to retrieve a list of probable values from a backend servlet (or other server-side control) and display them in a dropdown beneath an HTML text input field. The user may then use the cursor and ENTER keys or the mouse to make a selection from that list of labels, which is then populated into the text field. This JSP tag also allows for a second field to be populated with the value or ID of the item in the dropdown.

=over

=item B<Required Parameters>

=item * baseUrl

=item * source

=item * target

=item * parameters

=item * className

=over 

CSS class name to apply to the popup autocomplete dropdown

=back

=item B<Optional Parameters>

=item * indicator

=over

ID of indicator region that will show during Ajax request call

=back

=item * appendSeparator

=over

The separator to use for the target field when values are appended [default=space]. If appendValue is not set or is set to "false", this parameter has no effect.

=back

=item * minimumCharacters

=over

Minimum number of characters needed before autocomplete is executed

=back

=item * var

=over

Name of the JavaScript object created

=back

=item * attachTo

=over

Name of the JavaScript object to which autocompleter will attach. You must define 'var' for this to work.

=back

=back

=back

=cut

sub autoComplete {
    my $self = shift;
    my %data = ('minimumCharacters',1,
                 'className','autocomplete',
                 'jsFunc','AjaxJspTag.Autocomplete',
                 @_);

    my @elements;

    push @elements, qq[parameters:"$data{parameters}"],
                    qq[parser:new ResponseXmlToHtmlListParser()],
                    qq[className:"$data{className}"];

    push @elements, qq[target:"$data{target}"] if $data{target};
    push @elements, qq[source:"$data{source}"] if $data{source};
    push @elements, qq[appendSeparator:"$data{appendSeparator}"] if $data{appendSeparator};
    push @elements, qq[postFunction:$data{postFunction}] if $data{postFunction};
    push @elements, qq[errorFunction:$data{errorFunction}] if $data{errorFunction};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parser:"$data{parser}"] if $data{parser};
    push @elements, qq[indicator:"$data{indicator}"] if $data{indicator};
    push @elements, qq[minimumCharacters:"$data{minimumCharacters}"] if $data{minimumCharacters};
    

    my $elem = join ',', @elements;

    my $var = $data{var} ? "$data{var} = " : "";

    my $scriptTag = <<END;
<script type="text/javascript">
    $var new $data{jsFunc} (
        "$data{baseUrl}", {
        $elem
    })
</script>

END
        
    return $scriptTag;

}



=head2 B<callout(%params)>

=over

The callout tag is an easy way to attach a callout or popup balloon to any HTML element supporting an onclick event. The style of this callout is fairly flexible, but generally has a header/title, a close link ('X'), and the content itself, of course. All of this (since AjaxTags 1.2) is handled by the OverLIBMWS JavaScript library. See http://www.macridesweb.com/oltest/ for complete instructions on using OverLIBMWS.

=over

=item B<Required Parameters>

=item * baseUrl

=item * source OR sourceClass

=item * parameters

=item B<Optional Parameters>

=item * var

=over

Name of the JavaScript object created

=back

=item * attachTo

=over

Name of the JavaScript object to which callout will attach. You must define 'var' for this to work.

=back

=item * title

=over

Title for callout's box header. If useTitleBar==false and no title is specified, then the value attribute of the returned XML will be used as the title.

=back

=item * overlib

=over 

Options for OverLib

=back

=item * preFunction

=item * postFunction

=item * errorFunction

=back

=back

=cut


sub callout {
    my $self = shift;
    my %data = (@_);

    my @elements;
    push @elements,qq[parameters: "$data{parameters}"];

    push @elements, qq[source: "$data{source}"] if $data{source};
    push @elements, qq[sourceClass: "$data{sourceClass}"] if $data{sourceClass};
    push @elements, qq[title: "$data{title}"] if $data{title};
    push @elements, qq[eventType: "$data{eventType}"] if $data{eventType};
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[overlib:"$data{overlib}"] if $data{overlib};
    push @elements, qq[parser: $data{parser}] if $data{parser};

    my $var = $data{var} ? "$data{var} = " : ""; 

    my $elem = join ',', @elements;

    my $source = '';


    if ($data{source}) {
        $source = qq[document.getElementById("$data{source}").onmouseover = cout.calloutOpen.bindAsEventListener(cout);];
        $source .= qq[document.getElementById("$data{source}").onmouseout = cout.calloutClose.bindAsEventListener(cout);];
    } 

    my $scriptTag = <<END;
<script type="text/javascript">
    $var new AjaxJspTag.Callout(
        "$data{baseUrl}", {
        $elem
    })
    $source
</script>

END

    return $scriptTag;

}



=head2 B<htmlContent(%params)>

=over

The HTML content tag allows you to fill a region on the page (often a DIV tag) with any HTML content pulled from another webpage. The AJAX action may be activated by attaching it to an anchor link or form field.

This tag expects an HTML response instead of XML and the AJAX function will not parse it as XML; it will simply insert the content of the response as is. 


=over

=item B<Required Parameters>

=item * baseUrl

=item * source OR sourceClass

=item * target

=item * parameters


=item B<Optional Parameters>

=item * var

=over

Name of the JavaScript object created

=back

=item * attachTo

=over

Name of the JavaScript object to which htmlContent will attach. You must define 'var' for this to work.

=back

=item * eventType

=item * postFunction

=item * errorFunction

=back

=back

=cut



sub htmlContent {
    my $self = shift;
    my %data = (@_); 

    my @elements;
    push @elements, qq[parameters: "$data{parameters}"];

    push @elements, qq[source: "$data{source}"] if $data{source};
    push @elements, qq[sourceClass: "$data{sourceClass}"] if $data{sourceClass};
    push @elements, qq[target: "$data{target}"] if $data{target};
    push @elements, qq[contentXmlName: "$data{contentXmlName}"] if $data{contentXmlName};
    push @elements, qq[eventType: "$data{eventType}"] if $data{eventType};
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[emptyFunction: $data{emptyFunction}] if $data{emptyFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parser:$data{parser}] if $data{parser};

    my $elem = join ',',@elements;

    my $var = $data{var} ? "$data{var} = " : "";

    my $scriptTag = <<END;
<script type="text/javascript">
    $var new AjaxJspTag.HtmlContent(
        "$data{baseUrl}", {
         $elem
    })
</script>

END

    return $scriptTag;

}




=head2 B<portlet(%params)>

=over

The portlet tag simulates a a href="http://www.jcp.org/en/jsr/detail?id=168"JSR-168/a style portlet by allowing you to define a portion of the page that pulls content from another location using Ajax with or without a periodic refresh.

This tag expects an HTML response instead of XML and the AJAX function will not parse it as XML; it will simply insert the content of the response as is.

=over

=item B<Required Parameters>

=item * baseUrl

=item * source

=item * title 

=over

Title for portlet header

=back

=item * classNamePrefix

=over

CSS class name prefix to use for the portlet's 'Box', 'Tools', 'Refresh', 'Size', 'Close', 'Title', and 'Content' elements

=back

=item B<Optional Parameters>

=item * var

=over 

Name of the JavaScript object created

=back

=item * attachTo

=over

Name of the JavaScript object to which portlet will attach. You must define 'var' for this to work.

=back

=item * parameters

=item * postFunction

=item * emptyFunction

=item * errorFunction

=item * imageClose

=over

Image used for the close icon

=back

=item * imageMaximize

=over

Image used for the maximize icon

=back

=item * imageMinimize

=over

Image used for the minimize icon

=back

=item * imageRefresh

=over

Image used for the refresh icon

=back

=item * refreshPeriod

=over

The time (in seconds) the portlet waits before automatically refreshing its content. If no period is specified, the portlet will not refresh itself automatically, but must be commanded to do so by clicking the refresh image/link (if one is defined). Lastly, the refresh will not occur until after the first time the content is loaded, so if executeOnLoad is set to false, the refresh will not begin until you manually refresh the first time.

=back

=item * executeOnLoad

=over

Indicates whether the portlet's content should be retrieved when the page loads [default=true]

=back

=item * expireDays

=over

Number of days cookie should persist

=back

=item * expireHours

=over

Number of hours cookie should persist

=back

=item * expireMinutes

=over

Number of minutes cookie should persist

=back

=back

=back

=cut


sub portlet {
    my $self = shift;
    my %data = ('classNamePrefix','portlet',
                @_);

    my @elements;
    my $prefix = $data{classNamePrefix}; 
    push @elements, qq[classNamePrefix: "$data{classNamePrefix}"],
                    qq[title: "$data{title}"],
                    qq[source: "$data{source}"];


    push @elements, qq[parameters: "$data{parameters}"] if $data{parameters};
    push @elements, qq[imageClose: "$data{imageClose}"] if $data{imageClose};
    push @elements, qq[imageMaximize: "$data{imageMaximize}"] if $data{imageMaximize};
    push @elements, qq[imageMinimize: "$data{imageMinimize}"] if $data{imageMinimize};
    push @elements, qq[imageRefresh: "$data{imageRefresh}"] if $data{imageRefresh};
    push @elements, qq[refreshPeriod: "$data{refreshPeriod}"] if $data{refreshPeriod};
    push @elements, qq[executeOnLoad: "$data{executeOnLoad}"] if $data{executeOnLoad};
    push @elements, qq[expireDays: "$data{expireDays}"] if $data{expireDays};
    push @elements, qq[expireHours: "$data{expireHours}"] if $data{expireHours};
    push @elements, qq[expireMinutes: "$data{expireMinutes}"] if $data{expireMinutes};
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[emptyFunction: $data{emptyFunction}] if $data{emptyFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parser:"$data{parser}"] if $data{parser};

    my $elem = join ',',@elements;
    my $var = "$data{var} = " ? $data{var} : "aj_$data{source} = ";


my $box_class = $prefix . 'Box';
my $tools_class = $prefix . 'Tools';
my $refresh_class = $prefix . 'Refresh'; my $size_class = $prefix . 'Size'; my $close_class = $prefix . 'Close'; my $title_class = $prefix . 'Title'; my $content_class = $prefix . 'Content';


    my $scriptTag = <<END;
<div id="$data{source}Area" class="portletArea">
  <div id="$data{source}" class="$box_class">
    <div id="$data{source}Tools" class="$tools_class">
      <img id="$data{source}Refresh" class="$refresh_class" src="$data{imageRefresh}"/>
      <img id="$data{source}Size" class="$size_class" src="$data{imageMinimize}"/>
      <img id="$data{source}Close" class="$close_class" src="$data{imageClose}"/>
    </div>
  <div id="$data{source}Title" class="$title_class">$data{title}</div>
  <div id="$data{source}Content" class="$content_class"></div> </div> <script type="text/javascript">
    $var new AjaxJspTag.Portlet(
        "$data{baseUrl}", {
        $elem
    });
</script>

END

    return $scriptTag;

}





=head2 B<select(%params)>

=over

The select tag allows one to retrieve a list of values from a backend servlet (or other server-side control) and display them in another HTML select box.

=over

=item B<Required Parameters>

=item * baseUrl

=item * source

=item * target


=item B<Optional Parameters>

=item * var

=over

Name of the JavaScript object created

=back

=item * attachTo

=over

Name of the JavaScript object to which select will attach. You must define 'var' for this to work.

=back

=item * parameters

=item * eventType

=over

Specifies the event type to attach to the source field(s)

=back

=item * defaultOptions 

=over

A comma-seperated list of values of options to be marked as selected by default if they exist in the new set of options

=back

=item * executeOnLoad

=over

Indicates whether the target select/dropdown should be populated when the object is initialized (this is essentially when the form loads) [default=false]

=back

=item * preFunction

=item * postFunction

=item * errorFunction

=item * parser

=over 

The response parser to implement [default=ResponseHtmlParser]

=back

=back

=back

=cut


sub select {
    my $self = shift;
    my %data = (@_);

    my @elements;

    push @elements, qq[target: "$data{target}"],
                    qq[source: "$data{source}"];

    
    push @elements, qq[eventType: "$data{eventType}"] if $data{eventType};
    push @elements, qq[preFunction: $data{preFunction}] if $data{preFunction};
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parameters:"$data{parameters}"] if $data{parameters};
    push @elements, qq[parser:"$data{parser}"] if $data{parser};
    push @elements, qq[defaultOptions:"$data{defaultOptions}"] if $data{defaultOptions};
    push @elements, qq[executeOnLoad:"$data{executeOnLoad}"] if $data{executeOnLoad};

    my $elem = join ',', @elements;

    my $var = $data{var} ? "$data{var} = " : "";


    my $scriptTag = <<END;
<script type="text/javascript">
    $var new AjaxJspTag.Select(
        "$data{baseUrl}", {
        $elem
    })
</script>

END
    return $scriptTag;

}




=head2 B<tabPanel(%params)>

=over

Provides a tabbed page view of content from different resources.

=over

=item B<Required Parameters>

=item * panelStyleId

=item * contentStyleId

=item * currentStyleId

=item * tab

=over

Tab is an array reference of hash references.  Each hash reference describes a single tab in the tabPanel. Each hash reference must include:

=item * baseUrl

=item * caption

=over 

The caption for this tab

=back

=back

Optional aruments include:

=over

=item * parameters

=item * defaultTab

=over

Indicates whether this tab is the initial one loaded [true|false]

=back

=back

=item B<Optional Parameters>

=item * var

=over 

Name of the JavaScript object created

=back

=item * attachTo

=over 

Name of the JavaScript object to which tabPanel will attach. You must define 'var' for this to work.

=back

=item * preFunction

=item * postFunction

=item * errorFunction

=item * parser

=over 

The response parser to implement [default=ResponseHtmlParser]

=back

=back

=back

=cut



sub tabPanel {
    my $self = shift;
    my %data = ('panelStyleId','tabPanel',
                'contentStyleId','tabContent',
                'currentStyleClass','ajaxCurrentTab',
                @_);

    my @elements;

    push @elements, qq[parameters: params],
                    qq[source: elem],
                    qq[target: "$data{contentStyleId}"],
                    qq[currentStyleClass: "$data{currentStyleId}"];

    
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[emptyFunction: $data{emptyFunction}] if $data{emptyFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[var:"$data{var}"] if $data{var};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parser:"$data{parser}"] if $data{parser};

    my $elem = join ',', @elements;


    my $tabs;
    my $defaultUrl;
    my $defaultParams;
    foreach my $tab (@{$data{tab}}) {
         my $currTag = '';
         if ($tab->{defaultTab} eq 'true') { 
             $currTag = qq[ class="$data{currentStyleId}" ];
             $defaultUrl = $tab->{baseUrl};
             $defaultParams = $tab->{parameters};
         }
         $tabs .= <<END;
<li><a $currTag href="javascript://nop/" onclick="executeAjaxTab(this, \$('tabPanel'), 'ajaxCurrentTab', '$tab->{baseUrl}','$tab->{parameters}', ''); return false;">$tab->{caption}</a></li>

END
    }

    my $scriptTag = <<END;
<div id="$data{panelStyleId}" class="tabPanel"> <ul>
   $tabs
</ul>
</div>
<div id="$data{contentStyleId}" class="tabContent"></div> <script type="text/javascript">
    window.executeAjaxTab = function (elem, panelId, currentClass, url, params) {
        var myAjax = new AjaxJspTag.TabPanel(url, {
        $elem
      });
    }

    executeAjaxTab(null, \$('tabPanel'), '$data{currentStyleId}', '$defaultUrl', '$defaultParams', '');
    addOnLoadEvent(function() {window.executeAjaxTab(null, \$('tabPanel'), '$data{currentStyleId}', '$defaultUrl', '$defaultParams', '');});

</script>

END


    return $scriptTag;
}



=head2 B<toggle(%params)>

=over

The toggle tag will change the value of a hidden form field between true and false, toggle an image between two source files, and replace the inner HTML content of another tag (div, span, etc).

=over

=item B<Required Parameters>

=item * baseUrl

=item * image

=over

Image tag ID that will be toggled on/off

=back

=item * state

=over

ID of hidden form field used to hold the current state

=back

=item * stateXmlName

=over

Name of the XML property specifying the state in the returning XML

=back

=item * imagePattern

=over

URL pattern of images used to indicate different status

=back

=item B<Optional Parameters>

=item * parameters

=item * eventType

=item * postFunction

=item * emptyFunction

=item * errorFunction

=back

=back

=cut


sub toggle {
    my $self = shift;
    my %data = (@_);

    my @elements;

    push @elements, qq[image: "$data{image}"],
                    qq[state: "$data{state}"],
                    qq[stateXmlName: "$data{stateXmlName}"],
                    qq[imagePattern: "$data{imagePattern}"];

    push @elements, qq[parameters: "$data{parameters}"] if $data{parameters};
    push @elements, qq[eventType: "$data{eventType}"] if $data{eventType};
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[emptyFunction: $data{emptyFunction}] if $data{emptyFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[var:"$data{var}"] if $data{var};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parser:"$data{parser}"] if $data{parser};

    my $elem = join ',', @elements;


    my $scriptTag = <<END;
<script type="text/javascript">
    new AjaxJspTag.Toggle(
        "$data{baseUrl}", {
        $elem
    })
</script>

END

    return $scriptTag;

}



=head2 B<updateField(%params)>

=over

Builds the JavaScript required to update one or more form fields based on the value of another single field.

=over

=item B<Required Parameters>

=item * baseUrl

=item * source

=item * target

=item * parameters

=item * action

=over

ID of form button or image tag that will fire the onclick event

=back

=item B<Optional Parameters>

=item * eventType

=item * postFunction

=item * emptyFunction

=item * errorFunction

=back

=back

=cut


sub updateField {
    my $self = shift;
    my %data = (@_);

    my @elements;

    push @elements, qq[source: "$data{source}"],
                    qq[target: "$data{target}"],
                    qq[action: "$data{action}"],
                    qq[parser: new ResponseXmlParser()],
                    qq[parameters: "$data{parameters}"];

  
    push @elements, qq[eventType: "$data{eventType}"] if $data{eventType};
    push @elements, qq[postFunction: $data{postFunction}] if $data{postFunction};
    push @elements, qq[emptyFunction: $data{emptyFunction}] if $data{emptyFunction};
    push @elements, qq[errorFunction: $data{errorFunction}] if $data{errorFunction};
    push @elements, qq[var:"$data{var}"] if $data{var};
    push @elements, qq[attachTo:"$data{attachTo}"] if $data{attachTo};
    push @elements, qq[parser:"$data{parser}"] if $data{parser};

    my $elem = join ',',@elements;


    my $scriptTag = <<END;
<script type="text/javascript">
    new AjaxJspTag.UpdateField(
        "$data{baseUrl}", {
        $elem
    })
</script>

END
    return $scriptTag;

}



sub area {
    my $self = shift;
    my %data = (@_);

    my @elements;
    push @elements, qq[parameters: "$data{parameters}"];

    ## TODO Complete function

}


sub anchors {
    my $self = shift;
    my %data = (@_);

    my @elements;
    push @elements, qq[target: "$data{target}"];
  
    ## TODO Complete function

}



# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__



=head1 AUTHOR

Kevin McGrath, kmcgrath@baknet.com

=head1 SEE ALSO

perl(1)

=cut

