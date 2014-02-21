/***********************************************************************\
*                                dxgitype.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.dxgitype;

private import win32.windows;

const _FACDXGI = 0x87a;

HRESULT MAKE_DXGI_HRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACDXGI, code);
}

HRESULT MAKE_DXGI_STATUS(T)(T code) {
	return MAKE_HRESULT(0, _FACDXGI, code);
}

const HRESULT DXGI_STATUS_OCCLUDED						= MAKE_DXGI_STATUS(1);
const HRESULT DXGI_STATUS_CLIPPED						= MAKE_DXGI_STATUS(2);
const HRESULT DXGI_STATUS_NO_REDIRECTION				= MAKE_DXGI_STATUS(4);
const HRESULT DXGI_STATUS_NO_DESKTOP_ACCESS				= MAKE_DXGI_STATUS(5);
const HRESULT DXGI_STATUS_GRAPHICS_VIDPN_SOURCE_IN_USE	= MAKE_DXGI_STATUS(6);
const HRESULT DXGI_STATUS_MODE_CHANGED					= MAKE_DXGI_STATUS(7);
const HRESULT DXGI_STATUS_MODE_CHANGE_IN_PROGRESS		= MAKE_DXGI_STATUS(8);
const HRESULT DXGI_ERROR_INVALID_CALL					= MAKE_DXGI_HRESULT( 1);
const HRESULT DXGI_ERROR_NOT_FOUND						= MAKE_DXGI_HRESULT( 2);
const HRESULT DXGI_ERROR_MORE_DATA						= MAKE_DXGI_HRESULT( 3);
const HRESULT DXGI_ERROR_UNSUPPORTED					= MAKE_DXGI_HRESULT( 4);
const HRESULT DXGI_ERROR_DEVICE_REMOVED					= MAKE_DXGI_HRESULT( 5);
const HRESULT DXGI_ERROR_DEVICE_HUNG					= MAKE_DXGI_HRESULT( 6);
const HRESULT DXGI_ERROR_DEVICE_RESET					= MAKE_DXGI_HRESULT( 7);
const HRESULT DXGI_ERROR_WAS_STILL_DRAWING				= MAKE_DXGI_HRESULT(10);
const HRESULT DXGI_ERROR_FRAME_STATISTICS_DISJOINT		= MAKE_DXGI_HRESULT(11);
const HRESULT DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE	= MAKE_DXGI_HRESULT(12);
const HRESULT DXGI_ERROR_DRIVER_INTERNAL_ERROR			= MAKE_DXGI_HRESULT(32);
const HRESULT DXGI_ERROR_NONEXCLUSIVE					= MAKE_DXGI_HRESULT(33);
const HRESULT DXGI_ERROR_NOT_CURRENTLY_AVAILABLE		= MAKE_DXGI_HRESULT(34);
const HRESULT DXGI_FORMAT_DEFINED						= 1;

enum DXGI_FORMAT {
	DXGI_FORMAT_UNKNOWN						= 0,
	DXGI_FORMAT_R32G32B32A32_TYPELESS,
	DXGI_FORMAT_R32G32B32A32_FLOAT,
	DXGI_FORMAT_R32G32B32A32_UINT,
	DXGI_FORMAT_R32G32B32A32_SINT,
	DXGI_FORMAT_R32G32B32_TYPELESS,
	DXGI_FORMAT_R32G32B32_FLOAT,
	DXGI_FORMAT_R32G32B32_UINT,
	DXGI_FORMAT_R32G32B32_SINT,
	DXGI_FORMAT_R16G16B16A16_TYPELESS,
	DXGI_FORMAT_R16G16B16A16_FLOAT,
	DXGI_FORMAT_R16G16B16A16_UNORM,
	DXGI_FORMAT_R16G16B16A16_UINT,
	DXGI_FORMAT_R16G16B16A16_SNORM,
	DXGI_FORMAT_R16G16B16A16_SINT,
	DXGI_FORMAT_R32G32_TYPELESS,
	DXGI_FORMAT_R32G32_FLOAT,
	DXGI_FORMAT_R32G32_UINT,
	DXGI_FORMAT_R32G32_SINT,
	DXGI_FORMAT_R32G8X24_TYPELESS,
	DXGI_FORMAT_D32_FLOAT_S8X24_UINT,
	DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS,
	DXGI_FORMAT_X32_TYPELESS_G8X24_UINT,
	DXGI_FORMAT_R10G10B10A2_TYPELESS,
	DXGI_FORMAT_R10G10B10A2_UNORM,
	DXGI_FORMAT_R10G10B10A2_UINT,
	DXGI_FORMAT_R11G11B10_FLOAT,
	DXGI_FORMAT_R8G8B8A8_TYPELESS,
	DXGI_FORMAT_R8G8B8A8_UNORM,
	DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
	DXGI_FORMAT_R8G8B8A8_UINT,
	DXGI_FORMAT_R8G8B8A8_SNORM,
	DXGI_FORMAT_R8G8B8A8_SINT,
	DXGI_FORMAT_R16G16_TYPELESS,
	DXGI_FORMAT_R16G16_FLOAT,
	DXGI_FORMAT_R16G16_UNORM,
	DXGI_FORMAT_R16G16_UINT,
	DXGI_FORMAT_R16G16_SNORM,
	DXGI_FORMAT_R16G16_SINT,
	DXGI_FORMAT_R32_TYPELESS,
	DXGI_FORMAT_D32_FLOAT,
	DXGI_FORMAT_R32_FLOAT,
	DXGI_FORMAT_R32_UINT,
	DXGI_FORMAT_R32_SINT,
	DXGI_FORMAT_R24G8_TYPELESS,
	DXGI_FORMAT_D24_UNORM_S8_UINT,
	DXGI_FORMAT_R24_UNORM_X8_TYPELESS,
	DXGI_FORMAT_X24_TYPELESS_G8_UINT,
	DXGI_FORMAT_R8G8_TYPELESS,
	DXGI_FORMAT_R8G8_UNORM,
	DXGI_FORMAT_R8G8_UINT,
	DXGI_FORMAT_R8G8_SNORM,
	DXGI_FORMAT_R8G8_SINT,
	DXGI_FORMAT_R16_TYPELESS,
	DXGI_FORMAT_R16_FLOAT,
	DXGI_FORMAT_D16_UNORM,
	DXGI_FORMAT_R16_UNORM,
	DXGI_FORMAT_R16_UINT,
	DXGI_FORMAT_R16_SNORM,
	DXGI_FORMAT_R16_SINT,
	DXGI_FORMAT_R8_TYPELESS,
	DXGI_FORMAT_R8_UNORM,
	DXGI_FORMAT_R8_UINT,
	DXGI_FORMAT_R8_SNORM,
	DXGI_FORMAT_R8_SINT,
	DXGI_FORMAT_A8_UNORM,
	DXGI_FORMAT_R1_UNORM,
	DXGI_FORMAT_R9G9B9E5_SHAREDEXP,
	DXGI_FORMAT_R8G8_B8G8_UNORM,
	DXGI_FORMAT_G8R8_G8B8_UNORM,
	DXGI_FORMAT_BC1_TYPELESS,
	DXGI_FORMAT_BC1_UNORM,
	DXGI_FORMAT_BC1_UNORM_SRGB,
	DXGI_FORMAT_BC2_TYPELESS,
	DXGI_FORMAT_BC2_UNORM,
	DXGI_FORMAT_BC2_UNORM_SRGB,
	DXGI_FORMAT_BC3_TYPELESS,
	DXGI_FORMAT_BC3_UNORM,
	DXGI_FORMAT_BC3_UNORM_SRGB,
	DXGI_FORMAT_BC4_TYPELESS,
	DXGI_FORMAT_BC4_UNORM,
	DXGI_FORMAT_BC4_SNORM,
	DXGI_FORMAT_BC5_TYPELESS,
	DXGI_FORMAT_BC5_UNORM,
	DXGI_FORMAT_BC5_SNORM,
	DXGI_FORMAT_B5G6R5_UNORM,
	DXGI_FORMAT_B5G5R5A1_UNORM,
	DXGI_FORMAT_B8G8R8A8_UNORM,
	DXGI_FORMAT_B8G8R8X8_UNORM,
	DXGI_FORMAT_FORCE_UINT			= 0xffffffff
}

struct DXGI_RGB {
	float Red;
	float Green;
	float Blue;
}

struct DXGI_GAMMA_CONTROL {
	DXGI_RGB Scale;
	DXGI_RGB Offset;
	DXGI_RGB[1025] GammaCurve;
}

struct DXGI_GAMMA_CONTROL_CAPABILITIES {
	BOOL ScaleAndOffsetSupported;
	float MaxConvertedValue;
	float MinConvertedValue;
	UINT NumGammaControlPoints;
	float[1025] ControlPointPositions;
}

struct DXGI_RATIONAL {
	UINT Numerator;
	UINT Denominator;
}

enum DXGI_MODE_SCANLINE_ORDER {
	DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED		= 0,
	DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE		= 1,
	DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST	= 2,
	DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST	= 3
}

enum DXGI_MODE_SCALING {
	DXGI_MODE_SCALING_UNSPECIFIED	= 0,
	DXGI_MODE_SCALING_CENTERED		= 1,
	DXGI_MODE_SCALING_STRETCHED		= 2
}

enum DXGI_MODE_ROTATION {
	DXGI_MODE_ROTATION_UNSPECIFIED	= 0,
	DXGI_MODE_ROTATION_IDENTITY		= 1,
	DXGI_MODE_ROTATION_ROTATE90		= 2,
	DXGI_MODE_ROTATION_ROTATE180	= 3,
	DXGI_MODE_ROTATION_ROTATE270	= 4
}

struct DXGI_MODE_DESC {
	UINT Width;
	UINT Height;
	DXGI_RATIONAL RefreshRate;
	DXGI_FORMAT Format;
	DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
	DXGI_MODE_SCALING Scaling;
}

struct DXGI_SAMPLE_DESC {
	UINT Count;
	UINT Quality;
}
