#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TUCamApi.h"

static TUCAM_INIT m_itApi;
static TUCAM_OPEN m_opCam;
static TUCAM_FRAME m_frame;
static TUCAM_FILE_SAVE m_fs;
static TUCAM_TRIGGER_ATTR m_tgr;

/*
 * nBufFrames (TUCAM_TRIGGER_ATTR): capture buffer / ring frame count (Cap_SetTrigger).
 * uiRsdSize (TUCAM_FRAME): frames requested per Buf_WaitForFrame (usually 1).
 */
static const int kBufferFrameCount = 4;   /* match driver "[BeginBulkInDataTransfer]:Can get N frames!" */
static const int kWaitFrameCount = 1;     /* uiRsdSize for Buf_Alloc / WaitForFrame */
static const int kWarmupFrames = 10;
static const int kSoftTriggerSaveCount = 5;
static const int kFrameWaitTimeoutMs = 5000;
static const int kModeSwitchDelayMs = 300;

TUCAMRET InitApi()
{
    char szPath[1024] = {"./"};
    getcwd(szPath, sizeof(szPath));
    m_itApi.uiCamCount = 0;
    m_itApi.pstrConfigPath = szPath;

    TUCAMRET ret = TUCAM_Api_Init(&m_itApi);
    printf("TUCAM_Api_Init return %X\n", ret);
    if (ret != TUCAMRET_SUCCESS)
    {
        return ret;
    }

    printf("Connect %d camera\r\n", m_itApi.uiCamCount);
    if (0 == m_itApi.uiCamCount)
    {
        return TUCAMRET_NO_CAMERA;
    }

    return TUCAMRET_SUCCESS;
}

TUCAMRET UnInitApi()
{
    return TUCAM_Api_Uninit();
}

TUCAMRET OpenCamera(UINT uiIdx)
{
    if (uiIdx >= m_itApi.uiCamCount)
    {
        return TUCAMRET_OUT_OF_RANGE;
    }

    m_opCam.uiIdxOpen = uiIdx;
    return TUCAM_Dev_Open(&m_opCam);
}

TUCAMRET CloseCamera()
{
    if (NULL != m_opCam.hIdxTUCam)
    {
        TUCAM_Dev_Close(m_opCam.hIdxTUCam);
    }

    printf("Close the camera success\r\n");
    return TUCAMRET_SUCCESS;
}

static BOOL StartCapture(UINT32 mode)
{
    if (TUCAMRET_SUCCESS != TUCAM_Cap_Start(m_opCam.hIdxTUCam, mode))
    {
        printf("TUCAM_Cap_Start failed, mode=0x%X\r\n", mode);
        return FALSE;
    }
    return TRUE;
}

static void StopCapture()
{
    TUCAM_Buf_AbortWait(m_opCam.hIdxTUCam);
    TUCAM_Cap_Stop(m_opCam.hIdxTUCam);
}

static BOOL SetTriggerMode(INT32 tgrMode)
{
    if (TUCAMRET_SUCCESS != TUCAM_Cap_GetTrigger(m_opCam.hIdxTUCam, &m_tgr))
    {
        printf("TUCAM_Cap_GetTrigger failed\r\n");
        return FALSE;
    }
    m_tgr.nTgrMode = tgrMode;
    m_tgr.nFrames = 1;
    m_tgr.nBufFrames = kBufferFrameCount;
    if (TUCAMRET_SUCCESS != TUCAM_Cap_SetTrigger(m_opCam.hIdxTUCam, m_tgr))
    {
        printf("TUCAM_Cap_SetTrigger failed, mode=0x%X\r\n", tgrMode);
        return FALSE;
    }
    return TRUE;
}

static BOOL AllocFrameBuffer()
{
    m_frame.pBuffer = NULL;
    m_frame.ucFormatGet = TUFRM_FMT_USUAl;
    m_frame.uiRsdSize = (UINT32)kWaitFrameCount;
    m_frame.uiHstSize = 0;

    if (TUCAMRET_SUCCESS != TUCAM_Buf_Alloc(m_opCam.hIdxTUCam, &m_frame))
    {
        printf("TUCAM_Buf_Alloc failed\r\n");
        return FALSE;
    }
    return TRUE;
}

static void ReleaseFrameBuffer()
{
    TUCAM_Buf_Release(m_opCam.hIdxTUCam);
    m_frame.pBuffer = NULL;
}

