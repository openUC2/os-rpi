/************************************************************************

*  Copyright (C) Xintu Photonics Co.,Ltd. 2012-2025. All rights reserved.

*  @file      TuCamApi.h

*  @brief     Tucsen Camera export functions header file	

*  @version	  1.0.0.0	    

*  @author    Zhang Ren

*  @date      2023-01-05 

************************************************************************/
#ifndef _TUCAM_API_H_
#define _TUCAM_API_H_

#include "TUDefine.h"

#if defined (TUCAM_TARGETOS_IS_WIN32)
    #ifdef TUCAM_EXPORTS
        #define TUCAM_API extern "C" __declspec(dllexport)
    #else
        #define TUCAM_API extern "C" __declspec(dllimport)
    #endif  // TUCAM_EXPORTS
#elif defined (TUCAM_TARGETOS_IS_LINUX)
    #define TUCAM_API extern "C" __attribute__((visibility("default")))
#else
    #define TUCAM_API
#endif      // TUCAM_TARGETOS_IS_WIN32

//
// Initialize uninitialize and misc.
//
TUCAM_API TUCAMRET TUCAM_Api_Config             (INT32 configType, INT32 configValue);
TUCAM_API TUCAMRET TUCAM_Api_Init               (PTUCAM_INIT pInitParam, INT32 nTimeOut = TUCAM_TIMEOUT);
TUCAM_API TUCAMRET TUCAM_Api_Uninit             ();

TUCAM_API TUCAMRET TUCAM_Dev_Open               (PTUCAM_OPEN pOpenParam);   
TUCAM_API TUCAMRET TUCAM_Dev_Close              (HDTUCAM hTUCam); 

// Get some device information (VID/PID/Version)
TUCAM_API TUCAMRET TUCAM_Dev_GetInfo            (HDTUCAM hTUCam, PTUCAM_VALUE_INFO pInfo);                          // PTUCAM_VALUE_INFO  call after TUCAM_Dev_Open()
TUCAM_API TUCAMRET TUCAM_Dev_GetInfoEx          (UINT32  uiICam, PTUCAM_VALUE_INFO pInfo);                          // PTUCAM_VALUE_INFO  call after TUCAM_Api_Init()            

//
// Capability control
//
TUCAM_API TUCAMRET TUCAM_Capa_GetAttr           (HDTUCAM hTUCam, PTUCAM_CAPA_ATTR pAttr);                           // PTUCAM_CAPA_ATTR
TUCAM_API TUCAMRET TUCAM_Capa_GetValue	        (HDTUCAM hTUCam, INT32 nCapa, INT32 *pnVal);                        // TUCAM_IDCAPA
TUCAM_API TUCAMRET TUCAM_Capa_SetValue	        (HDTUCAM hTUCam, INT32 nCapa, INT32 nVal);                          // TUCAM_IDCAPA
TUCAM_API TUCAMRET TUCAM_Capa_GetValueText      (HDTUCAM hTUCam, PTUCAM_VALUE_TEXT pVal);                           // PTUCAM_VALUE_TEXT

//
// Property control
//
TUCAM_API TUCAMRET TUCAM_Prop_GetAttr           (HDTUCAM hTUCam, PTUCAM_PROP_ATTR pAttr);                           // PTUCAM_PROP_ATTR
TUCAM_API TUCAMRET TUCAM_Prop_GetValue	        (HDTUCAM hTUCam, INT32 nProp, DOUBLE *pdbVal, INT32 nChn = 0);      // TUCAM_IDPROP
TUCAM_API TUCAMRET TUCAM_Prop_SetValue	        (HDTUCAM hTUCam, INT32 nProp, DOUBLE dbVal, INT32 nChn = 0);        // TUCAM_IDPROP
TUCAM_API TUCAMRET TUCAM_Prop_GetValueText      (HDTUCAM hTUCam, PTUCAM_VALUE_TEXT pVal, INT32 nChn = 0);           // PTUCAM_VALUE_TEXT

