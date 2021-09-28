#ifdef __cplusplus
#error "Do not use C++.  See the INSTALL file."
#endif

#define _GNU_SOURCE
#include <sys/types.h>

#define MAN_CONF_FILE "/mmc/etc/man.conf"
#define MANPATH_BASE "/mmc/share/man:/mmc/man:/mmc/ssl/man"
#define MANPATH_DEFAULT "/mmc/share/man:/mmc/man:/mmc/ssl/man"
#define OSENUM MANDOC_OS_OTHER
#define EFTYPE EINVAL

#define HAVE_DIRENT_NAMLEN 0
#define HAVE_ENDIAN 1
#define HAVE_ERR 1
#define HAVE_FTS 1
#define HAVE_FTS_COMPARE_CONST 0
#define HAVE_GETLINE 1
#define HAVE_GETSUBOPT 1
#define HAVE_ISBLANK 1
#define HAVE_LESS_T 1
#define HAVE_MKDTEMP 1
#define HAVE_MKSTEMPS 1
#define HAVE_NTOHL 1
#define HAVE_PLEDGE 0
#define HAVE_PROGNAME 0
#define HAVE_REALLOCARRAY 0
#define HAVE_RECALLOCARRAY 0
#define HAVE_REWB_BSD 0
#define HAVE_REWB_SYSV 1
#define HAVE_SANDBOX_INIT 0
#define HAVE_STRCASESTR 1
#define HAVE_STRINGLIST 0
#define HAVE_STRLCAT 1
#define HAVE_STRLCPY 1
#define HAVE_STRNDUP 1
#define HAVE_STRPTIME 1
#define HAVE_STRSEP 1
#define HAVE_STRTONUM 0
#define HAVE_SYS_ENDIAN 0
#define HAVE_VASPRINTF 1
#define HAVE_WCHAR 0
#define HAVE_OHASH 0
#define NEED_XPG4_2 0

#define BINM_APROPOS "apropos"
#define BINM_CATMAN "catman"
#define BINM_MAKEWHATIS "makewhatis"
#define BINM_MAN "man"
#define BINM_SOELIM "soelim"
#define BINM_WHATIS "whatis"
#define BINM_PAGER "less"

extern	const char *getprogname(void);
extern	void	  setprogname(const char *);
extern	void	 *reallocarray(void *, size_t, size_t);
extern	void	 *recallocarray(void *, size_t, size_t, size_t);
extern	long long strtonum(const char *, long long, long long, const char **);
