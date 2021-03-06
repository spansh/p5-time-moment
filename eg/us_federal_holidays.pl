#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment;
use Time::Moment::Adjusters qw[ NthDayOfWeekInMonth ];

use enum qw[ Monday=1 Tuesday Wednesday Thursday Friday Saturday Sunday ];
use enum qw[ First=1 Second Third Fourth Last=-1 ];

use constant FirstMondayInMonth    => NthDayOfWeekInMonth(First, Monday);
use constant SecondMondayInMonth   => NthDayOfWeekInMonth(Second, Monday);
use constant ThirdMondayInMonth    => NthDayOfWeekInMonth(Third, Monday);
use constant LastMondayInMonth     => NthDayOfWeekInMonth(Last, Monday);
use constant FourthThursdayInMonth => NthDayOfWeekInMonth(Fourth, Thursday);

# Adjusts the date to the nearest workday
use constant NearestWorkday => sub {
    my ($tm) = @_;
    return $tm unless $tm->day_of_week > Friday;
    return $tm->plus_days($tm->day_of_week == Saturday ? -1 : +1);
};

# Federal law 5 USC § 6103 - HOLIDAYS
# http://www.law.cornell.edu/uscode/text/5/6103
sub compute_us_federal_holidays {
    @_ == 1 or @_ == 2 or die q<Usage: compute_us_federal_holidays(year [, inauguration = false])>;
    my ($year, $inauguration) = @_;

    my @dates;
    my $tm = Time::Moment->new(year => $year);

    # New Year’s Day, January 1.
    push @dates, $tm->with_month(1)
                    ->with_day_of_month(1)
                    ->with(NearestWorkday);

    # Birthday of Martin Luther King, Jr., the third Monday in January.
    push @dates, $tm->with_month(1)
                    ->with(ThirdMondayInMonth);

    # Inauguration Day, January 20 of each fourth year after 1965.
    if ($inauguration && $year % 4 == 1) {
        my $date = $tm->with_month(1)
                      ->with_day_of_month(20);

        # When January 20 falls on Sunday, the next succeeding day is selected.
        $date = $date->plus_days(1)
          if $date->day_of_week == Sunday;

        push @dates, $date
          unless $date->day_of_week == Saturday
              or $date->is_equal($dates[-1]);    # 1997, 2013, 2025 ...
    }

    # Washington’s Birthday, the third Monday in February.
    push @dates, $tm->with_month(2)
                    ->with(ThirdMondayInMonth);

    # Memorial Day, the last Monday in May.
    push @dates, $tm->with_month(5)
                    ->with(LastMondayInMonth);

    # Independence Day, July 4.
    push @dates, $tm->with_month(7)
                    ->with_day_of_month(4)
                    ->with(NearestWorkday);

    # Labor Day, the first Monday in September.
    push @dates, $tm->with_month(9)
                    ->with(FirstMondayInMonth);

    # Columbus Day, the second Monday in October.
    push @dates, $tm->with_month(10)
                    ->with(SecondMondayInMonth);

    # Veterans Day, November 11.
    push @dates, $tm->with_month(11)
                    ->with_day_of_month(11)
                    ->with(NearestWorkday);

    # Thanksgiving Day, the fourth Thursday in November.
    push @dates, $tm->with_month(11)
                    ->with(FourthThursdayInMonth);

    # Christmas Day, December 25.
    push @dates, $tm->with_month(12)
                    ->with_day_of_month(25)
                    ->with(NearestWorkday);

    return @dates;
}