//
// Buffer control
//
TUCAM_API TUCAMRET TUCAM_Buf_Alloc              (HDTUCAM hTUCam, PTUCAM_FRAME pFrame);                              // call TUCAM_Buf_Release() to free.
TUCAM_API TUCAMRET TUCAM_Buf_Release            (HDTUCAM hTUCam);
TUCAM_API TUCAMRET TUCAM_Buf_AbortWait          (HDTUCAM hTUCam);                                                   // call after TUCAM_Buf_WaitForFrame()
TUCAM_API TUCAMRET TUCAM_Buf_WaitForFrame       (HDTUCAM hTUCam, PTUCAM_FRAME pFrame, INT32 nTimeOut = TUCAM_TIMEOUT); // call after TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Buf_CopyFrame          (HDTUCAM hTUCam, PTUCAM_FRAME pFrame);                              // call after TUCAM_Buf_WaitForFrame()

// Buffer CallBack Function
TUCAM_API TUCAMRET TUCAM_Buf_DataCallBack       (HDTUCAM hTUCam, BUFFER_CALLBACK cbBuffer, void *pUserContex);
// Get Buffer Data
TUCAM_API TUCAMRET TUCAM_Buf_GetData            (HDTUCAM hTUCam, PTUCAM_RAWIMG_HEADER pFrame);

//Old API Interface
// GenICam Buffer CallBack Function
TUCAM_API TUCAMRET TUCAM_GenICam_BuffDataCallBack(HDTUCAM hTUCam, BUFFER_CALLBACK cbBuffer, void *pUserContex);

// GenICam Get Buffer Data
TUCAM_API TUCAMRET TUCAM_GenICam_GetBuffData(HDTUCAM hTUCam, PUCHAR *pBuffer, PTUCAM_CB_BUFHEADER pBufInfo);

//
// Capturing control
//
// ROI
TUCAM_API TUCAMRET TUCAM_Cap_SetROI             (HDTUCAM hTUCam, TUCAM_ROI_ATTR roiAttr);                           // call before TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Cap_GetROI             (HDTUCAM hTUCam, PTUCAM_ROI_ATTR pRoiAttr);   

// MultiROI
TUCAM_API TUCAMRET TUCAM_Cap_SetMultiROI        (HDTUCAM hTUCam, TUCAM_MULTIROI_ATTR multiroiAttr);
TUCAM_API TUCAMRET TUCAM_Cap_GetMultiROI        (HDTUCAM hTUCam, PTUCAM_MULTIROI_ATTR pmultiroiAttr);

// Trigger
TUCAM_API TUCAMRET TUCAM_Cap_SetTrigger         (HDTUCAM hTUCam, TUCAM_TRIGGER_ATTR tgrAttr);                       // call before TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Cap_GetTrigger         (HDTUCAM hTUCam, PTUCAM_TRIGGER_ATTR pTgrAttr);
TUCAM_API TUCAMRET TUCAM_Cap_DoSoftwareTrigger  (HDTUCAM hTUCam, UINT32 uiMode = TUCTS_TIMED);                      // in trigger mode

// TriggerOut
TUCAM_API TUCAMRET TUCAM_Cap_SetTriggerOut      (HDTUCAM hTUCam, TUCAM_TRGOUT_ATTR tgroutAttr);                       
TUCAM_API TUCAMRET TUCAM_Cap_GetTriggerOut      (HDTUCAM hTUCam, PTUCAM_TRGOUT_ATTR pTgrOutAttr);

// Capturing
TUCAM_API TUCAMRET TUCAM_Cap_Start              (HDTUCAM hTUCam, UINT32 uiMode);  // uiMode see enum TUCAM_CAPTURE_MODES
TUCAM_API TUCAMRET TUCAM_Cap_Stop               (HDTUCAM hTUCam);

