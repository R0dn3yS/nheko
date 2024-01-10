// SPDX-FileCopyrightText: Nheko Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

import "../ui/media"
import QtMultimedia
import QtQuick
import QtQuick.Controls
import im.nheko

Item {
    id: content

    required property double proportionalHeight
    required property int type
    required property int originalWidth
    required property int duration
    required property string thumbnailUrl
    required property string eventId
    required property string url
    required property string body
    required property string filesize
    property double divisor: EventDelegateChooser.isReply ? 10 : 4
    property int tempWidth: originalWidth < 1? 400: originalWidth
    implicitWidth: type == MtxEvent.VideoMessage ? Math.round(tempWidth*Math.min((timelineView.height/divisor)/(tempWidth*proportionalHeight), 1)) : 500
    width: Math.min(parent?.width ?? implicitWidth, implicitWidth)
    height: (type == MtxEvent.VideoMessage ? width*proportionalHeight : mediaControls.height) + fileInfoLabel.height
    //implicitHeight: height

    property int metadataWidth
    property bool fitsMetadata: parent != null ? ((parent.width - fileInfoLabel.width) > metadataWidth+4) : false

    Component.onCompleted: mxcmedia.startDownload(true)

    MxcMedia {
        id: mxcmedia

        // TODO: Show error in overlay or so?
        roomm: room
        eventId: content.eventId
        videoOutput: videoOutput

        muted: mediaControls.muted
        volume: mediaControls.desiredVolume
    }

    Rectangle {
        id: videoContainer

        color: content.type == MtxEvent.VideoMessage ? palette.window : "transparent"
        width: parent.width
        height: parent.height - fileInfoLabel.height

        TapHandler {
            onTapped: Settings.openVideoExternal ? room.openMedia(eventId) : mediaControls.showControls()
        }

        Image {
            anchors.fill: parent
            visible: content.type == MtxEvent.VideoMessage
            source: content.thumbnailUrl ? thumbnailUrl.replace("mxc://", "image://MxcImage/") + "?scale" : "image://colorimage/:/icons/icons/ui/video-file.svg?" + palette.windowText
            asynchronous: true
            fillMode: Image.PreserveAspectFit

            VideoOutput {
                id: videoOutput

                visible: content.type == MtxEvent.VideoMessage
                clip: true
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectFit
                orientation: mxcmedia.orientation
            }

        }

        MediaControls {
            id: mediaControls

            anchors.left: videoContainer.left
            anchors.right: videoContainer.right
            anchors.bottom: videoContainer.bottom
            playingVideo: content.type == MtxEvent.VideoMessage
            positionValue: mxcmedia.position
            duration: mediaLoaded ? mxcmedia.duration : content.duration
            mediaLoaded: mxcmedia.loaded
            mediaState: mxcmedia.playbackState
            onPositionChanged: mxcmedia.position = position
            onPlayPauseActivated: mxcmedia.playbackState == MediaPlayer.PlayingState ? mxcmedia.pause() : mxcmedia.play()
            onLoadActivated: mxcmedia.startDownload()
        }
    }

    // information about file name and file size
    Label {
        id: fileInfoLabel

        anchors.top: videoContainer.bottom
        text: content.body + " [" + filesize + "]"
        textFormat: Text.RichText
        elide: Text.ElideRight
        color: palette.text

        background: Rectangle {
            color: palette.base
        }

    }

}
