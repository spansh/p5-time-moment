#ifndef __MOMENT_H__
#define __MOMENT_H__
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "dt_core.h"

#ifndef _MSC_VER
#  include <stdint.h>
#else
#  if _MSC_VER >= 1600
#   include <stdint.h>
#  else
    typedef __int32             int32_t;
    typedef __int64             int64_t;
    typedef unsigned __int32    uint32_t;
    typedef unsigned __int64    uint64_t;
#  endif
#  ifndef INT64_C
#   define INT64_C(x) x##i64
#  endif
#endif

#define SECS_PER_DAY      86400
#define NANOS_PER_SEC     1000000000

#define MIN_UNIT_YEARS      INT64_C(-10000)
#define MAX_UNIT_YEARS      INT64_C(10000)
#define MIN_UNIT_MONTHS     INT64_C(-120000)
#define MAX_UNIT_MONTHS     INT64_C(120000)
#define MIN_UNIT_WEEKS      INT64_C(-521775)
#define MAX_UNIT_WEEKS      INT64_C(521775)
#define MIN_UNIT_DAYS       INT64_C(-3652425)
#define MAX_UNIT_DAYS       INT64_C(3652425)
#define MIN_UNIT_HOURS      INT64_C(-87658200)
#define MAX_UNIT_HOURS      INT64_C(87658200)
#define MIN_UNIT_MINUTES    INT64_C(-5259492000)
#define MAX_UNIT_MINUTES    INT64_C(5259492000)
#define MIN_UNIT_SECONDS    INT64_C(-315569520000)
#define MAX_UNIT_SECONDS    INT64_C(315569520000)
#define MIN_UNIT_MILLIS     INT64_C(-315569520000000)
#define MAX_UNIT_MILLIS     INT64_C(315569520000000)
#define MIN_UNIT_MICROS     INT64_C(-315569520000000000)
#define MAX_UNIT_MICROS     INT64_C(315569520000000000)

#define MIN_RANGE           INT64_C(86400)        /* 0001-01-01T00:00:00Z */
#define MAX_RANGE           INT64_C(315537983999) /* 9999-12-31T23:59:59Z */
#define UNIX_EPOCH          INT64_C(62135683200)  /* 1970-01-01T00:00:00Z */
#define MIN_EPOCH_SEC       INT64_C(-62135596800) /* 0001-01-01T00:00:00Z */
#define MAX_EPOCH_SEC       INT64_C(253402300799) /* 9999-12-31T23:59:59Z */

#define VALID_EPOCH_SEC(s) \
    (s >= MIN_EPOCH_SEC && s <= MAX_EPOCH_SEC)

typedef struct {
    int64_t sec;
    int32_t nsec;
    int32_t offset;
} moment_t;

typedef enum {
    MOMENT_UNIT_YEARS=0,
    MOMENT_UNIT_MONTHS,
    MOMENT_UNIT_WEEKS,
    MOMENT_UNIT_DAYS,
    MOMENT_UNIT_HOURS,
    MOMENT_UNIT_MINUTES,
    MOMENT_UNIT_SECONDS,
    MOMENT_UNIT_MILLIS,
    MOMENT_UNIT_MICROS,
    MOMENT_UNIT_NANOS,
} moment_unit_t;

typedef enum {
    MOMENT_COMPONENT_YEAR=0,
    MOMENT_COMPONENT_MONTH_OF_YEAR,
    MOMENT_COMPONENT_WEEK_OF_YEAR,
    MOMENT_COMPONENT_DAY_OF_YEAR,
    MOMENT_COMPONENT_DAY_OF_QUARTER,
    MOMENT_COMPONENT_DAY_OF_MONTH,
    MOMENT_COMPONENT_DAY_OF_WEEK,
    MOMENT_COMPONENT_HOUR_OF_DAY,
    MOMENT_COMPONENT_MINUTE_OF_HOUR,
    MOMENT_COMPONENT_MINUTE_OF_DAY,
    MOMENT_COMPONENT_SECOND_OF_MINUTE,
    MOMENT_COMPONENT_SECOND_OF_DAY,
    MOMENT_COMPONENT_MILLI_OF_SECOND,
    MOMENT_COMPONENT_MILLI_OF_DAY,
    MOMENT_COMPONENT_MICRO_OF_SECOND,
    MOMENT_COMPONENT_NANO_OF_SECOND,
} moment_component_t;

moment_t    THX_moment_new(pTHX_ IV Y, IV M, IV D, IV h, IV m, IV s, IV ns, IV offset);
moment_t    THX_moment_from_epoch(pTHX_ int64_t sec, IV usec, IV offset);
moment_t    THX_moment_from_epoch_nv(pTHX_ NV sec);

moment_t    THX_moment_from_jd(pTHX_ NV jd, NV epoch, IV precision);

