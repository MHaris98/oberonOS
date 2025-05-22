import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {
id: root
    
    // Pull in our custom lists and define
    ListAllGames    { id: listNone;         max: 0 }
    ListAllGames    { id: listAllGames;     max: 08 }
    ListPublisher   { id: listPublisher;    max: 08 }
	ListTopGames    { id: listTopGames;     max: 08 }
	ListMostPlayed  { id: listMostPlayed;   max: 08 }
    ListLastPlayed  { id: listLastPlayed;   max: 6 }
    ListFavorites   { id: listFavorites; }

    property alias menu: mainList
    property alias intro: introAnim
    property bool allGamesView: currentCollection == -1
    property var collectionData: !allGamesView ? api.collections.get(currentCollection) : null

    signal exit
	
	onCollectionDataChanged: {
        mainList.opacity = 0;
        introAnim.restart();
    }

    SequentialAnimation {
    id: introAnim

        running: true
        NumberAnimation { target: mainList; property: "opacity"; to: 0; duration: 100 }
        PauseAnimation  { duration: 400 }
        ParallelAnimation {
            NumberAnimation { target: mainList; property: "opacity"; from: 0; to: 1; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
            NumberAnimation { target: mainList; property: "y"; from: 50; to: 0; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
        }
    }


    ObjectModel {
    id: mainModel

        A0HorizontalList {
        id: a0List
			property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listMostPlayed.games
			height: vpx(200)
			title: "Most Played"
            focus: selected
            anchors { left: parent.left; right: parent.right }	
        }

    }

    ListView {
    id: mainList
        
        width: parent.width;
        height: parent.height;
        header: headerComponent
        model: mainModel
        focus: root.focus
        currentIndex: -1
		
        onFocusChanged: {
            if (focus)
                currentIndex = 0
        }

        anchors {
            left: parent.left; leftMargin: vpx(115)
            right: parent.right; rightMargin: vpx(115)
        }

        preferredHighlightBegin: vpx(100)
        preferredHighlightEnd: parent.height - vpx(300)
        //highlightRangeMode: ListView.ApplyRange
        //snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100
		spacing: vpx(0)
        Keys.onUpPressed: { 
            if (currentIndex == 0) {
                sfxBack.play();
                exit();
            } else {
                sfxNavU.play(); 
                decrementCurrentIndex();
            }
        }
        Keys.onDownPressed: { sfxNavD.play(); incrementCurrentIndex(); }

        Component {
        id: headerComponent

            Item {
                width: mainList.width
                height: vpx(345)

                Image {
                id: collectionLogo
					width: mainList.width - vpx(535)
                    property string logoName: currentCollection != -1 ? Utils.processPlatformName(api.collections.get(currentCollection).shortName) : "allgames"
//                    source: "assets/images/promos/" + logoName + ".png"
                    sourceSize: Qt.size(parent.width, parent.height)
                    anchors { 
                        //top: parent.top; topMargin: vpx(0)
                        bottom: parent.bottom; bottomMargin: vpx(0)
                    }
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                   // verticalAlignment: Image.alignBottom
                }
            }
        }
    }
}