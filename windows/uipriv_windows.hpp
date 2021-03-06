// 21 april 2016
#include "winapi.hpp"
#include "../ui.h"
#include "../ui_windows.h"
#include "../common/uipriv.h"
#include "resources.hpp"
#include "compilerver.hpp"

// ui internal window messages
enum {
	// redirected WM_COMMAND and WM_NOTIFY
	msgCOMMAND = WM_APP + 0x40,		// start offset just to be safe
	msgNOTIFY,
	msgHSCROLL,
	msgQueued,
	msgD2DScratchPaint,
	msgD2DScratchLButtonDown,
};

// alloc.cpp
extern void initAlloc(void);
extern void uninitAlloc(void);

// events.cpp
extern BOOL runWM_COMMAND(WPARAM wParam, LPARAM lParam, LRESULT *lResult);
extern BOOL runWM_NOTIFY(WPARAM wParam, LPARAM lParam, LRESULT *lResult);
extern BOOL runWM_HSCROLL(WPARAM wParam, LPARAM lParam, LRESULT *lResult);
extern void issueWM_WININICHANGE(WPARAM wParam, LPARAM lParam);

// utf16.cpp
#define emptyUTF16() ((WCHAR *) uiAlloc(1 * sizeof (WCHAR), "WCHAR[]"))
#define emptyUTF8() ((char *) uiAlloc(1 * sizeof (char), "char[]"))
extern WCHAR *toUTF16(const char *str);
extern char *toUTF8(const WCHAR *wstr);
extern WCHAR *utf16dup(const WCHAR *orig);
extern WCHAR *strf(const WCHAR *format, ...);
extern WCHAR *vstrf(const WCHAR *format, va_list ap);
extern char *LFtoCRLF(const char *lfonly);
extern void CRLFtoLF(const char *s);
extern WCHAR *ftoutf16(double d);
extern WCHAR *itoutf16(intmax_t i);

// debug.cpp
// see http://stackoverflow.com/questions/14421656/is-there-widely-available-wide-character-variant-of-file
// we turn __LINE__ into a string because PRIiMAX can't be converted to a wide string in MSVC (it seems to be defined as "ll" "i" according to the compiler errors)
// also note the use of __FUNCTION__ here; __func__ doesn't seem to work for some reason
#define _ws2(m) L ## m
#define _ws(m) _ws2(m)
#define _ws2n(m) L ## #m
#define _wsn(m) _ws2n(m)
#define debugargs const WCHAR *file, const WCHAR *line, const WCHAR *func
extern HRESULT _logLastError(debugargs, const WCHAR *s);
#define logLastError(s) _logLastError(_ws(__FILE__), _wsn(__LINE__), _ws(__FUNCTION__), s)
extern HRESULT _logHRESULT(debugargs, const WCHAR *s, HRESULT hr);
#define logHRESULT(s, hr) _logHRESULT(_ws(__FILE__), _wsn(__LINE__), _ws(__FUNCTION__), s, hr)

// winutil.cpp
extern int windowClassOf(HWND hwnd, ...);
extern void mapWindowRect(HWND from, HWND to, RECT *r);
extern DWORD getStyle(HWND hwnd);
extern void setStyle(HWND hwnd, DWORD style);
extern DWORD getExStyle(HWND hwnd);
extern void setExStyle(HWND hwnd, DWORD exstyle);
extern void clientSizeToWindowSize(HWND hwnd, intmax_t *width, intmax_t *height, BOOL hasMenubar);
extern HWND parentOf(HWND child);
extern HWND parentToplevel(HWND child);
extern void setWindowInsertAfter(HWND hwnd, HWND insertAfter);
extern HWND getDlgItem(HWND hwnd, int id);
extern void invalidateRect(HWND hwnd, RECT *r, BOOL erase);

// text.cpp
extern WCHAR *windowTextAndLen(HWND hwnd, LRESULT *len);
extern WCHAR *windowText(HWND hwnd);
extern void setWindowText(HWND hwnd, WCHAR *wtext);

// init.cpp
extern HINSTANCE hInstance;
extern int nCmdShow;
extern HFONT hMessageFont;
extern HBRUSH hollowBrush;
extern uiInitOptions options;

// utilwin.cpp
extern HWND utilWindow;
extern const char *initUtilWindow(HICON hDefaultIcon, HCURSOR hDefaultCursor);
extern void uninitUtilWindow(void);

// main.cpp
extern int registerMessageFilter(void);
extern void unregisterMessageFilter(void);

// parent.cpp
extern void paintContainerBackground(HWND hwnd, HDC dc, RECT *paintRect);
extern BOOL handleParentMessages(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam, LRESULT *lResult);

// d2dscratch.cpp
extern ATOM registerD2DScratchClass(HICON hDefaultIcon, HCURSOR hDefaultCursor);
extern void unregisterD2DScratchClass(void);
extern HWND newD2DScratch(HWND parent, RECT *rect, HMENU controlID, SUBCLASSPROC subclass, DWORD_PTR subclassData);

// area.cpp
#define areaClass L"libui_uiAreaClass"
extern ATOM registerAreaClass(HICON, HCURSOR);
extern void unregisterArea(void);

// areaevents.cpp
extern BOOL areaFilter(MSG *);

// window.cpp
extern ATOM registerWindowClass(HICON, HCURSOR);
extern void unregisterWindowClass(void);
extern void ensureMinimumWindowSize(uiWindow *);
extern void disableAllWindowsExcept(uiWindow *which);
extern void enableAllWindowsExcept(uiWindow *which);

// container.cpp
#define containerClass L"libui_uiContainerClass"
extern ATOM initContainer(HICON, HCURSOR);
extern void uninitContainer(void);

// tabpage.cpp
struct tabPage {
	HWND hwnd;
	uiControl *child;
	BOOL margined;
};
extern struct tabPage *newTabPage(uiControl *child);
extern void tabPageDestroy(struct tabPage *tp);
extern void tabPageMinimumSize(struct tabPage *tp, intmax_t *width, intmax_t *height);

// colordialog.cpp
struct colorDialogRGBA {
	double r;
	double g;
	double b;
	double a;
};
extern BOOL showColorDialog(HWND parent, struct colorDialogRGBA *c);




// TODO
#include "_uipriv_migrate.hpp"
