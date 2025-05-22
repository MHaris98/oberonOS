import QtQuick 2.12
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import QtQml.Models 2.10
import QtGraphicalEffects 1.12
import "Lists"
import "utils.js" as Utils

FocusScope {
    id: root

    signal exitNav
    
    property alias currentIndex: gameNav.currentIndex
    property alias list: gameNav
    property bool active

    // Build the games list but with extra menu options at the start and end
	
    ListModel {
    id: gamesListModel

        property var activeCollection:  currentCollection!=-1 ? api.collections.get(currentCollection).games : api.allGames

        Component.onCompleted: {
            clear();
            buildList();
        }

        onActiveCollectionChanged: {
            clear();
            buildList();
        }

        function buildList() {
            activeCollection.toVarArray().map(g => g.lastPlayed).sort((a, b) => a > b);
            var gamesCounter = activeCollection.count > 10 ? 10 : activeCollection.count;
            append({
                "name":         "Explore", 
                "idx":          -1, 
                "icon":   	    "assets/images/navigation/Explore.png",
            })
            for(var i=0; i<gamesCounter; i++) {
                
                append(createListElement(i));
            }
            append({
                "name":         "Game Library", 
                "idx":          -3,
                "icon":         "assets/images/navigation/All Games.png",
            })
        }
        
        function createListElement(i) {
            return {
                name:       activeCollection.get(i).title,
                idx:        i,
              //clogo:       activeCollection.get(i).assets.logo,
			  //background:  activeCollection.get(i).assets.screenshots[0]
            }
        }
    }

    ListView {
    id: gameNav

        x: active ? vpx(125) : vpx(42)
        y: active ? vpx(0) : vpx(-52)

        Behavior on x { NumberAnimation { duration: 200; 
            easing.type: Easing.OutCubic;
            easing.amplitude: 2.0;
            easing.period: 1.5 
            }
        }
        Behavior on y { NumberAnimation { duration: 200; 
            easing.type: Easing.OutCubic;
            easing.amplitude: 2.0;
            easing.period: 1.5 
            }
        }

        width: parent.width

        Keys.onLeftPressed: {sfxNavL.play();
            if (currentIndex > 0) {decrementCurrentIndex();}}
        Keys.onRightPressed: {sfxNavR.play();
            if (currentIndex < count-1) {incrementCurrentIndex();}}
			
        focus: true
        onFocusChanged: {
            if (!focus)
                positionViewAtIndex = 0;
        }

        //Component.onCompleted: currentIndex = 1;

        orientation: ListView.Horizontal
        displayMarginBeginning: vpx(150)
        displayMarginEnd: vpx(150)
        preferredHighlightBegin: vpx(-15)
        preferredHighlightEnd: vpx(0)
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100
		spacing: vpx(0)
        clip: false
        model: !searchtext ? gamesListModel : listSearch.games
        delegate: gameBarDelegate
    }
    
    Keys.onDownPressed: { 
        sfxAccept.play(); 
        exitNav(); 
    }

    Keys.onPressed: {                    
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxAccept.play();
            exitNav();
        }
    }

    Component {
    id: gameBarDelegate

        Item {
        id: gameItem
            
            property bool selected: ListView.isCurrentItem
            property var gameData: searchtext ? modelData : listRecent.currentGame(idx)
            property bool isGame: idx >= 0 

            onGameDataChanged: { if (selected) updateData() }
            onSelectedChanged: { if (selected) updateData() }

            function updateData() {

                currentGame = gameData;
				if (idx >= -1 || idx >= -3)
				{currentScreenID = idx;}

            }

            width: outline.width
            height: width
            opacity: active || selected ? 1 : 0

            // Highlight outline
            ItemOutline {
            id: outline 

                width: {
                    if (selected && active)
                        return vpx(120);
                    else if (selected && !active)
                        return vpx(65);
                    else
                        return vpx(80);
                }
                height: width
                Behavior on width { NumberAnimation { duration: 50 } }
                radius: active ? vpx(18) : vpx(10)
                show: selected && active
                z: 10
            }
			
			// Black bg
            Rectangle {
            id: imageBG

                anchors.fill: imageMask
                radius: imageMask.radius
                color: "black"
                opacity: 0.7
                //visible: gameData ? gameData.assets.boxFront : true
                visible: icon ? true : false
            }

            Image {
            id: screenshot

                anchors.fill: imageMask
                source: gameData.assets.boxFront
				opacity: 1
                fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(vpx(175), vpx(175))
					//sourceSize: Qt.size(parent.width, parent.height)
                smooth: true
                asynchronous: true
                visible: false

                Image {
                id: gameLogo
                    anchors.fill: parent
                    anchors.margins: selected && active ? vpx(31) : vpx(20)
					Behavior on anchors.margins { NumberAnimation { duration: 50 } }
                    source: icon
                    sourceSize: Qt.size(vpx(65), vpx(65))
					//sourceSize: Qt.size(parent.width, parent.height)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                }
            }

            Rectangle {
            id: imageMask

                anchors.fill: outline
                anchors.margins: vpx(4)
                radius: outline.radius - anchors.margins
                visible: false
            }

            OpacityMask {
                anchors.fill: imageMask
                source: screenshot
                maskSource: imageMask
            }
		
			Rectangle {
        id: getCollection
			x: active ? vpx(130) : vpx(88)
            y: active ? vpx(85) : vpx(7)
            width: vpx(55)
            height: vpx(22)
			color: "white"
            opacity: !active && idx > -1 ? 1 : 0
		//	border.width: 1.5
        //  border.color: "white"
			radius: vpx(2)

	   Text {
	   id: gameConsole
	    text: gameData.collections.get(0).shortName
        color: "black"
        font.pixelSize: vpx(10)
        font.family: consoleFont.name
		//font.bold: true
        anchors {
			verticalCenter: getCollection.verticalCenter
			horizontalCenter: getCollection.horizontalCenter
		}
	}
			
}
            Text {
            id: gameName
                x: active ? vpx(125) : vpx(88)
                y: active ? vpx(82) : vpx(32)
				text: idx > -1 ? gameData.title: name
                font.family: subtitleFont.name
                font.pixelSize: vpx(21)
                color: "white"
				clip: false
                opacity: selected ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 50 } }

            }
        }
    }
}