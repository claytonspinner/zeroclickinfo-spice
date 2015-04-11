package DDG::Spice::Population;
# ABSTRACT: Returns the population of a specified country

use strict;
use DDG::Spice;
use Locale::Country;

name "Population";
source "The World Bank";
icon_url "http://data.worldbank.org/profiles/datafinder/themes/datum/favicon.ico";
description "Returns the population for a specified country";
primary_example_queries "population of brazil", "population mexico";
secondary_example_queries "what is the population of china", "pop of spain";
category "facts";
topics "everyday";
code_url "https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Population.pm";
attribution github   => ["https://github.com/gregoriomartinez", "GregorioMartinez"],
            twitter  => ['http://twitter.com/gregemartinez','GregEMartinez'],
            web      => ["http://www.gmartinez.com", "Gregorio Martinez"];


triggers any => "population", "pop";

spice from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)';
spice to => 'http://api.worldbank.org/countries/$1/indicators/SP.POP.TOTL?per_page=2&MRV=1&format=json';
spice wrap_jsonp_callback => 1;

handle query_lc => sub {
    if (/(?:what\sis\sthe\s)?(?:population|pop\.?)\s(?:of)?\s?(.*)|(.*)\s(?:population|pop\.?)/) {
        my ($countryName, $countryCode);
        return if (!$1 && !$2);

        $countryName = $1 if $1;
        $countryName = $2 if $2;

        # Return alpha-3 country code
        $countryCode = country2code($countryName, LOCALE_CODE_ALPHA_3);

        if($countryCode) {
            $countryName = code2country(country2code($countryName, LOCALE_CODE_ALPHA_2), LOCALE_CODE_ALPHA_2);
        } else {
            $countryName = code2country(country2code(code2country($countryName, LOCALE_CODE_ALPHA_3), LOCALE_CODE_ALPHA_2), LOCALE_CODE_ALPHA_2);
            $countryCode = country2code($countryName, LOCALE_CODE_ALPHA_3);
        }

        return unless defined $countryName;

        # Check if the country string has a comma, split the string and only include the first element
        if (index($countryName, ',') != -1) {
            ($countryName) = split(',', $countryName);
        }

        # Ensure variables are defined before returning a result
        return unless (defined $countryCode and defined $countryName);
        return uc $countryCode, $countryName;
    }
    return;

};
1;
