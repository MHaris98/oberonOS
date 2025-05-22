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

    width: vpx(200)
    height: vpx(200)


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
        scale: 0.95
		
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
			//source: gameData ? gameData.assets.boxFront[0] : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            visible: false
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
				//anchors.margins: vpx(30)
				property var logoImage: {
                    if (gameData != null) {return gameData.assets.boxFront;} 
					else {return ""}	}
                source: logoImage
                sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
				//z: 10
            }
        }

		Rectangle {
        id: innerBorder

            width: parent.width
            height: screenshot.height - vpx(100)
			// color: "black"
            opacity: selected ? 1 : 0
			Behavior on opacity { NumberAnimation { duration: 100 } }
			radius: mask.radius
            anchors {
                bottom: parent.bottom; bottomMargin: vpx(7)
				right: parent.right; rightMargin: vpx(7)
            }
			 gradient: Gradient {
              orientation: Gradient.horizontal
              GradientStop { position: 0.0; color: "Transparent" }
              GradientStop { position: 1.0; color: "Black" }
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


Rectangle {

        width: parent.width - vpx(15)
        height: parent.height - vpx(125)
		color: "Transparent"
		anchors {
                bottom: parent.bottom; bottomMargin: vpx(18)
				left: parent.left; leftMargin: vpx(16)
				right: parent.right; rightMargin: vpx(16)
            }
		
    Text {
	   id: gameTitle
        width: parent.width
        text: gameData.title
        color: theme.text
		//scale: selected ? 0.9 : 0.9
        opacity: selected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
        font.pixelSize: vpx(14)
        font.family: subtitleFont.name
		//elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 0.9
        verticalAlignment: Text.AlignBottom
        anchors {
    bottom: parent.bottom; bottomMargin: vpx(0)
		}
		
		Rectangle {
        id: getCollection
			visible: gameData ? 1 : 0
            width: vpx(55)
            height: vpx(20)
			color: "white"
            opacity: selected ? 1 : 0
			Behavior on opacity { NumberAnimation { duration: 100 } }
		//	border.width: 1.5
        //  border.color: "white"
			radius: mask.radius
            anchors {
			top: parent.top; topMargin: vpx(-32)
			}
			
			
	   Text {
	   id: gameConsole
	    text: gameData.collections.get(0).shortName
        color: "black"
        opacity: selected ? 1 : 0
		Behavior on opacity { NumberAnimation { duration: 100 } }
        font.pixelSize: vpx(10)
        font.family: consoleFont.name
     // font.bold: true
        anchors {
			verticalCenter: getCollection.verticalCenter
			horizontalCenter: getCollection.horizontalCenter
		}
		}
			
			}
		
		}
		}
    
}