# Test cases extracted from <http://www.opm.gov/Operating_Status_Schedules/fedhol/Index.asp>
my @tests = (
    [ 1997, '1997-01-01', '1997-01-20', '1997-02-17', '1997-05-26', '1997-07-04',
            '1997-09-01', '1997-10-13', '1997-11-11', '1997-11-27', '1997-12-25' ],
    [ 1998, '1998-01-01', '1998-01-19', '1998-02-16', '1998-05-25', '1998-07-03',
            '1998-09-07', '1998-10-12', '1998-11-11', '1998-11-26', '1998-12-25' ],
    [ 1999, '1999-01-01', '1999-01-18', '1999-02-15', '1999-05-31', '1999-07-05',
            '1999-09-06', '1999-10-11', '1999-11-11', '1999-11-25', '1999-12-24' ],
    [ 2000, '1999-12-31', '2000-01-17', '2000-02-21', '2000-05-29', '2000-07-04',
            '2000-09-04', '2000-10-09', '2000-11-10', '2000-11-23', '2000-12-25' ],
    [ 2001, '2001-01-01', '2001-01-15', '2001-02-19', '2001-05-28', '2001-07-04',
            '2001-09-03', '2001-10-08', '2001-11-12', '2001-11-22', '2001-12-25' ],
    [ 2002, '2002-01-01', '2002-01-21', '2002-02-18', '2002-05-27', '2002-07-04',
            '2002-09-02', '2002-10-14', '2002-11-11', '2002-11-28', '2002-12-25' ],
    [ 2003, '2003-01-01', '2003-01-20', '2003-02-17', '2003-05-26', '2003-07-04',
            '2003-09-01', '2003-10-13', '2003-11-11', '2003-11-27', '2003-12-25' ],
    [ 2004, '2004-01-01', '2004-01-19', '2004-02-16', '2004-05-31', '2004-07-05',
            '2004-09-06', '2004-10-11', '2004-11-11', '2004-11-25', '2004-12-24' ],
    [ 2005, '2004-12-31', '2005-01-17', '2005-02-21', '2005-05-30', '2005-07-04',
            '2005-09-05', '2005-10-10', '2005-11-11', '2005-11-24', '2005-12-26' ],
    [ 2006, '2006-01-02', '2006-01-16', '2006-02-20', '2006-05-29', '2006-07-04',
            '2006-09-04', '2006-10-09', '2006-11-10', '2006-11-23', '2006-12-25' ],
    [ 2007, '2007-01-01', '2007-01-15', '2007-02-19', '2007-05-28', '2007-07-04',
            '2007-09-03', '2007-10-08', '2007-11-12', '2007-11-22', '2007-12-25' ],
    [ 2008, '2008-01-01', '2008-01-21', '2008-02-18', '2008-05-26', '2008-07-04',
            '2008-09-01', '2008-10-13', '2008-11-11', '2008-11-27', '2008-12-25' ],
    [ 2009, '2009-01-01', '2009-01-19', '2009-02-16', '2009-05-25', '2009-07-03',
            '2009-09-07', '2009-10-12', '2009-11-11', '2009-11-26', '2009-12-25' ],
    [ 2010, '2010-01-01', '2010-01-18', '2010-02-15', '2010-05-31', '2010-07-05',
            '2010-09-06', '2010-10-11', '2010-11-11', '2010-11-25', '2010-12-24' ],
    [ 2011, '2010-12-31', '2011-01-17', '2011-02-21', '2011-05-30', '2011-07-04',
            '2011-09-05', '2011-10-10', '2011-11-11', '2011-11-24', '2011-12-26' ],
    [ 2012, '2012-01-02', '2012-01-16', '2012-02-20', '2012-05-28', '2012-07-04',
            '2012-09-03', '2012-10-08', '2012-11-12', '2012-11-22', '2012-12-25' ],
    [ 2013, '2013-01-01', '2013-01-21', '2013-02-18', '2013-05-27', '2013-07-04',
            '2013-09-02', '2013-10-14', '2013-11-11', '2013-11-28', '2013-12-25' ],
    [ 2014, '2014-01-01', '2014-01-20', '2014-02-17', '2014-05-26', '2014-07-04',
            '2014-09-01', '2014-10-13', '2014-11-11', '2014-11-27', '2014-12-25' ],
    [ 2015, '2015-01-01', '2015-01-19', '2015-02-16', '2015-05-25', '2015-07-03',
            '2015-09-07', '2015-10-12', '2015-11-11', '2015-11-26', '2015-12-25' ],
    [ 2016, '2016-01-01', '2016-01-18', '2016-02-15', '2016-05-30', '2016-07-04',
            '2016-09-05', '2016-10-10', '2016-11-11', '2016-11-24', '2016-12-26' ],
    [ 2017, '2017-01-02', '2017-01-16', '2017-02-20', '2017-05-29', '2017-07-04',
            '2017-09-04', '2017-10-09', '2017-11-10', '2017-11-23', '2017-12-25' ],
    [ 2018, '2018-01-01', '2018-01-15', '2018-02-19', '2018-05-28', '2018-07-04',
            '2018-09-03', '2018-10-08', '2018-11-12', '2018-11-22', '2018-12-25' ],
    [ 2019, '2019-01-01', '2019-01-21', '2019-02-18', '2019-05-27', '2019-07-04',
            '2019-09-02', '2019-10-14', '2019-11-11', '2019-11-28', '2019-12-25' ],
    [ 2020, '2020-01-01', '2020-01-20', '2020-02-17', '2020-05-25', '2020-07-03',
            '2020-09-07', '2020-10-12', '2020-11-11', '2020-11-26', '2020-12-25' ],
);

use Test::More 0.88;

foreach my $test (@tests) {
    my ($year, @exp) = @$test;
    my @got = map {
        $_->strftime('%Y-%m-%d')
    } compute_us_federal_holidays($year);
    is_deeply([@got], [@exp], "U.S. federal holidays for year $year");
}

done_testing();