//
// File control
//
// Image
TUCAM_API TUCAMRET TUCAM_File_SaveImage         (HDTUCAM hTUCam, TUCAM_FILE_SAVE fileSave);
// Profiles
TUCAM_API TUCAMRET TUCAM_File_LoadProfiles      (HDTUCAM hTUCam, PCHAR pPrfName);                                   // call before TUCAM_Cap_Start()  if after called TUCAM_Cap_Start(), must call TUCAM_Cap_Stop() first
TUCAM_API TUCAMRET TUCAM_File_SaveProfiles      (HDTUCAM hTUCam, PCHAR pPrfName);     
// Video
TUCAM_API TUCAMRET TUCAM_Rec_Start              (HDTUCAM hTUCam, TUCAM_REC_SAVE recSave);
TUCAM_API TUCAMRET TUCAM_Rec_AppendFrame        (HDTUCAM hTUCam, PTUCAM_FRAME pFrame);
TUCAM_API TUCAMRET TUCAM_Rec_Stop               (HDTUCAM hTUCam);
TUCAM_API TUCAMRET TUCAM_Rec_SetRecordVoice		(HDTUCAM hTUCam, BOOL bVoiceRecord = FALSE);
// 
TUCAM_API TUCAMRET TUIMG_File_Open              (PTUIMG_OPEN pOpenParam, TUCAM_FRAME **pFrame);      
TUCAM_API TUCAMRET TUIMG_File_Close             (HDTUIMG hTUImg);   

//
// Extened control
//
TUCAM_API TUCAMRET TUCAM_Reg_Read               (HDTUCAM hTUCam, TUCAM_REG_RW regRW);
TUCAM_API TUCAMRET TUCAM_Reg_Write              (HDTUCAM hTUCam, TUCAM_REG_RW regRW);

// Drawing contorl
TUCAM_API TUCAMRET TUCAM_Draw_Init              (HDTUCAM hTUCam, TUCAM_DRAW_INIT drawInit);
TUCAM_API TUCAMRET TUCAM_Draw_Frame             (HDTUCAM hTUCam, PTUCAM_DRAW pDrawing);
TUCAM_API TUCAMRET TUCAM_Draw_Uninit            (HDTUCAM hTUCam);

// Calculate roi
TUCAM_API TUCAMRET TUCAM_Calc_SetROI            (HDTUCAM hTUCam, TUCAM_CALC_ROI_ATTR roiAttr);                          
TUCAM_API TUCAMRET TUCAM_Calc_GetROI            (HDTUCAM hTUCam, PTUCAM_CALC_ROI_ATTR pRoiAttr);         

// Process image data
TUCAM_API TUCAMRET TUCAM_Proc_Start             (HDTUCAM hTUCam, INT32 nProcType);
TUCAM_API TUCAMRET TUCAM_Proc_Stop              (HDTUCAM hTUCam, TUCAM_FILE_SAVE fileSave);
TUCAM_API TUCAMRET TUCAM_Proc_AbortWait         (HDTUCAM hTUCam);
TUCAM_API TUCAMRET TUCAM_Proc_UpdateFrame       (HDTUCAM hTUCam, PTUCAM_FRAME pFrame);                              // call after TUCAM_Buf_WaitForFrame()
TUCAM_API TUCAMRET TUCAM_Proc_WaitForFrame      (HDTUCAM hTUCam, TUCAM_FRAME **pFrame);                             // in new thread
TUCAM_API TUCAMRET TUCAM_Proc_Prop_GetAttr      (HDTUCAM hTUCam, PTUCAM_PPROP_ATTR pAttr);                          // PTUCAM_PPROP_ATTR
TUCAM_API TUCAMRET TUCAM_Proc_Prop_GetValue     (HDTUCAM hTUCam, INT32 nProp, DOUBLE *pdbVal);                      // TUCAM_IDPPROP
TUCAM_API TUCAMRET TUCAM_Proc_Prop_SetValue     (HDTUCAM hTUCam, INT32 nProp, DOUBLE dbVal);                        // TUCAM_IDPPROP
TUCAM_API TUCAMRET TUCAM_Proc_Prop_GetValueText (HDTUCAM hTUCam, PTUCAM_VALUE_TEXT pVal);