moment_t    THX_moment_with_component(pTHX_ const moment_t *mt, moment_component_t u, IV v);
moment_t    THX_moment_with_offset_same_instant(pTHX_ const moment_t *mt, IV offset);
moment_t    THX_moment_with_offset_same_local(pTHX_ const moment_t *mt, IV offset);

moment_t    THX_moment_plus_unit(pTHX_ const moment_t *mt, moment_unit_t u, int64_t v);
moment_t    THX_moment_minus_unit(pTHX_ const moment_t *mt, moment_unit_t u, int64_t v);

int64_t     moment_instant_rd_seconds(const moment_t *mt);
int64_t     moment_local_rd_seconds(const moment_t *mt);

dt_t        moment_local_dt(const moment_t *mt);

void        moment_to_instant_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos);
void        moment_to_local_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos);

int         moment_compare_instant(const moment_t *m1, const moment_t *m2);
int         moment_compare_local(const moment_t *m1, const moment_t *m2);
bool        moment_equals(const moment_t *m1, const moment_t *m2);

int         moment_year(const moment_t *mt);
int         moment_quarter(const moment_t *mt);
int         moment_month(const moment_t *mt);
int         moment_week(const moment_t *mt);
int         moment_day_of_year(const moment_t *mt);
int         moment_day_of_quarter(const moment_t *mt);
int         moment_day_of_month(const moment_t *mt);
int         moment_day_of_week(const moment_t *mt);
int         moment_hour(const moment_t *mt);
int         moment_minute(const moment_t *mt);
int         moment_minute_of_day(const moment_t *mt);
int         moment_second(const moment_t *mt);
int         moment_second_of_day(const moment_t *mt);
int         moment_millisecond(const moment_t *mt);
int         moment_millisecond_of_day(const moment_t *mt);
int         moment_microsecond(const moment_t *mt);
int         moment_nanosecond(const moment_t *mt);
int         moment_offset(const moment_t *mt);
int64_t     moment_epoch(const moment_t *mt);

NV          moment_jd(const moment_t *mt);
NV          moment_mjd(const moment_t *mt);
NV          moment_rd(const moment_t *mt);

int         moment_length_of_year(const moment_t *mt);
int         moment_length_of_quarter(const moment_t *mt);
int         moment_length_of_month(const moment_t *mt);
int         moment_length_of_week_year(const moment_t *mt);

moment_t    THX_moment_at_utc(pTHX_ const moment_t *mt);
moment_t    THX_moment_at_midnight(pTHX_ const moment_t *mt);
moment_t    THX_moment_at_noon(pTHX_ const moment_t *mt);
moment_t    THX_moment_at_last_day_of_year(pTHX_ const moment_t *mt);
moment_t    THX_moment_at_last_day_of_quarter(pTHX_ const moment_t *mt);
moment_t    THX_moment_at_last_day_of_month(pTHX_ const moment_t *mt);


#define moment_new(Y, M, D, h, m, s, ns, offset) \
    THX_moment_new(aTHX_ Y, M, D, h, m, s, ns, offset)

#define moment_from_epoch(sec, nsec, offset) \
    THX_moment_from_epoch(aTHX_ sec, nsec, offset)

#define moment_from_epoch_nv(sec) \
    THX_moment_from_epoch_nv(aTHX_ sec)

#define moment_from_jd(jd, epoch, precision) \
    THX_moment_from_jd(aTHX_ jd, epoch, precision)

#define moment_with_offset_same_instant(self, offset) \
    THX_moment_with_offset_same_instant(aTHX_ self, offset)

#define moment_with_offset_same_local(self, offset) \
    THX_moment_with_offset_same_local(aTHX_ self, offset)

#define moment_with_nanosecond(self, nsec) \
    THX_moment_with_nanosecond(aTHX_ self, nsec)

#define moment_plus_unit(self, unit, v) \
    THX_moment_plus_unit(aTHX_ self, unit, v)

#define moment_minus_unit(self, unit, v) \
    THX_moment_minus_unit(aTHX_ self, unit, v)

#define moment_with_component(self, component, v) \
    THX_moment_with_component(aTHX_ self, component, v)

#define moment_at_utc(self) \
    THX_moment_at_utc(aTHX_ self)

#define moment_at_midnight(self) \
    THX_moment_at_midnight(aTHX_ self)

#define moment_at_noon(self) \
    THX_moment_at_noon(aTHX_ self)

#define moment_at_last_day_of_year(self) \
    THX_moment_at_last_day_of_year(aTHX_ self)

#define moment_at_last_day_of_quarter(self) \
    THX_moment_at_last_day_of_quarter(aTHX_ self)

#define moment_at_last_day_of_month(self) \
    THX_moment_at_last_day_of_month(aTHX_ self)

#endif
