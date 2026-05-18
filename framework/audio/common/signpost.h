#pragma once
#ifdef __APPLE__
#include <os/signpost.h>

#include "global/defer.h"

// call this macro after you include this header file
#define MSS_SIGNPOST_PREPARE \
        os_log_t sn_log = os_log_create("net.staffpad.StaffPad", OS_LOG_CATEGORY_POINTS_OF_INTEREST);

// call these macros to begin and end a signpost interval
#define MSS_SIGNPOST_BEGIN(name)                \
        auto spid = os_signpost_id_generate(sn_log); \
        os_signpost_interval_begin(sn_log, spid, name);

#define MSS_SIGNPOST_END(name) os_signpost_interval_end(sn_log, spid, name);
#define MSS_SIGNPOST_SCOPE(name)                   \
        auto spid = os_signpost_id_generate(sn_log);    \
        os_signpost_interval_begin(sn_log, spid, name); \
        muse::Defer g([&] { os_signpost_interval_end(sn_log, spid, name); });

#define MSS_SIGNPOST_FUNCTION                                                       \
        auto spid = os_signpost_id_generate(sn_log);                                     \
        os_signpost_interval_begin(sn_log, spid, "Function", "%s", __PRETTY_FUNCTION__); \
        muse::Defer g([&] { os_signpost_interval_end(sn_log, spid, "Function", "%s", __PRETTY_FUNCTION__); });

#endif
