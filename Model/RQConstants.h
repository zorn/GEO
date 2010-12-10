#define RQDEBUG 0

#if !defined(RQDEBUG) || RQDEBUG == 0
#define CCLOG(...) do {} while (0)
#elif RQDEBUG == 1
#define CCLOG(...) NSLog(__VA_ARGS__)
#endif 