//
// Vendor control
//
TUCAM_API TUCAMRET TUCAM_Vendor_Config          (HDTUCAM hTUCam, UINT32 uiMode);
TUCAM_API TUCAMRET TUCAM_Vendor_ConfigEx        (UINT32  uiICam, UINT32 uiMode);
TUCAM_API TUCAMRET TUCAM_Vendor_Update          (HDTUCAM hTUCam, PTUCAM_FW_UPDATE updateFW);

//
// Vendor property control
//
TUCAM_API TUCAMRET TUCAM_Vendor_Prop_GetAttr     (HDTUCAM hTUCam, PTUCAM_VPROP_ATTR pAttr);                          // PTUCAM_VPROP_ATTR
TUCAM_API TUCAMRET TUCAM_Vendor_Prop_GetValue    (HDTUCAM hTUCam, INT32 nProp, DOUBLE *pdbVal, INT32 nChn = 0);      // TUCAM_IDVPROP
TUCAM_API TUCAMRET TUCAM_Vendor_Prop_SetValue	 (HDTUCAM hTUCam, INT32 nProp, DOUBLE dbVal, INT32 nChn = 0);        // TUCAM_IDVPROP
TUCAM_API TUCAMRET TUCAM_Vendor_Prop_GetValueText(HDTUCAM hTUCam, PTUCAM_VALUE_TEXT pVal, INT32 nChn = 0);           // PTUCAM_VALUE_TEXT

// Vendor buffer control
TUCAM_API TUCAMRET TUCAM_Vendor_ResetIndexFrame  (HDTUCAM hTUCam);													 // reset WaitForIndexFrame state 
TUCAM_API TUCAMRET TUCAM_Vendor_WaitForIndexFrame(HDTUCAM hTUCam, PTUCAM_FRAME pFrame);                              // call after TUCAM_Cap_Start()        
TUCAM_API TUCAMRET TUCAM_Buf_Attach              (HDTUCAM hTUCam, PUCHAR pBuffer, UINT32 uiBufSize);				 // call after TUCAM_Buf_Alloc() to attach a user buffer
TUCAM_API TUCAMRET TUCAM_Buf_Detach              (HDTUCAM hTUCam);													 // call after TUCAM_Buf_Attach() to detach a user buffer
TUCAM_API TUCAMRET TUCAM_Vendor_SetQueueMode     (HDTUCAM hTUCam, BOOL bQueueMode = FALSE);
TUCAM_API TUCAMRET TUCAM_Vendor_GetOldestFrame   (HDTUCAM hTUCam, PTUCAM_FRAME pFrame, UINT32 nTimeOut = INFINITE);
TUCAM_API TUCAMRET TUCAM_Vendor_QueueOldestFrame (HDTUCAM hTUCam);

// Get GrayValue
TUCAM_API TUCAMRET TUCAM_Get_GrayValue			 (HDTUCAM hTUCam, INT32 nXPos, INT32 nYPos, UINT16 *pusValue);    

// Find color temperature index value according to RGB
TUCAM_API TUCAMRET TUCAM_Index_GetColorTemperature(HDTUCAM hTUCam, INT32 nRed, INT32 nGeen, INT32 nBlue, UINT32 *pusValue);

// Set record save mode
TUCAM_API TUCAMRET TUCAM_Rec_SetAppendMode      (HDTUCAM hTUCam, UINT32 uiMode);

// Get the last stitch frame no edge
TUCAM_API TUCAMRET TUCAM_Proc_CopyFrame         (HDTUCAM hTUCam, TUCAM_FRAME **pFrame);

// Config the AF platform
TUCAM_API TUCAMRET TUCAM_Vendor_AFPlatform      (HDTUCAM hTUCam, NVILen *pLen);

// Any-BIN
TUCAM_API TUCAMRET TUCAM_Cap_SetBIN             (HDTUCAM hTUCam, TUCAM_BIN_ATTR binAttr);                           // call before TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Cap_GetBIN             (HDTUCAM hTUCam, PTUCAM_BIN_ATTR pBinAttr);

