import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils

FocusScope {
id: root

    property alias menu: gamegrid
    property alias intro: introAnim
    property var currentState
    property int numColumns : 5

    signal exit

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;        max: 0 }
    ListAllGames    { id: listAllGames; }
    ListFavorites   { id: listFavorites; }
    ListLastPlayed  { id: listLastPlayed; }
    ListTopGames    { id: listTopGames; }


		
    property var currentList: {
        switch (currentState) {
            case "allgames":
                return listAllGames;
                break;
            case "topgames": 
                return listTopGames;
                break;
            default:
                return listAllGames;
        }
    }

    visible: false
    onVisibleChanged: {
        if (visible) {
            gamegrid.opacity = 0;
            introAnim.restart();
        }
    }

    SequentialAnimation {
    id: introAnim

        running: true
        NumberAnimation { target: gamegrid; property: "opacity"; to: 0; duration: 100 }
        PauseAnimation  { duration: 400 }
        ParallelAnimation {
            NumberAnimation { target: gamegrid; property: "opacity"; from: 0; to: 1; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
            NumberAnimation { target: gamegrid; property: "y"; from: 50; to: 0; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
        }
    }
	
	Text {
            id: gameNum
			
        anchors {

			left: parent.left; leftMargin: vpx(115)
            right: parent.right; rightMargin: vpx(109)
		  //bottom: parent.bottom; bottomMargin: vpx(212)
			top: parent.top; topMargin: vpx(95)
				}
				text: "All: "
                font.family: subtitleFont.name
                font.pixelSize: vpx(16)
                color: "white"
	}
	
		Text {
            id: gameArr
			
        anchors {

			//left: parent.left; leftMargin: vpx(109)
            right: parent.right; rightMargin: vpx(115)
		  //bottom: parent.bottom; bottomMargin: vpx(212)
			top: parent.top; topMargin: vpx(95)
				}
				text: "Sort By: Name (A - Z)"
                font.family: subtitleFont.name
                font.pixelSize: vpx(16)
                color: "white"
	}

    GridView {
    id: gamegrid

        width: parent.width;
        height: vpx(500);

        anchors {

			left: parent.left; leftMargin: vpx(109)
            right: parent.right; rightMargin: vpx(109)
		  //bottom: parent.bottom; bottomMargin: vpx(212)
			top: parent.top; topMargin: vpx(125)
        }
        
        focus: true
       // cellWidth: width / numColumns
        cellWidth: vpx(212)
        cellHeight: vpx(212)

        preferredHighlightBegin: vpx(0)
        preferredHighlightEnd: vpx(212)
        highlightRangeMode: ListView.ApplyRange
        //header: gridHeader
		clip: true
        model: currentList.games
        delegate: boxartDelegate
		highlightMoveDuration: 100

        // We need to set to -1 so there are no selections in the grid
        //currentIndex: focus ? currentGameIndex : -1
        /*onCurrentIndexChanged: {
            // Ensure that the game index is never set to -1
            if (currentIndex != -1)
                currentGameIndex = currentIndex;
        }*/



        Component {

        id: boxartDelegate
		


            GameGridItem {
            id: delegatecontainer
                selected:   GridView.isCurrentItem && root.focus
                gameData:   modelData
                width:      GridView.view.cellWidth
                height:     GridView.view.cellHeight
                radius:     vpx(2)

				

                // List specific input
                Keys.onPressed: {                    
                    // Back
                    if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        sfxBack.play();
                        exit();
                    }

                    // Favorites
                    if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        sfxToggle.play();
                        modelData.favorite = !modelData.favorite;
                    }
                }
            }
        }

        property int col: currentIndex % 4;
        Keys.onLeftPressed: {
            sfxNavL.play();
            moveCurrentIndexLeft();
			
        }
        Keys.onRightPressed: {
            sfxNavR.play();
            moveCurrentIndexRight();
        }
        Keys.onUpPressed: {
            
            if (currentIndex >= numColumns) {
                sfxNavU.play();
                moveCurrentIndexUp();
            } else {
                sfxBack.play();
                exit();
            }
        }
        Keys.onDownPressed: {
			
            sfxNavD.play();
			moveCurrentIndexDown();
			
        }
    }
}