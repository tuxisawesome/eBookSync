/* generated from: obj/COMICS.o */
#define HAS_INIT_ARRAY 0
#define HAS_FINI_ARRAY 0
#define HAS_CLOCK 0
#define HAS_ABORT 0
#define HAS_EXIT 0
#define HAS_C99__EXIT 0
#define HAS_RUN_PRGM 0
#define HAS_MAIN_ARGC_ARGV 0
#define HAS_ATEXIT 0
#ifdef __ASSEMBLER__
.macro LIBLOAD_LIBS
	.global __libload_library_FILEIOC
	.type __libload_library_FILEIOC, @object
__libload_library_FILEIOC:
	.db 0xC0, "FILEIOC", 0, 8
	.global _ti_Open
	.type _ti_Open, @function
_ti_Open:
	jp 3
	.global _ti_Close
	.type _ti_Close, @function
_ti_Close:
	jp 9
	.global _ti_Write
	.type _ti_Write, @function
_ti_Write:
	jp 12
	.global _ti_Delete
	.type _ti_Delete, @function
_ti_Delete:
	jp 24
	.global _ti_Seek
	.type _ti_Seek, @function
_ti_Seek:
	jp 30
	.global _ti_SetArchiveStatus
	.type _ti_SetArchiveStatus, @function
_ti_SetArchiveStatus:
	jp 39
	.global _ti_GetSize
	.type _ti_GetSize, @function
_ti_GetSize:
	jp 48
	.global _ti_GetDataPtr
	.type _ti_GetDataPtr, @function
_ti_GetDataPtr:
	jp 54
	.global _ti_ArchiveHasRoom
	.type _ti_ArchiveHasRoom, @function
_ti_ArchiveHasRoom:
	jp 102
	.global __libload_library_GRAPHX
	.type __libload_library_GRAPHX, @object
__libload_library_GRAPHX:
	.db 0xC0, "GRAPHX", 0, 14
	.global _gfx_Begin
	.type _gfx_Begin, @function
_gfx_Begin:
	jp 0
	.global _gfx_End
	.type _gfx_End, @function
_gfx_End:
	jp 3
	.global _gfx_SetColor
	.type _gfx_SetColor, @function
_gfx_SetColor:
	jp 6
	.global _gfx_FillScreen
	.type _gfx_FillScreen, @function
_gfx_FillScreen:
	jp 15
	.global _gfx_SetDraw
	.type _gfx_SetDraw, @function
_gfx_SetDraw:
	jp 27
	.global _gfx_SwapDraw
	.type _gfx_SwapDraw, @function
_gfx_SwapDraw:
	jp 30
	.global _gfx_PrintStringXY
	.type _gfx_PrintStringXY, @function
_gfx_PrintStringXY:
	jp 54
	.global _gfx_SetTextBGColor
	.type _gfx_SetTextBGColor, @function
_gfx_SetTextBGColor:
	jp 60
	.global _gfx_SetTextFGColor
	.type _gfx_SetTextFGColor, @function
_gfx_SetTextFGColor:
	jp 63
	.global _gfx_FillRectangle_NoClip
	.type _gfx_FillRectangle_NoClip, @function
_gfx_FillRectangle_NoClip:
	jp 126
	.global __libload_library_KEYPADC
	.type __libload_library_KEYPADC, @object
__libload_library_KEYPADC:
	.db 0xC0, "KEYPADC", 0, 2
	.global _kb_Scan
	.type _kb_Scan, @function
_kb_Scan:
	jp 0
	.global __libload_library_SRLDRVCE
	.type __libload_library_SRLDRVCE, @object
__libload_library_SRLDRVCE:
	.db 0xC0, "SRLDRVCE", 0, 0
	.global _srl_Open
	.type _srl_Open, @function
_srl_Open:
	jp 0
	.global _srl_Read
	.type _srl_Read, @function
_srl_Read:
	jp 6
	.global _srl_Write
	.type _srl_Write, @function
_srl_Write:
	jp 9
	.global _srl_GetCDCStandardDescriptors
	.type _srl_GetCDCStandardDescriptors, @function
_srl_GetCDCStandardDescriptors:
	jp 12
	.global _srl_UsbEventCallback
	.type _srl_UsbEventCallback, @function
_srl_UsbEventCallback:
	jp 15
	.global __libload_library_USBDRVCE
	.type __libload_library_USBDRVCE, @object
__libload_library_USBDRVCE:
	.db 0xC0, "USBDRVCE", 0, 0
	.global _usb_Init
	.type _usb_Init, @function
_usb_Init:
	jp 0
	.global _usb_Cleanup
	.type _usb_Cleanup, @function
_usb_Cleanup:
	jp 3
	.global _usb_HandleEvents
	.type _usb_HandleEvents, @function
_usb_HandleEvents:
	jp 9
	.global _usb_FindDevice
	.type _usb_FindDevice, @function
_usb_FindDevice:
	jp 36
.endm
#endif
#define HAS_LIBLOAD 1
