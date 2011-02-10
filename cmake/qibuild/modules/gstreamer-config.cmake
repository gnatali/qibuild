## Copyright (C) 2011 Aldebaran Robotics

clean(GSTREAMER)
fpath(GSTREAMER  gst/gst.h PATH_SUFFIXES gstreamer-0.10 gstreamer)
flib (GSTREAMER  NAMES
  gstreamer-0.10.0
  gstreamer-0.10
  gstreamer)

if (APPLE)
  depend (GSTREAMER REQUIRED ICONV)
  depend (GSTREAMER REQUIRED GETTEXT)
endif()

export_lib(GSTREAMER)