/* Stream warmup first, then switch to soft trigger and save each frame as TIFF */
void SaveImageData()
{
    char szPath[1024] = {"./"};
    getcwd(szPath, sizeof(szPath));

    m_fs.nSaveFmt = (INT32)TUFMT_TIF;

    if (!AllocFrameBuffer())
    {
        return;
    }

    /* --- Phase A: continuous stream warmup (no save) --- */
    if (!SetTriggerMode((INT32)TUCCM_SEQUENCE))
    {
        goto cleanup;
    }
    if (!StartCapture((UINT32)TUCCM_SEQUENCE))
    {
        goto cleanup;
    }

    TUCAM_SLEEP(kModeSwitchDelayMs);
    printf("Stream warmup, %d frames\r\n", kWarmupFrames);
    for (int i = 0; i < kWarmupFrames; ++i)
    {
        if (TUCAMRET_SUCCESS == TUCAM_Buf_WaitForFrame(m_opCam.hIdxTUCam, &m_frame, kFrameWaitTimeoutMs))
        {
            printf("  warmup frame %d\r\n", i);
        }
        else
        {
            printf("  warmup wait failed at %d\r\n", i);
        }
    }
    StopCapture();
    TUCAM_SLEEP(kModeSwitchDelayMs);

    /* Re-alloc after stream so trigger path starts clean */
    ReleaseFrameBuffer();
    if (!AllocFrameBuffer())
    {
        goto cleanup;
    }

    /* --- Phase B: software trigger, save each frame as TIFF --- */
    if (!SetTriggerMode((INT32)TUCCM_TRIGGER_SOFTWARE))
    {
        goto cleanup;
    }
    if (!StartCapture((UINT32)TUCCM_TRIGGER_SOFTWARE))
    {
        goto cleanup;
    }

    /*
     * Exposure/gain sweep reference (set once before soft trigger, not per frame):
     * int npose = 1000, ngain = 1;
     * TUCAM_Prop_SetValue(m_opCam.hIdxTUCam, TUIDP_EXPOSURETM, npose);
     * TUCAM_Prop_SetValue(m_opCam.hIdxTUCam, TUIDP_GLOBALGAIN, ngain);
     */

    printf("Soft trigger save, %d frames (TIFF)\r\n", kSoftTriggerSaveCount);
    for (int i = 0; i < kSoftTriggerSaveCount; ++i)
    {
        if (TUCAMRET_SUCCESS != TUCAM_Cap_DoSoftwareTrigger(m_opCam.hIdxTUCam))
        {
            printf("  DoSoftwareTrigger failed at %d\r\n", i);
            continue;
        }

        if (TUCAMRET_SUCCESS != TUCAM_Buf_WaitForFrame(m_opCam.hIdxTUCam, &m_frame, kFrameWaitTimeoutMs))
        {
            printf("  grab failed at %d\r\n", i);
            continue;
        }

        char path[1024];
        snprintf(path, sizeof(path), "%s/capture_%03d", szPath, i);

        m_fs.pFrame = &m_frame;
        m_fs.pstrSavePath = path;

        if (TUCAMRET_SUCCESS == TUCAM_File_SaveImage(m_opCam.hIdxTUCam, m_fs))
        {
            printf("  saved %s (TIFF)\r\n", path);
        }
        else
        {
            printf("  save failed %s\r\n", path);
        }
    }

    StopCapture();
    printf("Capture done\r\n");

cleanup:
    ReleaseFrameBuffer();
}

int main()
{
    if (TUCAMRET_SUCCESS != InitApi())
    {
        printf("InitApi failure\r\n");
        return 1;
    }

    if (TUCAMRET_SUCCESS == OpenCamera(0))
    {
        printf("Open the camera success\r\n");

        /*
         * --- Parameter setup reference (uncomment before SaveImageData / Cap_Start) ---
         * TUCAM_Capa_SetValue(m_opCam.hIdxTUCam, TUIDC_ATEXPOSURE, 0);
         * TUCAM_Capa_SetValue(m_opCam.hIdxTUCam, TUIDC_RESOLUTION, 1);
         * TUCAM_Prop_SetValue(m_opCam.hIdxTUCam, TUIDP_EXPOSURETM, 1000);
         * TUCAM_Prop_SetValue(m_opCam.hIdxTUCam, TUIDP_GLOBALGAIN, 2);
         * TUCAM_Prop_SetValue(m_opCam.hIdxTUCam, TUIDP_TEMPERATURE, 40);
         * TUCAM_ROI_ATTR roiAttr;
         * roiAttr.bEnable = TRUE;
         * roiAttr.nVOffset = 500;
         * roiAttr.nHOffset = 900;
         * roiAttr.nWidth = 1300;
         * roiAttr.nHeight = 1000;
         * TUCAM_Cap_SetROI(m_opCam.hIdxTUCam, roiAttr);
         */

        SaveImageData();
        CloseCamera();
    }
    else
    {
        printf("Open the camera failure\r\n");
    }

    UnInitApi();
    printf("Press any key to exit...\r\n");
    return 0;
}
