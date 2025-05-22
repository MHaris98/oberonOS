import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils
import "qrc:/qmlutils" as ScrollUtils

FocusScope {
id: root

    property bool selected
    property bool highlighted
    property var gameData
    property bool isFave: gameData ? gameData.favorite : false
    property alias radius: mask.radius

    signal activated

    // List specific input
    Keys.onPressed: {
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxAccept.play();
            launchGame(gameData);
            activated();
        }

        // Favorite
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            gameData.favorite = !gameData.favorite
        }
    }

    width: vpx(160)
  //height: selected ? vpx(160) : vpx(90)
    height: vpx(90)
  //Behavior on height { NumberAnimation { duration: 75 } }

    function logo(data) {
    if (data != null) {
        if (data.assets.boxFront.includes("header.jpg")) 
            return steamLogo(data);
        else {
            if (data.assets.logo != "")
                return data.assets.logo;
            }
        }
        return "";
    }

    Item {
    id: screenshotContainer

        width: outline.width
        height: outline.height
        scale: 1
		
        ItemOutline {
        id: outline 

            anchors.fill: screenshot
            radius: mask.radius - anchors.margins
            show: selected
            z: 15
        }

        Image {
        id: screenshot

            width: root.width;
            height: root.height;		
			
          //property var screenshotImage: (gameData && (gameData.collections.get(0).shortName === "retropie" || gameData.collections.get(0).shortName === "android")) ? gameData.assets.boxFront : (gameData.collections.get(0).shortName === "steam") ? fanArt(gameData) : gameData.assets.boxFront[0]
          //source: gameData ? gameData.assets.poster || "" : ""
		    source: "assets/images/store/2.png"
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            visible: true
        }
        
        
        Rectangle {
        id: mask

            anchors.fill: screenshot
            radius: vpx(18)
            visible: false
        }

        OpacityMask {
            anchors.fill: screenshot
            source: screenshot
            maskSource: mask
        }

        Rectangle {
        id: container

            width: screenshot.width
            height: screenshot.height
            radius: mask.radius
            color: "black"
            opacity: 0.4
            border.width: 0
            border.color: "#333333"
			visible: screenshot.paintedWidth < 1
        }

        Loader {
            anchors.fill: screenshot
            anchors.centerIn: screenshot
            sourceComponent: gameData ? logo : undefined
        }
        
        Component {
        id: logo

            Image {
                anchors.fill: parent
                anchors.centerIn: parent
				anchors.margins: vpx(20)
				property var logoImage: {
                    if (gameData != null) {
                             return gameData.assets.logo;	}
					else {return ""}
				}
                source: logoImage
				//sourceSize: Qt.size(parent.width, parent.height)
                sourceSize: Qt.size(vpx(75), vpx(75))
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
				visible: true
				//z: 10
            }
        }

        Rectangle {
        id: favIcon
            width: vpx(26)
            height: width
            radius: width/2
            visible: isFave

            anchors {
                right: parent.right; rightMargin: vpx(15)
                top: parent.top; topMargin: vpx(10)
            }
            color: "black"
            opacity: 0.5
        }

        Image {
        id: star

            anchors.fill: favIcon
            anchors.margins: vpx(5)
            source: "assets/images/navigation/Favorites.png"
            sourceSize: Qt.size(favIcon.width, favIcon.height)
            smooth: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        ColorOverlay {
            anchors.fill: star
            source: star
            color: theme.highlight
            visible: isFave
        }

        // Mouse/touch functionality
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { highlighted = true }
            onExited: { highlighted = false }
            onClicked: {
                launchGame(gameData);
                activated();
            }
        }
    }  
}