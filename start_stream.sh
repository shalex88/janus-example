#!/bin/bash

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
}

# Function to start the stream
start_stream() {
    echo "Starting the stream..."
    # GStreamer pipeline
    #TODO: Change the pipeline to match your camera settings and receive camera ID as an argument
    pipeline="videotestsrc ! video/x-raw,width=640,height=480 ! videoconvert ! queue ! vp8enc ! rtpvp8pay ! udpsink host=127.0.0.1 port=5104"
    # Run the GStreamer pipeline in the background and redirect the output to /dev/null
    gst-launch-1.0 -v $pipeline > /dev/null 2>&1 &
    # Save the process ID of the pipeline
    echo $! > /tmp/gst_pipeline_$1.pid
}

# Function to stop the stream
stop_stream() {
    if [ -f /tmp/gst_pipeline_$1.pid ]; then
        echo "Stopping the stream..."
        # Kill the specific GStreamer pipeline process
        kill $(cat /tmp/gst_pipeline_$1.pid)
        rm /tmp/gst_pipeline_$1.pid
    else
        echo "Stream is not running."
    fi
}

case "$2" in
    install)
        install_dependencies
        ;;
    start)
        start_stream $1
        ;;
    stop)
        stop_stream $1
        ;;
    *)
        echo "Usage: $0 {camera_id} {start|stop}"
        exit 1
        ;;
esac
