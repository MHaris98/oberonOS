import QtQuick 2.12
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
    //ListAllGames    { id: listNone;         max: 0 }
    //ListAllGames    { id: listAllGames;     max: 08 }
    //ListPublisher   { id: listPublisher;    max: 06; publisher: gameData ? gameData.publisher : "" }
    //ListTopGames    { id: listTopGames;     max: 08 }
    //ListLastPlayed  { id: listLastPlayed;   max: 12 }

    //property var gameData: (currentCollection != -1) ? api.collections.get(currentCollection).games.get(Math.floor(Math.random() * api.collections.get(currentCollection).games.count)) : api.allGames.get(Math.floor(Math.random() * api.allGames.count))
    property var gameData: listLastPlayed.games.get(currentGameIndex)
    property alias menu: mainList

    signal exit

    onGameDataChanged: {
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

        Item {
        id: featuredRecentGame

            width: parent.width
            height: vpx(482)
            property bool selected: ListView.isCurrentItem && root.focus
			
			
            

            Image {
            id: favelogo

                width: vpx(350)
                anchors { 
                    top: parent.top
                    bottom: gameNav.top; bottomMargin: vpx(50)
                    left: parent.left;

                }
				
                property var logoImage:  gameData ?
                    gameData.collections.get(0).shortName === "retropie" ? 
                        gameData.assets.boxFront 
                    : 
                        (gameData.collections.get(0).shortName === "steam") ? 
                            Utils.logo(gameData) 
                        : 
                            gameData.assets.logo
                : ""

                source: gameData ? logoImage || "" : ""
                sourceSize: Qt.size(parent.width, parent.height)
               fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                verticalAlignment: Image.AlignBottom
		
			
	}

            Text {
            id: gameName
				width: vpx(500)
                text: gameData ? !gameData.assets.logo ? gameData.title : "" : ""
                font.pixelSize: vpx(36)
                font.family: subtitleFont.name
				wrapMode: Text.WordWrap
                anchors {
                    bottom: favelogo.verticalCenter; bottomMargin: vpx(-33)
                    left: parent.left;
                }
                color: theme.text
            }
			
			Text {
            id: gameSummary
				width: vpx(500)
                text: gameData ? !gameData.assets.logo ? gameData.summary : "" : ""
                font.pixelSize: vpx(19)
                font.family: bodyFont.name
				lineHeight: 1.2
				wrapMode: Text.WordWrap
                anchors {
                    top: gameName.bottom; topMargin: vpx(16)
                    left: parent.left;
                }
                color: theme.text
            }
			
			Text {
            id: gameReadmore
				width: vpx(500)
                text: gameData ? !gameData.assets.logo ? "Read More Below" : "" : ""
                font.pixelSize: vpx(14)
                font.family: subtitleFont.name
				wrapMode: Text.WordWrap
				font.bold: true
                anchors {
                    top: gameSummary.bottom; topMargin: vpx(24)
                    left: parent.left;
                }
                color: theme.text
            }

            ObjectModel {
            id: gameNavModel

                Button {
                id: playButton  

                    width: vpx(240)
                    isSelected: featuredRecentGame.selected && ListView.isCurrentItem
                    onActivated: { 
                        sfxAccept.play();
                      launchGame(gameData); 
                    }
                }

                Button {
                id: favButton  

                    width: vpx(50)
                    isSelected: featuredRecentGame.selected && ListView.isCurrentItem
                    icon: "assets/images/Favorites.png"
                    onActivated: { 
                        sfxToggle.play();
                        gameData.favorite = !gameData.favorite;
                    }
                    hlColor: gameData ? gameData.favorite ? theme.highlight : "white" : "white"
                }
            }
            
            ListView {
            id: gameNav

                width: vpx(500)
                height: vpx(50)
                anchors { 
                    top: parent.top; topMargin: vpx(282)
                    left: parent.left;
                }
                focus: featuredRecentGame.selected
                orientation: ListView.Horizontal
                spacing: vpx(10)
                model: gameNavModel
                keyNavigationWraps: true
                
                Keys.onLeftPressed: {
                    sfxNavL.play();
                    decrementCurrentIndex();
                }
                Keys.onRightPressed: {
                    sfxNavR.play();
                    incrementCurrentIndex();
                }
            }

            Image {
            id: boxart

                width: vpx(250)
                height: vpx(250)
                anchors {
                    bottom: gameNav.bottom
                    right: parent.right
                }
                source: gameData ? Utils.boxArt(gameData) : ""
                //sourceSize: Qt.size(vpx(512), vpx(512))
				sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignBottom
            }
			
			Image {
            id: esrbArt

                width: vpx(400)
                height: vpx(80)
				opacity: featuredRecentGame.selected ? 1: 0
				//Behavior on opacity { NumberAnimation { duration: 100 } }
                anchors {
                    top: gameNav.bottom; topMargin: vpx(25)
                    left: parent.left
                }	
            source: {
			if (gameData.extra.esrb == "A")
            return "assets/images/ESRB/A.png";
            if (gameData.extra.esrb == "M")
            return "assets/images/ESRB/M.png";
            if (gameData.extra.esrb == "T")
            return "assets/images/ESRB/T.png";
            if (gameData.extra.esrb == "E")
            return "assets/images/ESRB/E.png";
            if (gameData.extra.esrb == "E10")
            return "assets/images/ESRB/E10.png";
			else
			return "assets/images/ESRB/RP.png";
			}
              //sourceSize: Qt.size(vpx(400), vpx(80))
				sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }
			
			Image {
            id: stats

                width: vpx(250)
                height: vpx(80)
				opacity: featuredRecentGame.selected ? 1 : 0
				//Behavior on opacity { NumberAnimation { duration: 100 } }
                anchors {
                    top: boxart.bottom; topMargin: vpx(25)
                    right: parent.right
                }
				source: "assets/images/stats.png"
                sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true

            }
			
				Text {
				opacity: featuredRecentGame.selected ? 0.8 : 0
				Behavior on opacity { NumberAnimation { duration: 100 } }
                anchors {
                    top: stats.top; topMargin: vpx(14)
                    left: stats.left; leftMargin: vpx(60)
                }
				text: "Last Played"
				color: "white"
                font {
                pixelSize: vpx(14)
                family: subtitleFont.name
                }
				}
				Text {
				opacity: featuredRecentGame.selected ? 1 : 0
				Behavior on opacity { NumberAnimation { duration: 100 } }
                anchors {
                    top: stats.top; topMargin: vpx(35)
                    left: stats.left; leftMargin: vpx(60)
                }
                text: {
                    if (!gameData)
                        return "N/A";
                    if (isNaN(gameData.lastPlayed))
                        return "Never";

                    var now = new Date();

                    var diffHours = (now.getTime() - gameData.lastPlayed.getTime()) / 1000 / 60 / 60;
                    if (diffHours < 24 && now.getDate() === gameData.lastPlayed.getDate())
                        return "Today";

                    var diffDays = Math.round(diffHours / 24);
                    if (diffDays <= 1)
                        return "Yesterday";

                    return diffDays +  " Days"
                }
                color: "white"
                font {
                pixelSize: vpx(20)
                family: subtitleFont.name
			//	bold: true
                }
            }
			
			
				Text {
				opacity: featuredRecentGame.selected ? 0.8 : 0
				Behavior on opacity { NumberAnimation { duration: 100 } }
                anchors {
                    top: stats.top; topMargin: vpx(14)
                    right: stats.right; rightMargin: vpx(15)
                }
				text: "Play Time"
				color: "white"
                font {
                pixelSize: vpx(14)
                family: subtitleFont.name
                }
				}
				Text {
				opacity: featuredRecentGame.selected ? 1 : 0
				Behavior on opacity { NumberAnimation { duration: 100 } }
                anchors {
                    top: stats.top; topMargin: vpx(35)
                    right: stats.right; rightMargin: vpx(15)
                }
                text: {
                    if (!gameData)
                        return "-";

                    var minutes = Math.ceil(gameData.playTime / 60)
                    if (minutes <= 90)
                        return Math.round(minutes) + " Min";

                    return parseFloat((minutes / 60).toFixed(1)) + " Hrs"
                }
                color: "white"
				lineHeight: 0.6
                font {
                pixelSize: vpx(20)
                family: subtitleFont.name
			//	bold: true
                }
            }	
      }

		ListView {
            id: descListView
                anchors {top: esrbArt.bottom;
				left: parent.left;
				}
			    
                width: root.width
                height: vpx(450)
            Text {

				text: "Game and legal info"
                font.family: subtitleFont.name
                font.pixelSize: vpx(15)
				opacity: 1
				//Behavior on opacity { NumberAnimation { duration: 100 } }
                //font.bold: true
                color: theme.text

                anchors { left: parent.left; leftMargin: vpx(5)
				top: parent.top; topMargin: vpx(-33) }
				}
                orientation: ListView.Horizontal
                spacing: vpx(22)
                model: 3
				focus: featuredRecentGame.selected
				keyNavigationWraps: false
				preferredHighlightBegin: vpx(0)
				preferredHighlightEnd: preferredHighlightBegin + vpx(257)
				// highlightRangeMode: ListView.StrictlyEnforceRange
				snapMode: ListView.SnapOneItem 
				highlightMoveDuration: 100
				clip: false
				delegate: descList

        Component {
        id: descList 
			
		 Rectangle {
		 

                id: descRec  
				property bool selected: !featuredRecentGame.selected && !gameNavModel.selected
				//opacity: !gameNavModel.selected ? 0.8 : 0
				Behavior on opacity { NumberAnimation { duration: 50 } }
				opacity: 0.8
				width: vpx(335)
				height: vpx(455)
				radius: vpx(10)
				color: "black"
			//	border.width: selected ? vpx(1) : vpx(0)
			//	Behavior on border.width { NumberAnimation { duration: 200 } }
			//	border.color: "white"
	
			
		Text {
        id: newDesc
		
			anchors {
                    top: parent.top; topMargin: vpx(20)
                    left: parent.left; leftMargin: vpx(20)
                    right: parent.right; rightMargin: vpx(20)
                    bottom: parent.bottom; bottomMargin: vpx(20)
                }
		
			width: parent.width
			height: parent.height
			font.pixelSize: vpx(14)
            font.family: subtitleFont.name
            color: theme.text
			lineHeight: 1.2
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
			property string recNum: modelData
			
            text: {
			
			if (recNum == "0")
            return gameData && (gameData.summary || gameData.description) ? gameData.description || gameData.summary : "No description available";
			
			
			if (recNum == "1")
            return "Publisher:   " + gameData.publisher + "

Release Date:   " + gameData.extra.release + "

Players:   " + gameData.players + "
__________________________________________

Metacritic Rating:   " + gameData.extra.rating + "

Size:   " + gameData.extra.size + "

Genres:   " + gameData.genre;


			if (recNum == "2")
            return "To play this game on PC, your system may need to be updated to the latest system software. Although this game have all DLC to purchase date, some features available or released after the PC purchase may be absent.
Audio
English, French, German, Italian, Spanish

Subtitles
English, French, German, Italian, Spanish 

Online features require an account and are subject to terms and applicable privacy policy

Software subject to lincense.";
			else
			return ":)";
			}

        }	
			
}
		
      }
}

        /*NewHorizontalList {
        id: recentList
		anchors { left: parent.left;
		 topMargin: vpx(200)
		}
            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listPublisher.games
			

            width: mainList.width
            height: vpx(300)

            title: gameData ? "More by " + gameData.publisher : ""
            
        }*/

        /*HorizontalList {
        id: favouriteList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listFavorites.games

            height: vpx(300)

            title: "Favorites"

            focus: selected
            anchors { left: parent.left; right: parent.right }
        }*/

        /*HorizontalList {
        id: topList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listTopGames.games

            height: vpx(300)

            title: "Recommended"

            focus: selected
            anchors { left: parent.left; right: parent.right }
        }*/
    }

    ListView {
    id: mainList
		
        
        width: parent.width;
        height: parent.height;

        anchors {
            left: parent.left; leftMargin: vpx(115)
            right: parent.right; rightMargin: vpx(115)
        }

        model: mainModel
        focus: true
		
        onFocusChanged: {
            if (!focus)
                positionViewAtIndex = 0;
        }

        preferredHighlightBegin: vpx(85)
        preferredHighlightEnd: parent.height - vpx(85)
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100

        Keys.onUpPressed: { 
            if (currentIndex == 0) {
                sfxBack.play();
                exit();
            } else {
                sfxNavU.play(); 
                decrementCurrentIndex();
            }
        }
        Keys.onDownPressed: { 
            sfxNavD.play(); 
            incrementCurrentIndex() 
        }
    }
}
