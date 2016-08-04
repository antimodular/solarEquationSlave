unit PgrStrmReg.pas;

// This header file provides the functionality for the user to access extended 
// registers through the IAMVideoProcAmp interface in DirectShow.
// The accessible extended registers
// are listed below in the PGRVideoProcAmpProperty enumeration.

{$MINENUMSIZE 4}

interface

type
  TPGRVideoProcAmpProperty =
    (VideoProcAmp_PGR_REG_ABS_VAL_AUTO_EXPOSURE = 0x00010000,
     VideoProcAmp_PGR_REG_ABS_VAL_SHUTTER,
     VideoProcAmp_PGR_REG_ABS_VAL_GAIN,
     VideoProcAmp_PGR_REG_ABS_VAL_BRIGHTNESS,
     VideoProcAmp_PGR_REG_ABS_VAL_GAMMA,
     VideoProcAmp_PGR_REG_EXTENDED_SHUTTER,
     VideoProcAmp_PGR_REG_GPIO_CONTROL,
     VideoProcAmp_PGR_REG_GPIO_XTRA,
     VideoProcAmp_PGR_REG_SHUTTER_DELAY,
     VideoProcAmp_PGR_REG_GPIO_CTRL_PIN_0,
     VideoProcAmp_PGR_REG_GPIO_XTRA_PIN_0,
     VideoProcAmp_PGR_REG_GPIO_CTRL_PIN_1,
     VideoProcAmp_PGR_REG_GPIO_XTRA_PIN_1,
     VideoProcAmp_PGR_REG_GPIO_CTRL_PIN_2,
     VideoProcAmp_PGR_REG_GPIO_XTRA_PIN_2,
     VideoProcAmp_PGR_REG_FRAME_TIME,
     VideoProcAmp_PGR_REG_FRAME_SYNC_OFFSET,
     VideoProcAmp_PGR_REG_FRAME_TIMESTAMP,
     VideoProcAmp_PGR_REG_NUM_ITEMS);

implementation

end.

