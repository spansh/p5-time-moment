#!/usr/bin/perl
use strict;
use warnings;

use Benchmark     qw[];
use DateTime      qw[];
use Time::Moment  qw[];
use Time::Piece   qw[];
use POSIX         qw[];

{
    print "Benchmarking constructor: ->new()\n";
    my $zone = DateTime::TimeZone->new(name => 'UTC');
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $dt = DateTime->new(
                year       => 2012,
                month      => 12,
                day        => 24,
                hour       => 15,
                minute     => 30,
                second     => 45,
                nanosecond => 123456789,
                time_zone  => $zone,
            );
        },
        'Time::Moment' => sub {
            my $tm = Time::Moment->new(
                year       => 2012,
                month      => 12,
                day        => 24,
                hour       => 15,
                minute     => 30,
                second     => 45,
                nanosecond => 123456789,
                offset     => 0
            );
        },
    });
}

{
    print "\nBenchmarking constructor: ->now()\n";
    my $zone = DateTime::TimeZone->new(name => 'local');
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $dt = DateTime->now(time_zone => $zone);
        },
        'Time::Moment' => sub {
            my $tm = Time::Moment->now;
        },
        'Time::Piece' => sub {
            my $tp = Time::Piece::localtime();
        },
        'localtime()' => sub {
            my @tm = localtime();
        },
    });
}

{
    print "\nBenchmarking constructor: ->now_utc()\n";
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $dt = DateTime->now;
        },
        'Time::Moment' => sub {
            my $tm = Time::Moment->now_utc;
        },
        'Time::Piece' => sub {
            my $tp = Time::Piece::gmtime();
        },
        'gmtime()' => sub {
            my @tm = gmtime();
        },
    });
}

{
    print "\nBenchmarking constructor: ->from_epoch()\n";
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $dt = DateTime->from_epoch(epoch => 0);
        },
        'Time::Moment' => sub {
            my $tm = Time::Moment->from_epoch(0);
        },
        'Time::Piece' => sub {
            my $tp = Time::Piece::gmtime(0);
        },
    });
}

{
    print "\nBenchmarking accessor: ->year()\n";
    my $dt = DateTime->now;
    my $tm = Time::Moment->now;
    my $tp = Time::Piece::localtime();
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $year = $dt->year;
        },
        'Time::Moment' => sub {
            my $year = $tm->year;
        },
        'Time::Piece' => sub {
            my $year = $tp->year;
        },
    });
}

{
    print "\nBenchmarking arithmetic: +10 days -10 days\n";
    my $dt = DateTime->now;
    my $tm = Time::Moment->now_utc;
    my $tp = Time::Piece::gmtime();
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $r = $dt->add(days => 10)->subtract(days => 10);
        },
        'Time::Moment' => sub {
            my $r = $tm->plus_days(10)->minus_days(10);
        },
        'Time::Piece' => sub {
            my $r = $tp->add(86400 * 10)->add(-86400 * 10);
        },
    });
}

{
    print "\nBenchmarking: at end of current month\n";
    my $dt = DateTime->now;
    my $tm = Time::Moment->now_utc;
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            $dt = $dt->set_day(1)
                     ->add(months => 1)
                     ->subtract(days => 1);
        },
        'Time::Moment' => sub {
            $tm = $tm->with_day_of_month(1)
                     ->plus_months(1)
                     ->minus_days(1);
        },
    });
}

{
    print "\nBenchmarking strftime: ->strftime('%FT%T')\n";
    my $dt = DateTime->now;
    my $tm = Time::Moment->now;
    my $tp = Time::Piece::localtime();
    my @lt = localtime();
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $string = $dt->strftime('%FT%T');
        },
        'Time::Moment' => sub {
            my $string = $tm->strftime('%FT%T');
        },
        'Time::Piece' => sub {
            my $string = $tp->strftime('%FT%T');
        },
        'POSIX::strftime' => sub {
            my $string = POSIX::strftime('%FT%T', @lt);
        },
    });
}

{
    print "\nBenchmarking sort: 1000 instants\n";

    my @epochs = map { 
        int(rand(365.2425 * 50) * 86400 + rand(86400))
    } (1..1000);

    my @dt = map {
        DateTime->from_epoch(epoch => $_)
    } @epochs;

    my @tm = map {
        Time::Moment->from_epoch($_)
    } @epochs;

    my @tp = map {
        scalar Time::Piece::gmtime($_);
    } @epochs;

    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my @sorted = sort { $a->compare($b) } @dt;
        },
        'Time::Moment' => sub {
            my @sorted = sort { $a->compare($b) } @tm;
        },
        'Time::Piece' => sub {
            my @sorted = sort { $a->compare($b) } @tp;
        },
    });
}

eval {
    require DateTime::Format::ISO8601;
    require DateTime::Format::RFC3339;

    my $string = '2013-12-24T12:34:56.123456+02:00';

    print "\nBenchmarking parsing: '$string'\n";
    my $rfc_p  = DateTime::Format::RFC3339->new;
    my $iso_p  = DateTime::Format::ISO8601->new;
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $tm = Time::Moment->from_string($string);
        },
        'DT::F::ISO8601' => sub {
            my $dt = $iso_p->parse_datetime($string);
        },
        'DT::F::RFC3339' => sub {
            my $dt = $rfc_p->parse_datetime($string);
        },
    });
};