// Subtract background
TUCAM_API TUCAMRET TUCAM_Cap_SetBackGround      (HDTUCAM hTUCam, TUCAM_IMG_BACKGROUND bgAttr);                     // call before TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Cap_GetBackGround      (HDTUCAM hTUCam, PTUCAM_IMG_BACKGROUND pBGAttr);

// Math
TUCAM_API TUCAMRET TUCAM_Cap_SetMath            (HDTUCAM hTUCam, TUCAM_IMG_MATH mathAttr);                         // call before TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Cap_GetMath            (HDTUCAM hTUCam, PTUCAM_IMG_MATH pMathAttr);

// GenICam Element Attribute pName
TUCAM_API TUCAMRET TUCAM_GenICam_ElementAttr    (HDTUCAM hTUCam, PTUCAM_ELEMENT pNote, PCHAR pName, TUXML_DEVICE Xml = TU_CAMERA_XML);

// GenICam Element Attribute Next
TUCAM_API TUCAMRET TUCAM_GenICam_ElementAttrNext(HDTUCAM hTUCam, PTUCAM_ELEMENT pNote, PCHAR pName, TUXML_DEVICE Xml = TU_CAMERA_XML);

// GenICam Set Element Value 
TUCAM_API TUCAMRET TUCAM_GenICam_SetElementValue(HDTUCAM hTUCam, PTUCAM_ELEMENT pNote, TUXML_DEVICE Xml = TU_CAMERA_XML);

// GenICam Get Element Value 
TUCAM_API TUCAMRET TUCAM_GenICam_GetElementValue(HDTUCAM hTUCam, PTUCAM_ELEMENT pNote, TUXML_DEVICE Xml = TU_CAMERA_XML);

// GenICam Set Register Value 
TUCAM_API TUCAMRET TUCAM_GenICam_SetRegisterValue(HDTUCAM hTUCam, PUCHAR pBuffer, INT64 nAddress, INT64 nLength);

// GenICam Get Register Value 
TUCAM_API TUCAMRET TUCAM_GenICam_GetRegisterValue(HDTUCAM hTUCam, PUCHAR pBuffer, INT64 nAddress, INT64 nLength);

// Only CXP and CL Support
TUCAM_API TUCAMRET TUCAM_Cap_AnnounceBuffer      (HDTUCAM hTUCam, UINT32 uiSize, void *pBuf);                        // call before TUCAM_Cap_Start()
TUCAM_API TUCAMRET TUCAM_Cap_ClearBuffer         (HDTUCAM hTUCam);

//FFC Coefficient Load or Save 
TUCAM_API TUCAMRET TUCAM_File_LoadFFCCoefficient (HDTUCAM hTUCam, PCHAR pstrFile);
TUCAM_API TUCAMRET TUCAM_File_SaveFFCCoefficient (HDTUCAM hTUCam, PCHAR pstrFile);

//DSNU Data write/read
TUCAM_API TUCAMRET TUCAM_GenICam_DSNUDataRW(HDTUCAM hTUCam, PCHAR pTextFile, TUDATA_RW rwFlag);

//PRNU Data write/read
TUCAM_API TUCAMRET TUCAM_GenICam_PRNUDataRW(HDTUCAM hTUCam, PCHAR pTextFile, TUDATA_RW rwFlag);

// Load Param
TUCAM_API TUCAMRET TUCAM_GenICam_LoadParam(HDTUCAM hTUCam, PCHAR pstrFile);

// Save Param
TUCAM_API TUCAMRET TUCAM_GenICam_SaveParam(HDTUCAM hTUCam, PCHAR pstrFile);


/************************************************************************
The custom interfaces
************************************************************************/
//start capture
TUCAM_API TUCAMRET TUCAM_TDI_Cap_Start(HDTUCAM hTUCam, UINT32 uiMode, UINT32 uiBufCnt);

//Get Buffer Data
TUCAM_API TUCAMRET TUCAM_TDI_GetBuffData(HDTUCAM hTUCam, PUCHAR *pBuffer, PTUCAM_TDI_CB_BUFHEADER pBufInfo);
#endif      // _TUCAM_API_H_