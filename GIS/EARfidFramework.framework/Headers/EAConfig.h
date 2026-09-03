//
//  EAConfig.h
//  EARfidFramework
//
//  Created by ATID
//  Copyright © 2016년 Alluser.net Corp. All rights reserved.
//

#ifndef EAConfig_h
#define EAConfig_h

//
// 패킷 통신관련 로그 출력 여부 설정
//
// PRINT_LOG가 켜져있더라도 Release 모드에서는 자동으로 NSLog가 빠짐
//
#define PRINT_LOG   1

#if DEBUG && PRINT_LOG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif

#endif /* EAConfig_h */
