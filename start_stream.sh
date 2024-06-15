gst-launch-1.0 videotestsrc ! video/x-raw,width=640,height=480 ! videoconvert ! queue ! vp8enc ! rtpvp8pay ! udpsink host=127.0.0.1 port=8004
